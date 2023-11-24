import AVFoundation
import SwiftUI

// struct CameraView: UIViewControllerRepresentable {
//    @ObservedObject var cameraManager: PhotoCameraManager
//
//    func makeUIViewController(context: Context) -> some UIViewController {
//        let viewController = UIViewController()
//        let previewLayer = AVCaptureVideoPreviewLayer(session: cameraManager.session)
//        previewLayer.frame = UIScreen.main.bounds
//        previewLayer.videoGravity = .resizeAspectFill
//        viewController.view.layer.addSublayer(previewLayer)
//        cameraManager.startSession()
//        return viewController
//    }
//
//    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
//        // Update view controller if needed
//    }
// }

struct CameraView: UIViewControllerRepresentable {
    @ObservedObject var cameraManager: MLPhotoCameraManager

    func makeUIViewController(context: Context) -> some UIViewController {
        let viewController = UIViewController()
        let previewLayer = AVCaptureVideoPreviewLayer(session: cameraManager.session)
        previewLayer.frame = UIScreen.main.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)
        cameraManager.startSession()
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // Update view controller if needed
    }
}
