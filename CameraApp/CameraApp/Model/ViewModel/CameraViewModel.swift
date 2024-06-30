import AVFoundation
import SwiftUI

class CameraViewModel: NSObject, ObservableObject {
    @Published var isTakenPhoto = false
    @Published var cameraSession = AVCaptureSession()
    @Published var cameraSettingAlert = false
    @Published var cameraOutput = AVCapturePhotoOutput()
    @Published var cameraPreview: AVCaptureVideoPreviewLayer!
    @Published var isSaved = false
    @Published var photoData = Data(count: 0)
    @Published var isPhotoURLSet = false
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
            return
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { status in
                if status {
                    self.setupCamera()
                }
            }
        case .denied:
            self.cameraSettingAlert.toggle()
            return
        default:
            return
        }
    }

    func setupCamera() {
        do {
            self.cameraSession.beginConfiguration()

            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
            let input = try AVCaptureDeviceInput(device: device!)
            if self.cameraSession.canAddInput(input) {
                self.cameraSession.addInput(input)
            }

            if self.cameraSession.canAddOutput(self.cameraOutput) {
                self.cameraSession.addOutput(self.cameraOutput)
            }
            self.cameraSession.commitConfiguration()
            self.cameraSession.startRunning()
        } catch {
            print(error.localizedDescription)
        }
    }

    func takePhoto() {
        DispatchQueue.global(qos: .userInteractive).async {
            self.cameraOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            DispatchQueue.main.async {
                withAnimation {
                    self.isTakenPhoto = true
                }
            }
        }
    }

    func reTakePhoto() {
        DispatchQueue.global(qos: .utility).async {
            self.cameraSession.startRunning()
            DispatchQueue.main.async {
                withAnimation {
                    self.isTakenPhoto.toggle()
                }
                self.isSaved = false
            }
        }
    }

    func savePhoto() {
        guard !photoData.isEmpty else {
            print("Error: No photo data to save")
            return
        }
        guard let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first
        else {
            print("Error: Couldn't find document directory")
            return
        }
        let fileName = "tempPhoto.jpg"
        let fileURL = documentsDirectory.appending(path: fileName)
        print("FileURL: \(fileURL)")
        do {
            try photoData.write(to: fileURL)
            DispatchQueue.main.async {
                self.isSaved = true
            }
            print("Saved successfully")
        } catch {
            print("Error saving photo: \(error.localizedDescription)")
        }
    }

    func loadPhoto() -> [URL] {
        guard let documentsDirectiory = FileManager.default.urls(
            for: .documentDirectory,
            in: .allDomainsMask
        ).first
        else {
            print("Error: Couldn't find documents directory")
            return []
        }
        do {
            let items = try FileManager.default.contentsOfDirectory(
                at: documentsDirectiory,
                includingPropertiesForKeys: nil
            )
            let photoFiles = items.filter { $0.pathExtension == "jpg" }
            DispatchQueue.main.async {
                self.isPhotoURLSet = true
            }
            return photoFiles
        } catch {
            print("Error loading photo files: \(error.localizedDescription)")
            return []
        }
    }

    func deletePhoto(at fileURL: URL) {
        do {
            try FileManager.default.removeItem(at: fileURL)
            DispatchQueue.main.async {
                self.isPhotoURLSet = false
            }
            print("Photo deleted successfully: \(fileURL)")
        } catch {
            print("Error deleting photo: \(error.localizedDescription)")
        }
    }
}

extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        self.cameraSession.stopRunning()
        if let error = error {
            print("Error capturing photo: \(error.localizedDescription)")
            return
        }
        guard let imageData = photo.fileDataRepresentation() else {
            print("Couldn't obtain photo data.")
            return
        }
        print("ImageData: \(imageData)")
        DispatchQueue.main.async {
            self.photoData = imageData
            print("Photo captured successfully.")
            self.savePhoto()
        }
    }
    // Camera Shutter sound Off
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings
    ) {
        AudioServicesDisposeSystemSoundID(1108)
    }
    // Camera Shutter sound Off
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings
    ) {
        AudioServicesDisposeSystemSoundID(1108)
    }
}
