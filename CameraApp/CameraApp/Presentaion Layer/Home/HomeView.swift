import SwiftUI
import AVFoundation
// メーン
struct HomeView: View {
    @ObservedObject var homeViewModel = HomeViewModel()
    @State private var mediaSelectedMode: HomeViewModel.MediaMode = .photo
    @State private var previewLayer: AVCaptureVideoPreviewLayer?
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .local)
            .onEnded { gesture in
                homeViewModel.handleDragGesture(gesture)
            }
    }
    private let mediaModes: [(title: String, mediaMode: HomeViewModel.MediaMode)] = [
        ("動画", .video),
        ("写真", .photo),
        ("録音", .audio)
    ]
    init() {
        self.homeViewModel = HomeViewModel()
    }
    var body: some View {
        ZStack {
            MediaPreview(mediaSelectedMode: $mediaSelectedMode, setupPreviewLayer: setupPreviewLayer, handlePinchToZoom: handlePinchToZoom)
            MediaControlsView(mediaSelectedMode: $mediaSelectedMode, homeViewModel: homeViewModel, mediaModes: mediaModes)
        }
        .gesture(dragGesture)
        .onChange(of: mediaSelectedMode) { newMode in
            homeViewModel.modeChanged(to: newMode)
            homeViewModel.selectedMode = newMode
        }
        .onChange(of: homeViewModel.selectedMode) { newMode in
            mediaSelectedMode = newMode
        }
        .onAppear {
            self.homeViewModel.checkPermissionsOnLaunch()
            self.mediaSelectedMode = homeViewModel.selectedMode
        }
        .onChange(of: homeViewModel.recordedVideoURL) { newURL in
            if newURL != nil {
                homeViewModel.showVideoRecordedView = true
            }
        }
        .fullScreenCover(isPresented: $homeViewModel.showVideoRecordedView) {
            if let videoURL = homeViewModel.recordedVideoURL {
                VideoPlayerView(videoURL: .constant(videoURL))
            }
        }
        .fullScreenCover(isPresented: $homeViewModel.showCapturedDetailView) {
            CapturedView(
                photoURL: homeViewModel.savedPhotoURL.first,
                deletePhoto: {
                    if let firstPhotoURL = homeViewModel.savedPhotoURL.first {
                        homeViewModel.isDeleteButtonTapped(at: firstPhotoURL)
                        homeViewModel.isPhotoURLSet = false
                        homeViewModel.showCapturedDetailView = false
                    }
                },
                retakePhoto: {
                    homeViewModel.setupSessionForPhotoMode()
                },
                dismiss: {
                    homeViewModel.showCapturedDetailView = false
                }
            )
        }
        .fullScreenCover(isPresented: $homeViewModel.isAudioSaved) {
            if homeViewModel.recorededAudioURL != nil {
                AudioPlayerView(
                    stopAudioRecording: {
                        homeViewModel.isAudioRecordingStopButtonTapped()
                    },
                    dismiss: {
                        homeViewModel.isAudioSaved = false
                    }
                )
                .onAppear {
                    homeViewModel.playAudioRecordingInPreview()
                }
            }
        }
    }

    func setupPreviewLayer(for view: UIView) {
        let previewLayer = AVCaptureVideoPreviewLayer(session: homeViewModel.cameraUseCase.session)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer
    }

    func handlePinchToZoom(_ gesture: UIPinchGestureRecognizer) {
        guard let device = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back
        ) else {
            return
        }
        if gesture.state == .changed {
            let maxZoomFactor = device.activeFormat.videoMaxZoomFactor
            do {
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }
                var newZoomFactor = device.videoZoomFactor * gesture.scale
                newZoomFactor = min(maxZoomFactor, newZoomFactor)
                newZoomFactor = max(1.0, newZoomFactor)
                device.videoZoomFactor = newZoomFactor
                gesture.scale = 1.0
            } catch {
                print("Error locking configuration: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    HomeView()
}
