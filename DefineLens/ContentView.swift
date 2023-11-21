//
//  ContentView.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/19/23.
//

import ARKit
import RealityKit
import simd
import SwiftUI

extension matrix_float4x4 {
    static func translation(_ translation: SIMD3<Float>) -> matrix_float4x4 {
        var matrix = matrix_identity_float4x4
        matrix.columns.3 = SIMD4<Float>(translation.x, translation.y, translation.z, 1)
        return matrix
    }
}

struct ContentView: View {
    @State private var isARSessionActive = false
    @State private var recognizedWords = [String]()
    @State private var arView: ARView? = ARView(frame: .zero)
    @State private var selectedWord: String = ""
    @State private var currentTextAnchor: AnchorEntity?
    var body: some View {
        VStack {
            ARTextView(isActive: $isARSessionActive, recognizedWords: $recognizedWords, arView: $arView, onRecognizeWord: { word in
                if !recognizedWords.contains(word) {
                    recognizedWords.append(word)
                }
            })
            .edgesIgnoringSafeArea(.all)
            .disabled(!isARSessionActive)

            Button(action: {
                isARSessionActive.toggle()
                let configuration = ARWorldTrackingConfiguration()
                configuration.planeDetection = [.horizontal, .vertical]
                configuration.environmentTexturing = .automatic
                if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
                    configuration.frameSemantics.insert(.personSegmentationWithDepth)
                }
                if isARSessionActive {
                    arView?.session.run(configuration)
                } else {
                    arView?.session.pause()
                }
//                view.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            }) {
                Text(isARSessionActive ? "Stop" : "Start")
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        ScrollView(.horizontal) {
            HStack {
                ForEach(recognizedWords, id: \.self) { word in
                    Button(action: {
                        fetchDefinitionAndDisplayInAR(for: word)
                        selectedWord = word
                    }) {
                        Text(word)
                            .padding()
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(5)
                    }
                }
            }
        }
        .padding()
    }

    // ContentView.swift

    func fetchDefinitionAndDisplayInAR(for word: String) {
        fetchDefinition(for: word) { jsonData in
            guard let jsonData = jsonData,
                  let dictionaryEntries = DictionaryResponse.parse(jsonData: jsonData),
                  let firstEntry = dictionaryEntries.first,
                  let firstMeaning = firstEntry.meanings.first,
                  let firstDefinition = firstMeaning.definitions.first
            else {
                print("Unable to parse definition for \(word)")
                return
            }

            let formattedText = "\(word.uppercased()) (\(firstMeaning.partOfSpeech))\n\(firstDefinition.definition)"
            DispatchQueue.main.async {
                self.addTextToARScene(formattedText)
            }
        }
    }

//    func addTextToARScene(_ text: String) {
//        let position = SIMD3<Float>(0, 0, -1) // Example position
//        let anchorEntity = AnchorEntity(world: position)
//        let textEntity = createTextEntity(with: text)
//
//        anchorEntity.addChild(textEntity)
//
//        arView?.scene.addAnchor(anchorEntity)
//
    ////        let translationMatrix = matrix_float4x4.translation(position)
    ////        let anchor = ARAnchor(name: "definition", transform: translationMatrix)
    ////
    ////        // You'll need to keep a reference to your ARView to add anchors to it
    ////        arView?.session.add(anchor: anchor)
    ////
    ////        // Create a text entity to display the definition
    ////        let textEntity = createTextEntity(with: text)
    ////
    ////        // Attach the text entity to the anchor
    ////        // Note: This requires a RealityKit ARView, adjust if using SceneKit
    ////        arView?.scene.anchors.append(anchor)
    ////        anchor.addChild(textEntity)
//    }

    func addTextToARScene(_ text: String) {
        guard let currentFrame = arView?.session.currentFrame else {
            print("Unable to get current AR frame.")
            return
        }

        // Create a transform with a translation that's 0.5 meters in front of the camera
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.5 // Adjust this value as needed
        let transform = currentFrame.camera.transform * translation

        let anchorEntity = AnchorEntity(world: transform)
        let textEntity = createTextEntity(with: text)

        if let existingAnchor = currentTextAnchor {
            arView?.scene.removeAnchor(existingAnchor)
        }

        anchorEntity.addChild(textEntity)
        currentTextAnchor = anchorEntity
        arView?.scene.addAnchor(anchorEntity)
    }

    func addTextToARSceneAtPos(_ text: String, at position: matrix_float4x4) {
        let anchorEntity = AnchorEntity(world: position)
        let textEntity = createTextEntity(with: text)

        anchorEntity.addChild(textEntity)

        arView?.scene.addAnchor(anchorEntity)
    }

    func createTextEntity(with text: String) -> Entity {
        let textMesh = MeshResource.generateText(text,
                                                 extrusionDepth: 0.02,
                                                 font: .boldSystemFont(ofSize: 0.04),
                                                 containerFrame: CGRect.zero,
                                                 alignment: .left,
                                                 lineBreakMode: .byTruncatingTail)
        let material = SimpleMaterial(color: .green, isMetallic: false)
        let textEntity = ModelEntity(mesh: textMesh, materials: [material])

        textEntity.transform.rotation = simd_quatf(angle: .pi / 2, axis: [0, 0, 1])

        return textEntity
    }
}

#Preview {
    ContentView()
}
