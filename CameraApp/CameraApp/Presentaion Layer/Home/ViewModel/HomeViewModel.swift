import SwiftUI
import AVFoundation

class HomeViewModel: ObservableObject {
    enum MediaMode {
        case video
        case photo
        case audio
    }
    @Published var selectedMode: MediaMode = .photo
    var cameraUseCase: CameraUseCase
    var audioUseCase: AudioUseCase
    var videoUseCase: VideoUseCase
    var permissionManager: PermissionManager
    // カメラ
    @Published var isTakenPhoto = false
    @Published var isPhotoURLSet = false
    @Published var isPhotoSaved = false
    @Published var showCapturedDetailView = false
    @Published var photoData: Data = Data()
    @Published var savedPhotoURL: [URL] = []
    // オ-ディオ
    @Published var isAudioRecording = false
    @Published var recorededAudioURL: URL?
    @Published var recodingTime = 0
    @Published var isAudioSaved = false
    // ビデオ
    @Published var isVideoRecording = false
    @Published var showVideoRecordedView = false
    @Published var recordedVideoURL: URL?
    @Published var videoRecordingTime = 0
    init() {
        self.cameraUseCase = MediaRepository.shared
        self.audioUseCase = MediaRepository.shared
        self.videoUseCase = MediaRepository.shared
        self.permissionManager = PermissionManager()
    }

    func checkPermissionsOnLaunch() {
        permissionManager.checkCameraPermission { granted in
            if granted {
                self.cameraUseCase.setupSession()
            }
        }
        permissionManager.checkAudioPermission { granted in
            if granted {
                self.audioUseCase.setupAudioSession()
            }
        }
    }

    func setupSessionForPhotoMode() {
        cameraUseCase.setupSession()
    }

    func terminateCameraSessionForAudioMode() {
        cameraUseCase.terminateCameraSession()
    }

    func setupAudioSessionForAudioMode() {
        audioUseCase.setupAudioSession()
    }

    func terminateAudioSessionForPhotoMode(completion: @escaping () -> Void) {
        audioUseCase.terminateAudioSession(completion: completion)
    }

    func handleDragGesture(_ gesture: DragGesture.Value) {
        if gesture.translation.width < 0 {
            switch selectedMode {
            case .video:
                selectedMode = .photo
            case .photo:
                selectedMode = .audio
            case .audio:
                break
            }
        } else if gesture.translation.width > 0 {
            switch selectedMode {
            case .video:
                break
            case .photo:
                selectedMode = .video
            case .audio:
                selectedMode = .photo
            }
        }
    }

    func modeChanged(to newMode: MediaMode) {
        switch newMode {
        case .photo:
            terminateAudioSessionForPhotoMode {
                DispatchQueue.main.async {
                    self.setupSessionForPhotoMode()
                }
            }
        case .audio:
            terminateCameraSessionForAudioMode()
            setupAudioSessionForAudioMode()
        case .video:
            break
        }
    }
}
