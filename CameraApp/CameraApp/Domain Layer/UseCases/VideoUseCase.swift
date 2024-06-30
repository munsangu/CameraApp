import Foundation
import AVFoundation

protocol VideoUseCase {
    // ビデオ録画を開始
    func startVideoRecording(
        updateTime: @escaping (Int) -> Void,
        completion: @escaping (Result<URL, Error>) -> Void
    )
    // ビデオ録画を停止
    func stopVideoRecording()
}
