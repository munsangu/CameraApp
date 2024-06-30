import SwiftUI
// // ビデオ、写真、録音によるボタン注意背景色変化管理関数
struct ConditionalBackgroundModifier: ViewModifier {
    var condition: Bool
    func body(content: Content) -> some View {
        content
            .background(condition ? .black : .gray.opacity(0.3))
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.2), value: condition)
    }
}
