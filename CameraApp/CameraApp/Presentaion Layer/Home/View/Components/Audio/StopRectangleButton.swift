import SwiftUI
// 録音ボタン(録音中)
struct StopRectangleButton: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.gray)
                .frame(width: 45, height: 45)
            Circle()
                .stroke(.white, lineWidth: 4)
                .background(.clear)
                .frame(width: 70, height: 70)
        } //: ZSTACK
    }
}

#Preview {
    StopRectangleButton()
}
