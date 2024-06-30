import Foundation

extension HomeViewModel {
    func isVideoStartButtonTapped() {
        videoUseCase.startVideoRecording(updateTime: { time in
            DispatchQueue.main.async {
                self.videoRecordingTime = time
                if time >=  29 {
                    self.isVideoStopButtonTapped()
                }
            }
        }, completion: { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let videoURL):
                    self.recordedVideoURL = videoURL
                    self.showVideoRecordedView = true
                    self.isVideoRecording = false
                case .failure(let error):
                    print("Failed to record video: \(error.localizedDescription)")
                    self.isVideoRecording = false
                }
            }
        })
        isVideoRecording = true
    }

    func isVideoStopButtonTapped() {
        videoUseCase.stopVideoRecording()
        isVideoRecording = false
        videoRecordingTime = 0
    }

    func isVideoButtonTapped() {
        if self.isVideoRecording {
            self.isVideoStopButtonTapped()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showVideoRecordedView = true
            }
        } else {
            self.isVideoStartButtonTapped()
        }
    }
}
