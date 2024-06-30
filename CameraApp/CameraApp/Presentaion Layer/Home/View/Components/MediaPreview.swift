import SwiftUI

struct MediaPreview: View {
    @Binding var mediaSelectedMode: HomeViewModel.MediaMode
    let setupPreviewLayer: (UIView) -> Void
    let handlePinchToZoom: (UIPinchGestureRecognizer) -> Void
    var body: some View {
        switch mediaSelectedMode {
        case .photo, .video:
            CameraPreview(
                setupPreviewLayer: setupPreviewLayer,
                handlePinchToZoom: handlePinchToZoom
            )
            .ignoresSafeArea(.all, edges: [.bottom, .leading, .trailing])
        case .audio:
            AudioPreview()
            .ignoresSafeArea(.all, edges: [.bottom, .leading, .trailing])
        }
    }
}
