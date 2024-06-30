import Foundation
import AVFoundation

protocol CameraUseCase {
    var session: AVCaptureSession { get }
    // カメラセッションを設定
    func setupSession()
    // カメラセッションを終了
    func terminateCameraSession()
    // 写真を撮る
    func takePhoto(completion: @escaping (Result<Camera, Error>) -> Void)
    // 写真を再撮影
    func retakePhoto()
    // 写真を保存
    func savePhoto(_ photo: Camera)
    // ファイルURLの写真を削除
    func deletePhoto(at fileURL: URL)
    // サーバーに画像をアップロード
    //    func uploadImageToServer(imageURL: URL, completion: @escaping (Result<Void, Error>) -> Void)
    // 写真を読み込む
    func loadPhoto() -> [URL]
}
