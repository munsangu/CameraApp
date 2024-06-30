import Foundation

protocol AudioUseCase {
    // オーディオ録音を開始
    func startAudioRecording(
        updateTime: @escaping (Int) -> Void,
        completion: @escaping (Result<URL, Error>) -> Void
    )
    // オーディオ録音を停止
    func stopAudioRecording()
    // オーディオセッションを設定
    func setupAudioSession()
    // オーディオセッションを終了
    func terminateAudioSession(completion: @escaping () -> Void)
    // 録音したオーディオを再生
    func playAudioRecording()
}
