// ContentView.swift

import SwiftUI

// struct ContentView: View {
//    @StateObject var photoCameraManager = PhotoCameraManager()
//    @StateObject var videoCameraManager = VideoCameraManager()
//
//    var body: some View {
//        ZStack {
////            CameraView(cameraManager: photoCameraManager)
////                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
//            VideoView(videoManager: videoCameraManager)
//                .edgesIgnoringSafeArea(.all)
//            CrosshairView()
//                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/ .all/*@END_MENU_TOKEN@*/)
//            VStack {
//                Spacer()
//                Button("Snap") {
//                    photoCameraManager.captureImage { buffer in
//                        print("Captured")
//                        guard let buffer = buffer else {
//                            print("Invalid buffer")
//                            return
//                        }
//                        if let image = photoCameraManager.convertToUIImage(pixelBuffer: buffer) {
//                            recognizeTextAndHighlight(from: image) { recognizedText in
//                                print("Recognized Text: \(recognizedText)")
//                            }
//                        }
//                        // Handle captured image (pixelBuffer)
//                    }
//                }
//                .padding()
//                .background(Color.blue)
//                .foregroundColor(.white)
//                .clipShape(Circle())
//                .padding(.bottom)
//            }
//        }
//    }
// }

struct ContentView: View {
    @StateObject var videoCameraManager = VideoCameraManager()
    @StateObject var photoCameraManager = PhotoCameraManager()
    @State private var isVideo: Bool = true
    var body: some View {
        ZStack {
            if isVideo {
                VideoView(cameraManager: videoCameraManager)
                    .edgesIgnoringSafeArea(.all)
            } else {
                CameraView(cameraManager: photoCameraManager)
                    .edgesIgnoringSafeArea(.all)
            }

            CrosshairView()
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/ .all/*@END_MENU_TOKEN@*/)
            VStack {
                Spacer()
                HStack {
                    if isVideo {
                        Button(videoCameraManager.isRunning ? "Stop" : "Start") {
                            videoCameraManager.toggleSession()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Rectangle())
                        .padding(.bottom)
                    }
                    if !isVideo {
                        Spacer()
                        Button("Snap") {
                            photoCameraManager.captureImage { buffer in
                                print("Captured")
                                guard let buffer = buffer else {
                                    print("Invalid buffer")
                                    return
                                }
                                if let image = photoCameraManager.convertToUIImage(pixelBuffer: buffer) {
                                    recognizeTextAndHighlight(from: image) { recognizedText in
                                        print("Recognized Text: \(recognizedText ?? "--")")
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .padding(.bottom)
                    }
                    Spacer()
                    Button(isVideo ? "Camera" : "Video") {
                        isVideo = !isVideo
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .clipShape(Rectangle())
                    .padding(.bottom)
                }
            }
        }
    }
}
