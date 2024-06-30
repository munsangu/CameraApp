import SwiftUI

extension View {
    // ビデオ、写真、録音によるボタン注意背景色変化管理関数
    func conditionalBackground(condition: Bool) -> some View {
        self.modifier(ConditionalBackgroundModifier(condition: condition))
    }
}
