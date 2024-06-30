import SwiftUI
// カメラ撮影ボタン
struct CaptureButton: View {
    var isTakenPhoto: Bool
    var firstPhotoURL: URL?
    var takePhoto: () -> Void
    var deletePhoto: () -> Void
    var retakePhoto: () -> Void
    var showCapturedDetailView: () -> Void
    var body: some View {
        HStack {
            if isTakenPhoto {
                Button {
                    print("Delete photo button pressed")
                    deletePhoto()
                    retakePhoto()
                } label: {
                    Image(systemName: "trash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundStyle(.white)
                }
                .padding(.leading, 30)
                Spacer()
                Button {
                    print("Retake photo button pressed")
                    retakePhoto()
                } label: {
                    Image(systemName: "camera.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                        .foregroundStyle(.white)
                }
                Spacer()
                Button {
                    print("Delete2 photo button pressed")
                    deletePhoto()
                    retakePhoto()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundStyle(.white)
                }
                .padding(.trailing, 30)
            } else {
                HStack {
                    if let firstPhotoURL = firstPhotoURL {
                        Button {
                            print("Show captured detail view button pressed")
                            showCapturedDetailView()
                        } label: {
                            Image(uiImage: UIImage(contentsOfFile: firstPhotoURL.path(percentEncoded: false))
                                  ?? UIImage()
                            )
                                .resizable()
                                .scaleEffect(CGSize(width: 0.8, height: 0.8))
                                .frame(width: 70, height: 70)
                                .padding(.leading, 15)
                        }
                    } else {
                        Rectangle()
                            .frame(width: 70, height: 70)
                            .foregroundStyle(.black)
                            .padding(.leading, 15)
                    }
                    Button {
                        takePhoto()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(.white)
                                .frame(width: 64, height: 64)
                            Circle()
                                .stroke(.white, lineWidth: 1)
                                .background(.clear)
                                .frame(width: 70, height: 70)
                        }
                    }
                    .padding(.leading, 58)
                    Spacer()
                }
            }
        }
        .padding(.bottom, 60)
    }
}
