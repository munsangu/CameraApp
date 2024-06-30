import SwiftUI
// iPhoneの基本カメラデザインを参考にして作ったもの
struct ModeButton: View {
    let buttonTitle: String
    var textColor: Color
    var isButtonTapped: () -> Void
    var body: some View {
        Button {
            isButtonTapped()
        } label: {
            Text(buttonTitle)
                .font(.system(size: 14))
                .foregroundColor(textColor)
        }
    }
}
