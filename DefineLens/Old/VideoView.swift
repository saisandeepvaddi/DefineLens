//
//  VideoView.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/23/23.
//

import AVFoundation
import SwiftUI

// struct VideoView: UIViewControllerRepresentable {
//    var cameraManager = VideoCameraManager()
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

// struct VideoView: UIViewRepresentable {
//    @ObservedObject var videoManager: VideoCameraManager
//
//    func makeUIView(context: Context) -> UIView {
//        let view = UIView(frame: .zero)
//
//        let layer = AVCaptureVideoPreviewLayer(session: videoManager.session)
//        layer.videoGravity = .resizeAspectFill
//        view.layer.addSublayer(layer)
////        videoManager.startSession()
//
//        return view
//    }
//
//    func updateUIView(_ uiView: UIView, context: Context) {
//        guard let layer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer else { return }
//        layer.frame = uiView.bounds
//    }
// }

// func transformBoundingBox(box: CGRect, fromVideoSize videoSize: CGSize, toViewSize viewSize: CGSize) -> CGRect {
//    let videoAspectRatio = videoSize.width / videoSize.height
//    let viewAspectRatio = viewSize.width / viewSize.height
//
//    var scale: CGFloat
//    var xOffset: CGFloat = 0.0
//    var yOffset: CGFloat = 0.0
//
//    if viewAspectRatio > videoAspectRatio {
//        // Video is taller than view
//        scale = viewSize.width / videoSize.width
//        yOffset = (viewSize.height - (videoSize.height * scale)) / 2
//    } else {
//        // Video is wider than view
//        scale = viewSize.height / videoSize.height
//        xOffset = (viewSize.width - (videoSize.width * scale)) / 2
//    }
//
//    var transformedBox = box
//    transformedBox.origin.x = box.origin.x * scale + xOffset
//    transformedBox.origin.y = box.origin.y * scale + yOffset
//    transformedBox.size.width *= scale
//    transformedBox.size.height *= scale
//
//    return transformedBox
// }

// func transformBoundingBox(_ box: CGRect, fromVideoSize videoSize: CGSize, toViewSize viewSize: CGSize) -> CGRect {
//    // Convert the normalized bounding box (0...1) to the video frame's coordinate system
//    let videoBox = CGRect(x: box.origin.x * videoSize.width,
//                          y: box.origin.y * videoSize.height,
//                          width: box.size.width * videoSize.width,
//                          height: box.size.height * videoSize.height)
//
//    // Calculate the scaling factors for width and height
//    let widthScale = viewSize.width / videoSize.width
//    let heightScale = viewSize.height / videoSize.height
//
//    // Scale the bounding box to the view size
//    let scaledBox = CGRect(x: videoBox.origin.x * widthScale,
//                           y: videoBox.origin.y * heightScale,
//                           width: videoBox.size.width * widthScale,
//                           height: videoBox.size.height * heightScale)
//
//
//    let transformY = viewSize.height - scaledBox.origin.y - scaledBox.size.height
//
//    return CGRect(x: scaledBox.origin.x,
//                  y: transformY,
//                  width: scaledBox.size.width,
//                  height: scaledBox.size.height)
// }

// private func transformBoundingBox(_ box: CGRect, fromVideoSize videoSize: CGSize, toViewSize viewSize: CGSize) -> CGRect {
//    // Normalize bounding box to video frame coordinates
//    let normalizedBox = CGRect(x: box.origin.x * videoSize.width,
//                               y: box.origin.y * videoSize.height,
//                               width: box.size.width * videoSize.width,
//                               height: box.size.height * videoSize.height)
//
//    // Scale the bounding box to the view size
//    // Since the video is in portrait .right, the videoSize's width and height are swapped
//    let widthScale = viewSize.width / videoSize.height
//    let heightScale = viewSize.height / videoSize.width
//
//    let scaledBox = CGRect(x: normalizedBox.origin.x * widthScale,
//                           y: normalizedBox.origin.y * heightScale,
//                           width: normalizedBox.width * widthScale,
//                           height: normalizedBox.height * heightScale)
//
//    // Vision framework's coordinate system starts from the bottom left corner
//    // and UIKit's from the top left corner, so we need to transform the y-coordinate.
//    let transformY = viewSize.height - scaledBox.origin.y - scaledBox.size.height
//
//    return CGRect(x: scaledBox.origin.x,
//                  y: transformY,
//                  width: scaledBox.size.width,
//                  height: scaledBox.size.height)
// }

