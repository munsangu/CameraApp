import Foundation
import AVFoundation
import Combine

class AudioViewModel: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var audioSettingAlert = false
    @Published var isSaved = false
    @Published var audioRecorder: AVAudioRecorder?
    @Published var recorededAudioURL: URL?
    @Published var recodingTime = 0
    var audioPlayer: AVAudioPlayer?
    var timer: AnyCancellable?
    func checkPermission() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.setupRecorder()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.audioSettingAlert.toggle()
                    }
                }
            }
        case .denied:
            self.audioSettingAlert.toggle()
        case .granted:
            self.setupRecorder()
        @unknown default:
            break
        }
    }

    func setupRecorder() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
            let basePath: String = NSSearchPathForDirectoriesInDomains(
                .documentDirectory
                , .userDomainMask, true
            ).first!
            let pathComponents = [basePath, "audioRecording.m4a"]
            let audioULR = NSURL.fileURL(withPathComponents: pathComponents)!
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            audioRecorder = try AVAudioRecorder(url: audioULR, settings: settings)
            audioRecorder?.delegate = self
        } catch {
            print(error.localizedDescription)
        }
    }

    func startRecording() {
        guard let audioRecorder = audioRecorder else {
            return
        }
        if audioRecorder.record() {
            self.isRecording = true
            self.recodingTime = 0
            timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink(receiveValue: { _ in
                self.recodingTime += 1
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 29) {
                if self.isRecording {
                    self.stopRecording()
                }
            }
        }
    }

    func stopRecording() {
        timer?.cancel()
        guard let audioRecorder = audioRecorder, audioRecorder.isRecording else {
            return
        }
        audioRecorder.stop()
        isRecording = false
        isSaved = true
        recorededAudioURL = audioRecorder.url
        print(recorededAudioURL!)
        self.playRecording()
    }

    func playRecording() {
        // Here you would handle moving the file to a permanent location if desired,
        // or perform additional actions with the recorded audio file.
        // For Example: Start recorded file
        guard let recorededAudioURL = recorededAudioURL else {
            return
        }
        print("Recording saved at \(String(describing: recorededAudioURL))")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: recorededAudioURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            print("Playing recording: \(recorededAudioURL)")
        } catch {
            print("Couldn't load file for playback: \(error.localizedDescription)")
        }
    }
}

extension AudioViewModel: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("Recording was not successful.")
        }
    }
}
