import Foundation
import AVFoundation
import Combine

class MediaRepository: NSObject, CameraUseCase, VideoUseCase, AudioUseCase {
    static let shared = MediaRepository()
    var session = AVCaptureSession()
    private var cameraOutput = AVCapturePhotoOutput()
    private var videoOutput = AVCaptureMovieFileOutput()
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var timer: AnyCancellable?
    var settingAlert = false
    var isTakenPhoto = false
    var isPhotoSaved = false
    var photoCaptureCompletion: ((Result<Camera, Error>) -> Void)?
    var photoCompletion: ((Result<Camera, Error>) -> Void)?
    var videoCompletion: ((Result<URL, Error>) -> Void)?
    var videoUpdateTime: ((Int) -> Void)?
    var audioCompletion: ((Result<URL, Error>) -> Void)?
    var audioUpdateTime: ((Int) -> Void)?
    private override init() {
        super.init()
    }

    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            DispatchQueue.main.async {
                self.setupSession()
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { status in
                if status {
                    DispatchQueue.main.async {
                        self.setupSession()
                    }
                }
            }
        case .denied:
            self.settingAlert = true
        default:
            return
        }
        switch AVAudioSession.sharedInstance().recordPermission {
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                if granted {
                    DispatchQueue.main.async {
                        return
                    }
                } else {
                    DispatchQueue.main.async {
                        self.settingAlert = true
                    }
                }
            }
        case .denied:
            self.settingAlert = true
        case .granted:
            return
        @unknown default:
            break
        }
    }

    func setupSession() {
        self.session.beginConfiguration()
        do {
            if let audioDevice = AVCaptureDevice.default(for: .audio),
               let audioInput = try? AVCaptureDeviceInput(device: audioDevice) {
                if self.session.canAddInput(audioInput) {
                    self.session.addInput(audioInput)
                    print("Audio input added")
                } else {
                    print("Failed to add audio input")
                }
            }
            if let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                         for: .video, position: .back),
               let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
               self.session.canAddInput(videoInput) {
                self.session.addInput(videoInput)
                print("Video input added")
            } else {
                print("Failed to add video input")
            }
            if self.session.canAddOutput(cameraOutput) {
                self.session.addOutput(cameraOutput)
            }
            if self.session.canAddOutput(videoOutput) {
                self.session.addOutput(videoOutput)
                videoOutput.movieFragmentInterval = CMTime.invalid
            }
            self.session.commitConfiguration()
            self.session.startRunning()
        }
    }

    func terminateCameraSession() {
        DispatchQueue.main.async {
            self.session.stopRunning()
            for input in self.session.inputs {
                self.session.removeInput(input)
            }
            for output in self.session.outputs {
                self.session.removeOutput(output)
            }
            print("Camera session has been terminated.")
        }
    }

    func takePhoto(completion: @escaping (Result<Camera, Error>) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async {
            self.cameraOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            self.photoCompletion = completion
        }
    }

    func retakePhoto() {
        self.isTakenPhoto = false
        self.isPhotoSaved = false
        self.terminateCameraSession()
        DispatchQueue.main.async {
            self.setupSession()
        }
    }

    func savePhoto(_ photo: Camera) {
        guard !photo.phtoData.isEmpty else {
            print("Error: No photo data to save")
            return
        }
        do {
            try photo.phtoData.write(to: photo.photoURL)
            DispatchQueue.main.async {
                print("Photo saved to: \(photo.photoURL)")
            }
        } catch {
            print("Error saving photo: \(error.localizedDescription)")
        }
    }

    func startVideoRecording(
        updateTime: @escaping (Int) -> Void,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        if !session.isRunning || session.inputs.isEmpty || session.outputs.isEmpty {
            print("Session is not properly configured. Reconfiguring...")
            terminateCameraSession()
            setupSession()
        }
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true)
            try audioSession.setCategory(.playAndRecord, mode: .videoRecording)
            print("Audio session activated and category set to playAndRecord.")
        } catch {
            print("Failed to activate or set audio session category: \(error.localizedDescription)")
            return
        }
        timer?.cancel()
        let fixedFileName = "temporary.mp4"
        let tempURL = NSTemporaryDirectory().appending(fixedFileName)
        let fileURL = URL(fileURLWithPath: tempURL)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(at: fileURL)
            } catch {
                print("Failed to remove existing file: \(error)")
            }
        }
        videoOutput.startRecording(to: fileURL, recordingDelegate: self)
        self.videoUpdateTime = updateTime
        self.videoCompletion = completion
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { _ in
            let videoRecordingTime = self.videoOutput.recordedDuration.seconds
            updateTime(Int(videoRecordingTime))
        }
    }

    func stopVideoRecording() {
        videoOutput.stopRecording()
        timer?.cancel()
        timer = nil
    }

    func startAudioRecording(
        updateTime: @escaping (Int) -> Void,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        guard let audioRecorder = audioRecorder else {
            return
        }
        if audioRecorder.record() {
            self.audioUpdateTime = updateTime
            self.audioCompletion = completion
            timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink(receiveValue: { _ in
                updateTime(Int(audioRecorder.currentTime))
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 29) {
                if audioRecorder.isRecording {
                    self.stopAudioRecording()
                }
            }
        }
    }

    func stopAudioRecording() {
        timer?.cancel()
        guard let audioRecorder = audioRecorder, audioRecorder.isRecording else {
            return
        }
        audioRecorder.stop()
        audioCompletion?(.success(audioRecorder.url))
    }

    func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
            let basePath: String = NSSearchPathForDirectoriesInDomains(
                .documentDirectory,
                .userDomainMask, true
            ).first!
            let pathComponents = [basePath, "audioRecording.m4a"]
            let audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            audioRecorder?.delegate = self as AVAudioRecorderDelegate
        } catch {
            print(error.localizedDescription)
        }
    }

    func terminateAudioSession(completion: @escaping () -> Void) {
        if audioRecorder?.isRecording == true {
            audioRecorder?.stop()
        }
        do {
            try AVAudioSession.sharedInstance().setActive(false)
            completion()
        } catch {
            print("Failed to deactivate audio session: \(error.localizedDescription)")
            completion()
        }
    }

    func playAudioRecording() {
        guard let recorededAudioURL = audioRecorder?.url else {
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: recorededAudioURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Couldn't load file for playback: \(error.localizedDescription)")
        }
    }

    func deletePhoto(at fileURL: URL) {
        do {
            try FileManager.default.removeItem(at: fileURL)
            print("Photo deleted at: \(fileURL)")
        } catch {
            print("Error deleting photo: \(error.localizedDescription)")
        }
    }

    //    func uploadImageToServer(imageURL: URL, completion: @escaping (Result<Void, Error>) -> Void) {
    //        guard let imageData = try? Data(contentsOf: imageURL) else {
    //            print("Error: Could not convert image to data.")
    //            return
    //        }
    //        let uploadURL = URL(string: "https://yourserver.com/upload")!
    //        var request = URLRequest(url: uploadURL)
    //        request.httpMethod = "POST"
    //        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
    //        let task = URLSession.shared.uploadTask(with: request, from: imageData) { data, response, error in
    //            if let error = error {
    //                print("Upload failed: \(error.localizedDescription)")
    //                completion(.failure(error))
    //                return
    //            }
    //            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
    //                print("Image uploaded successfully.")
    //                self.deletePhoto(at: imageURL)
    //                completion(.success(()))
    //            } else {
    //                print("Upload failed with response: \(response.debugDescription)")
    //                completion(.failure(NSError(domain: "UploadError", code: httpResponse.statusCode, userInfo: nil)))
    //            }
    //        }
    //        task.resume()
    //    }

    func loadPhoto() -> [URL] {
        guard let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            print("Error: Couldn't find documents directory")
            return []
        }
        do {
            let items = try FileManager.default.contentsOfDirectory(
                at: documentsDirectory,
                includingPropertiesForKeys: nil
            )
            let photoFiles = items.filter { $0.pathExtension == "jpg" }
            return photoFiles
        } catch {
            print("Error loading photo files: \(error.localizedDescription)")
            return []
        }
    }
}
