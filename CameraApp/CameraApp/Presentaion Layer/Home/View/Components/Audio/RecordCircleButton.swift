import SwiftUI
// 録音ボタン(基本)
struct RecordCircleButton: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(.red)
                .frame(width: 60, height: 60)
            Circle()
                .stroke(.white, lineWidth: 4)
                .background(.clear)
                .frame(width: 70, height: 70)
        } //: ZSTACK
    }
}

#Preview {
    RecordCircleButton()
}
