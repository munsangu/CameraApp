import SwiftUI
// 録音ボタン
struct AudioButton: View {
    var isAudioRecording: Bool
    var isButtonTapped: () -> Void
    var body: some View {
        VStack {
            if !isAudioRecording {
                Button {
                   isButtonTapped()
                } label: {
                    RecordCircleButton()
                }
                .padding(.bottom, 60)
            } else {
                Button {
                    isButtonTapped()
                } label: {
                    StopRectangleButton()
                }
                .padding(.bottom, 60)
            }
        }
    }
}

#Preview {
    AudioButton(isAudioRecording: true) {
        print("Button Tapped!")
    }
}
