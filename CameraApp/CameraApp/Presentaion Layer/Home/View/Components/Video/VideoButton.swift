import SwiftUI
// ビデオ録画ボタン
struct VideoButton: View {
    var isVideoRecording: Bool
    var isButtonTapped: () -> Void
    var body: some View {
        Button {
            if isVideoRecording {
                isButtonTapped()
            } else {
                isButtonTapped()
            }
        } label: {
            ZStack {
                if isVideoRecording {
                    StopRectangleButton()
                } else {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 60, height: 60)
                    Circle()
                        .stroke(Color.white, lineWidth: 5)
                        .background(Color.clear)
                        .frame(width: 70, height: 70)
                }
            }
        }
        .padding(.bottom, 60)
    }
}
