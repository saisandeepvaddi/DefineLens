// ContentView.swift

import MLKit
import SwiftUI

func convertFrameToViewCoordinates(mlKitFrame: CGRect, imageSize: CGSize, viewSize: CGSize) -> CGRect {
    let scaleX = viewSize.width / imageSize.width
    let scaleY = viewSize.height / imageSize.height

    // Adjust for different coordinate systems (if needed)
    let transformedY = imageSize.height - mlKitFrame.origin.y - mlKitFrame.height

    return CGRect(
        x: mlKitFrame.origin.x * scaleX,
        y: transformedY * scaleY,
        width: mlKitFrame.size.width * scaleX,
        height: mlKitFrame.size.height * scaleY
    )
}

struct AnnotationView: View {
    var frame: CGRect // Scaled frame

    var body: some View {
        Rectangle()
            .frame(width: frame.size.width, height: frame.size.height)
            .background(.clear)
            .border(Color.red, width: 2) // Red border for the annotation
            .position(x: frame.midX, y: frame.midY) // Position based on the mid-point of the frame
    }
}

struct Annotations: View {
    var textBlocks = [TextBlock]()
    var imageSize: CGSize = .zero
    var body: some View {
        GeometryReader { geometry in

            ForEach(textBlocks, id: \.self) { textBlock in
                let convertedFrame = convertFrameToViewCoordinates(mlKitFrame: textBlock.frame, imageSize: imageSize, viewSize: geometry.size)
                AnnotationView(frame: convertedFrame)
            }
        }
    }
}

struct ContentView: View {
    @StateObject var photoCameraManager = MLPhotoCameraManager()
    @StateObject var videoCameraManager = VideoCameraManager()
    @State private var navigateToDefinition = false
    @State private var recognizedWord: String?
    @State private var textBlocks = [TextBlock]()
    @State private var imageSize: CGSize = .zero
    @State private var showAnnotations = false
    var body: some View {
        GeometryReader { geometry in

            NavigationView {
                ZStack {
                    CameraView(cameraManager: photoCameraManager)
                        .edgesIgnoringSafeArea(.all)
                    CrosshairView()
                        .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/ .all/*@END_MENU_TOKEN@*/)
                    VStack {
                        Spacer()
                        Button(action: {
                            photoCameraManager.captureImage { text, image in
                                guard let text = text, let image = image else {
                                    print("no values")
                                    return
                                }

                                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                                let imageSize = image.size
                                let viewSize = geometry.size

                                var frames: [CGRect] = []

                                for block in text.blocks {
                                    let frame = block.frame
                                    let converted = convertFrameToViewCoordinates(mlKitFrame: frame, imageSize: imageSize, viewSize: viewSize)
                                    frames.append(converted)
                                }

                                guard let cgImage = image.cgImage else {
                                    print("No cgImage")
                                    return
                                }

//                                drawAnnotationsAtBoxes(image: image, cgImage: cgImage, bboxes: frames ?? [])
                            }
                        }) {
                            Text("Snap")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .font(.title)
                                .cornerRadius(20)
                        }
                        .padding()

//                        NavigationLink(destination: Annotations(textBlocks: textBlocks, imageSize: imageSize), isActive: $showAnnotations) {
//                            EmptyView()
//                        }

                        NavigationLink(destination: DefinitionView(word: recognizedWord), isActive: $navigateToDefinition) {
                            EmptyView()
                        }
                    }
                }
            }
        }
    }
}

// #Preview {
//    ContentView(photoCameraManager: PhotoCameraManager(), videoCameraManager: VideoCameraManager())
// }

// struct ContentView: View {
//    @StateObject var videoCameraManager = VideoCameraManager()
//    @StateObject var photoCameraManager = PhotoCameraManager()
//    @State private var isVideo: Bool = true
//    var body: some View {
//        ZStack {
//            if isVideo {
//                VideoView(cameraManager: videoCameraManager)
//                    .edgesIgnoringSafeArea(.all)
//            } else {
//                CameraView(cameraManager: photoCameraManager)
//                    .edgesIgnoringSafeArea(.all)
//            }
//
//            CrosshairView()
//                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/ .all/*@END_MENU_TOKEN@*/)
//            VStack {
//                Spacer()
//                HStack {
//                    if isVideo {
//                        Button(videoCameraManager.isRunning ? "Stop" : "Start") {
//                            videoCameraManager.toggleSession()
//                        }
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .clipShape(Rectangle())
//                        .padding(.bottom)
//                    }
//                    if !isVideo {
//                        Spacer()
//                        Button("Snap") {
//                            photoCameraManager.captureImage { buffer in
//                                print("Captured")
//                                guard let buffer = buffer else {
//                                    print("Invalid buffer")
//                                    return
//                                }
//                                if let image = photoCameraManager.convertToUIImage(pixelBuffer: buffer) {
//                                    recognizeTextAndHighlight(from: image) { recognizedText in
//                                        print("Recognized Text: \(recognizedText ?? "--")")
//                                    }
//                                }
//                            }
//                        }
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .clipShape(Circle())
//                        .padding(.bottom)
//                    }
//                    Spacer()
//                    Button(isVideo ? "Camera" : "Video") {
//                        isVideo = !isVideo
//                    }
//                    .padding()
//                    .background(Color.green)
//                    .foregroundColor(.white)
//                    .clipShape(Rectangle())
//                    .padding(.bottom)
//                }
//            }
//        }
//    }
// }
