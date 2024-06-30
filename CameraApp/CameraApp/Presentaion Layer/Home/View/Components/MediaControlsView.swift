import SwiftUI

struct MediaControlsView: View {
    @Binding var mediaSelectedMode: HomeViewModel.MediaMode
    @ObservedObject var homeViewModel: HomeViewModel
    let mediaModes: [(title: String, mediaMode: HomeViewModel.MediaMode)]
    var body: some View {
        VStack {
            Spacer()
            HStack {
                VStack(alignment: .center) {
                    if !homeViewModel.isTakenPhoto &&
                        !homeViewModel.isAudioRecording &&
                        !homeViewModel.isVideoRecording {
                        HStack {
                            Spacer()
                            ForEach(mediaModes, id: \.mediaMode) { mode in
                                ModeButton(
                                    buttonTitle: mode.title,
                                    textColor: mediaSelectedMode == mode.mediaMode ? .yellow : .white
                                ) {
                                    mediaSelectedMode = mode.mediaMode
                                }
                                Spacer()
                            }
                        }
                        .padding(20)
                    } else {
                        HStack {
                            Spacer()
                        }
                    }
                    switch mediaSelectedMode {
                    case .video:
                        if homeViewModel.isVideoRecording {
                            HStack {
                                Text("00 : \(String(format: "%02d", homeViewModel.videoRecordingTime))")
                                Text("/")
                                    .padding(.horizontal, 20)
                                Text("00 : 30")
                            }
                            .padding(15)
                        }
                        VideoButton(isVideoRecording: homeViewModel.isVideoRecording) {
                            homeViewModel.isVideoButtonTapped()
                        }
                    case .photo:
                        CaptureButton(
                            isTakenPhoto: homeViewModel.isTakenPhoto,
                            firstPhotoURL: homeViewModel.savedPhotoURL.first,
                            takePhoto: {
                                homeViewModel.isCaptureButtonTapped()
                            },
                            deletePhoto: {
                                if let firstPhotoURL = homeViewModel.savedPhotoURL.first {
                                    homeViewModel.isDeleteButtonTapped(at: firstPhotoURL)
                                    homeViewModel.isTakenPhoto = false
                                    homeViewModel.isPhotoURLSet = false
                                }
                            },
                            retakePhoto: {
                                homeViewModel.isRetakeButtonTapped()
                            },
                            showCapturedDetailView: {
                                homeViewModel.showCapturedDetailView = true
                            }
                        )
                    case .audio:
                        if homeViewModel.isAudioRecording {
                            HStack {
                                Text("00 : \(String(format: "%02d", homeViewModel.recodingTime))")
                                Text("/")
                                    .padding(.horizontal, 20)
                                Text("00 : 30")
                            }
                            .padding(15)
                        }
                        AudioButton(isAudioRecording: homeViewModel.isAudioRecording) {
                            homeViewModel.isAudioButtonTapped()
                        }
                    }
                }
                .conditionalBackground(condition: mediaSelectedMode == .photo)
            }
            .frame(height: 110)
        }
    }
}
