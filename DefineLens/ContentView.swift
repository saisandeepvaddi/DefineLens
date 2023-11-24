// ContentView.swift

import SwiftUI

struct ContentView: View {
    @StateObject var photoCameraManager = MLPhotoCameraManager()
    @StateObject var videoCameraManager = VideoCameraManager()
    @State private var navigateToDefinition = false
    @State private var recognizedWord: String?

    var body: some View {
        NavigationView {
            ZStack {
                CameraView(cameraManager: photoCameraManager)
                    .edgesIgnoringSafeArea(.all)
                CrosshairView()
                    .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/ .all/*@END_MENU_TOKEN@*/)
                VStack {
                    Spacer()
                    Button(action: {
//                        photoCameraManager.captureImage { buffer in
//                            guard let buffer = buffer else {
//                                print("Invalid buffer")
//                                return
//                            }
//                            if let image = photoCameraManager.convertToUIImage(pixelBuffer: buffer) {
//                                recognizeTextAndHighlight(from: image) { recognizedText in
//                                    guard let word = recognizedText else {
//                                        print("No word found")
//                                        return
//                                    }
//                                    print("Recognized Text: \(word)")
//                                    self.recognizedWord = word
//                                    self.navigateToDefinition = true
//                                }
//                            }
//                        }
                        photoCameraManager.captureImage { text in
                            print("Text: \(text?.text)")
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

                    NavigationLink(destination: DefinitionView(word: recognizedWord), isActive: $navigateToDefinition) {
                        EmptyView()
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
