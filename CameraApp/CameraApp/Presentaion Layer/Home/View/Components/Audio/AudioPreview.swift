import SwiftUI
import AVFoundation
// 録音モードに切り替えたときに表示される画面
struct AudioPreview: View {
    var body: some View {
        Image(systemName: "music.note")
            .resizable()
            .scaledToFit()
            .frame(width: 200, height: 200)
            .foregroundStyle(.white)
            .offset(y: -80)
    }
}
