import SwiftUI
// ローディング画面
struct LoadingView: View {
    @State var currentDegress = 0.0
    let colorGradient = LinearGradient(
        gradient: Gradient(
            colors: [
                .mint,
                .mint.opacity(0.75),
                .mint.opacity(0.5),
                .mint.opacity(0.25),
                .clear
            ]),
            startPoint: /*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/,
            endPoint: .trailing
    )
    var body: some View {
        Circle()
            .trim(from: 0.0, to: 0.85)
            .stroke(colorGradient, style: StrokeStyle(lineWidth: 5))
            .frame(width: 80, height: 80)
            .rotationEffect(Angle(degrees: currentDegress))
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                    withAnimation {
                        self.currentDegress += 10
                    }
                }
            }
    }
}

#Preview {
    LoadingView()
}
