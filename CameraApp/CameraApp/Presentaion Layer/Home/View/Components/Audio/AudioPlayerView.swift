import SwiftUI
// 録音ファイルの再生時に表示される画面
struct AudioPlayerView: View {
    let stopAudioRecording: () -> Void
    let dismiss: () -> Void

    var body: some View {
        VStack {
            LoadingView()
                .padding(50)
            Button {
                stopAudioRecording()
                dismiss()
            } label: {
                Text("Close")
            }
            .padding(10)
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}
