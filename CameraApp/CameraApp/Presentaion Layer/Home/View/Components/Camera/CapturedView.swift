import SwiftUI
// 撮影した写真を見るときに出てくる画面
struct CapturedView: View {
    let photoURL: URL?
    let deletePhoto: () -> Void
    let retakePhoto: () -> Void
    let dismiss: () -> Void

    var body: some View {
        VStack {
            if let photoURL = photoURL {
                Image(uiImage: UIImage(contentsOfFile: photoURL.path(percentEncoded: false)) ?? UIImage())
                    .resizable()
                    .scaledToFit()
                HStack {
                    Button {
                        deletePhoto()
                        retakePhoto()
                    } label: {
                        Image(systemName: "trash")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 30)
                    Spacer()
                    Button(action: dismiss) {
                        Image(systemName: "camera.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Button {
                        deletePhoto()
                        retakePhoto()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                    }
                    .padding(.trailing, 30)
                }
            } else {
                Text("No photo available")
                    .foregroundColor(.white)
                    .padding()
            }
        }
    }
}
