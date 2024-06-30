import AVFoundation
import UIKit

class VideoViewModel: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var videoSettingAlert = false
    @Published var videoSession = AVCaptureSession()
    @Published var videoOutput = AVCaptureMovieFileOutput()
    @Published var videoPreview: AVCaptureVideoPreviewLayer!
    func checkPermission() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.setupSession()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.videoSettingAlert.toggle()
                    }
                }
            }
        case .denied:
            self.videoSettingAlert.toggle()
        case .granted:
            self.setupSession()
        @unknown default:
            break
        }
    }

    func setupSession() {
        do {
            self.videoSession.beginConfiguration()
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
            let input = try AVCaptureDeviceInput(device: device!)
            if self.videoSession.canAddInput(input) {
                self.videoSession.addInput(input)
            }
            if self.videoSession.canAddOutput(self.videoOutput) {
                self.videoSession.addOutput(self.videoOutput)
            }
            self.videoSession.commitConfiguration()
            self.videoSession.startRunning()
        } catch {
            print(error.localizedDescription)
        }
    }

    func startRecording() {
        guard !isRecording else {
            return
        }
        let outputPath = NSTemporaryDirectory() + "output.mov"
        let outputFileURL = URL(fileURLWithPath: outputPath)
        videoOutput.startRecording(to: outputFileURL, recordingDelegate: self)
        self.isRecording = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 29) {
            if self.isRecording {
                self.stopRecording()
            }
        }
    }

    func stopRecording() {
        guard isRecording else {
            return
        }
        videoOutput.stopRecording()
        isRecording = false
    }

    func cleanRecording(_ outputFileURL: URL) {
        let path = outputFileURL.path
        if FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.removeItem(atPath: path)
                print("Delete path of video successfully")
            } catch {
                print("Error clean up: \(error)")
            }
        }
    }
}

extension VideoViewModel: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(
        _ output: AVCaptureFileOutput,
        didFinishRecordingTo outputFileURL: URL,
        from connections: [AVCaptureConnection],
        error: (any Error)?) {
            print("Video URL: \(outputFileURL)")
//            cleanRecording(outputFileURL)
        }
}
