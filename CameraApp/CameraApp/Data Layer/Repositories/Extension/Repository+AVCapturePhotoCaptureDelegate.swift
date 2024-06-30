import Foundation
import AVFoundation

extension MediaRepository: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        self.session.stopRunning()
        if let error = error {
            photoCompletion?(.failure(error))
            return
        }
        guard let imageData = photo.fileDataRepresentation() else {
            let error = NSError(
                domain: "CaptureError",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Couldn't obtain photo data."]
            )
            photoCompletion?(.failure(error))
            return
        }
        DispatchQueue.main.async {
            guard let documentsDirectory = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first else {
                let error = NSError(
                    domain: "CaptureError",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Couldn't find document directory."]
                )
                self.photoCompletion?(.failure(error))
                return
            }
            let fileName = "tempPhoto.jpg"
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            let photoEntity = Camera(phtoData: imageData, photoURL: fileURL)
            self.savePhoto(photoEntity)
            self.photoCompletion?(.success(photoEntity))
        }
    }

    func photoOutput(
        _ output: AVCapturePhotoOutput,
        willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings
    ) {
        AudioServicesDisposeSystemSoundID(1108)
    }

    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings
    ) {
        AudioServicesDisposeSystemSoundID(1108)
    }
}
