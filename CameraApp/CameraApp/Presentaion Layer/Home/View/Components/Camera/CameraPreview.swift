import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    let setupPreviewLayer: (UIView) -> Void
    let handlePinchToZoom: (UIPinchGestureRecognizer) -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        setupPreview(for: view)
        addPinchGesture(to: view, context: context)
        return view
    }

    private func setupPreview(for view: UIView) {
        DispatchQueue.main.async {
            self.setupPreviewLayer(view)
        }
    }

    private func addPinchGesture(to view: UIView, context: Context) {
        let pinch = UIPinchGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.pinchToZoom(_:))
        )
        view.addGestureRecognizer(pinch)
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(handlePinchToZoom: handlePinchToZoom)
    }

    class Coordinator: NSObject {
        let handlePinchToZoom: (UIPinchGestureRecognizer) -> Void

        init(handlePinchToZoom: @escaping (UIPinchGestureRecognizer) -> Void) {
            self.handlePinchToZoom = handlePinchToZoom
        }

        @objc func pinchToZoom(_ gesture: UIPinchGestureRecognizer) {
            handlePinchToZoom(gesture)
        }
    }
}