// struct VideoView: UIViewControllerRepresentable {
//    @ObservedObject var cameraManager: VideoCameraManager
//
//    func makeUIViewController(context: Context) -> some UIViewController {
//        let viewController = UIViewController()
//        let previewLayer = AVCaptureVideoPreviewLayer(session: cameraManager.session)
//        previewLayer.frame = UIScreen.main.bounds
//        previewLayer.videoGravity = .resizeAspectFill
//        viewController.view.layer.addSublayer(previewLayer)
//
//        return viewController
//    }
//
//    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
//        // Update view controller if needed
//        guard let uiView = uiViewController.view else {
//            return
//        }
//
//        guard let layer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer else { return }
////        layer.frame = uiView.bounds
//        layer.frame = uiView.bounds
////        print("UIView: \(uiView.bounds.size)")
//        uiView.layer.sublayers?.removeSubrange(1...)
//        for box in cameraManager.boundingBoxes {
//            let transformedBox = transformBoundingBox(box: box, fromVideoSize: cameraManager.videoSize, toViewSize: uiView.bounds.size)
////            let transformedBox = convertBoundingBoxCoordinates(boundingBox: box, to: CGRect(origin: .zero, size: uiView.bounds.size))
//            let rectangleLayer = CAShapeLayer()
//            rectangleLayer.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
//            rectangleLayer.borderColor = UIColor.red.cgColor
//            rectangleLayer.borderWidth = 2
//            uiView.layer.addSublayer(rectangleLayer)
//        }
//    }
// }

private func transformBoundingBox(_ box: CGRect, fromVideoSize videoSize: CGSize, toViewSize viewSize: CGSize) -> CGRect {
    // Normalize bounding box to video frame coordinates
    let normalizedBox = CGRect(x: box.origin.x * videoSize.width,
                               y: box.origin.y * videoSize.height,
                               width: box.size.width * videoSize.width,
                               height: box.size.height * videoSize.height)

    // The Vision coordinates are based on a landscape orientation. Since the video is in portrait .right,
    // the height and width are effectively swapped.
    let widthScale = viewSize.width / videoSize.height
    let heightScale = viewSize.height / videoSize.width

    // Vision's y-coordinate is from the bottom, UIKit's y-coordinate is from the top
    let transformedY = videoSize.height - (normalizedBox.origin.y + normalizedBox.height)

    let scaledBox = CGRect(x: normalizedBox.origin.x * widthScale,
                           y: transformedY * heightScale,
                           width: normalizedBox.width * widthScale,
                           height: normalizedBox.height * heightScale)

    return scaledBox
}

struct VideoView: UIViewRepresentable {
    @ObservedObject var cameraManager: VideoCameraManager
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        setupPreviewLayer(in: view)
//        let previewLayer = AVCaptureVideoPreviewLayer(session: cameraManager.session)
//        previewLayer.videoGravity = .resizeAspectFill
//        view.layer.addSublayer(previewLayer)
//        previewLayer.frame = view.bounds
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        updatePreviewLayerFrame(in: uiView)
        drawBoundingBoxes(in: uiView)
    }

    private func setupPreviewLayer(in view: UIView) {
        let previewLayer = AVCaptureVideoPreviewLayer(session: cameraManager.session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.bounds
    }

    private func updatePreviewLayerFrame(in view: UIView) {
        view.layer.sublayers?.first?.frame = view.bounds
    }

    private func drawBoundingBoxes(in view: UIView) {
        // Remove old bounding box layers
        view.layer.sublayers?.removeSubrange(1...)

        let viewSize = view.bounds.size
        let videoSize = cameraManager.videoSize

        for box in cameraManager.boundingBoxes {
//            let transformedBox = transformBoundingBox(box, fromVideoSize: videoSize, toViewSize: viewSize)
            let transformedBox = convertBoundingBoxCoordinates(boundingBox: box, to: view.bounds)
//            let transformedBox = transformBoundingBox(box, fromVideoSize: videoSize, toViewSize: viewSize)
            let boxLayer = createBoxLayer(with: transformedBox)
            view.layer.addSublayer(boxLayer)
        }
    }

    private func createBoxLayer(with rect: CGRect) -> CALayer {
        let layer = CALayer()
        layer.frame = rect
        layer.borderColor = UIColor.red.cgColor
        layer.borderWidth = 2
        return layer
    }

//    func updateUIView(_ uiView: UIViewType, context: Context) {
//        guard let layer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer else {
//            return
//        }
//        layer.frame = uiView.bounds
//        uiView.layer.sublayers?.removeSubrange(1...)
    ////        layer.sublayers?.removeSubrange(1...)
//        print("Box count: \(cameraManager.boundingBoxes.count)")
    ////        print("Box size: \(cameraManager.videoSize) \(uiView.bounds.size)")
//        for box in cameraManager.boundingBoxes {
//            let rectangleLayer = CAShapeLayer()
    ////            let transformedBox = transformBoundingBox(box: box, fromVideoSize: cameraManager.videoSize, toViewSize: uiView.bounds.size)
    ////            let transformedBox = box.applying(CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -1))
    ////            rectangleLayer.frame = box
//            rectangleLayer.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
//            rectangleLayer.borderColor = UIColor.red.cgColor
//            rectangleLayer.borderWidth = 2
    ////            print("Box: \(rectangleLayer)")
//            uiView.layer.addSublayer(rectangleLayer)
    ////            layer.addSublayer(rectangleLayer)
//        }
//    }
}
