import Foundation

extension HomeViewModel {
    func isCaptureButtonTapped() {
        cameraUseCase.takePhoto { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let camera):
                    self.isTakenPhoto = true
                    self.isPhotoSaved = true
                    self.isPhotoURLSet = true
                    self.photoData = camera.phtoData
                    self.savedPhotoURL.insert(camera.photoURL, at: 0)
                case .failure(let error):
                    print("Failed to capture photo: \(error.localizedDescription)")
                }
            }
        }
    }

    func isRetakeButtonTapped() {
        cameraUseCase.retakePhoto()
        DispatchQueue.main.async {
            self.isTakenPhoto = false
            self.isPhotoSaved = false
            self.isPhotoURLSet = false
            self.photoData = Data()
        }
    }

    func isSaveButtonTapped(_ camera: Camera) {
        cameraUseCase.savePhoto(camera)
    }

    func loadPhotoInHomeView() {
        savedPhotoURL = cameraUseCase.loadPhoto()
    }

    func isDeleteButtonTapped(at fileURL: URL) {
        cameraUseCase.deletePhoto(at: fileURL)
        DispatchQueue.main.async {
            self.isTakenPhoto = false
            self.isPhotoURLSet = false
            self.savedPhotoURL.removeAll { $0 == fileURL }
        }
    }
}
