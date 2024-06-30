import Foundation
import AVFoundation

extension MediaRepository: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("Recording was not successful.")
        }
    }
}
