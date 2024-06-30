import Foundation

extension HomeViewModel {
    func isAudioRecordingStartButtonTapped() {
        audioUseCase.startAudioRecording(updateTime: { time in
            self.recodingTime = time
        }, completion: { result in
            switch result {
            case .success(let audioURL):
                self.recorededAudioURL = audioURL
                self.isAudioSaved = true
                self.isAudioRecording = false
            case .failure(let error):
                print("Failed to record audio: \(error.localizedDescription)")
                self.isAudioRecording = false
            }
        })
        isAudioRecording = true
        recodingTime = 0
    }

    func isAudioRecordingStopButtonTapped() {
        audioUseCase.stopAudioRecording()
        isAudioRecording = false
        isAudioSaved = true
        recodingTime = 0
    }

    func playAudioRecordingInPreview() {
        audioUseCase.playAudioRecording()
    }

    func isAudioButtonTapped() {
        if !self.isAudioRecording {
            self.isAudioRecordingStartButtonTapped()
        } else {
            self.isAudioRecordingStopButtonTapped()
        }
    }
}
