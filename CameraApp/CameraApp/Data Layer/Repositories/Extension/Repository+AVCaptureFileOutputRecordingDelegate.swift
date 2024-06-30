import Foundation
import AVFoundation

extension MediaRepository: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(
        _ output: AVCaptureFileOutput,
        didFinishRecordingTo outputFileURL: URL,
        from connections: [AVCaptureConnection],
        error: (any Error)?) {
            DispatchQueue.main.async {
                if let error = error {
                    self.videoCompletion?(.failure(error))
                } else {
                    self.videoCompletion?(.success(outputFileURL))
                }
            }
        }
}
