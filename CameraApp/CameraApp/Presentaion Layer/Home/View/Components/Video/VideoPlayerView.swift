import SwiftUI
import AVKit
// 録画したビデオ再生時に見える画面
struct VideoPlayerView: UIViewControllerRepresentable {
    @Binding var videoURL: URL
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerViewController = AVPlayerViewController()
        updatePlayer(for: playerViewController, with: videoURL)
        return playerViewController
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        updatePlayer(for: uiViewController, with: videoURL)
    }
    private func updatePlayer(for controller: AVPlayerViewController, with videoURL: URL) {
        let refreshedURL = URL(string: "\(videoURL.absoluteString)?t=\(NSDate().timeIntervalSince1970)")
        let player = AVPlayer(url: refreshedURL!)
        controller.player = player
    }
}
