//
//  ContentView.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/19/23.
//

import ARKit
import RealityKit
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

    func fetchDefinitionAndDisplayInAR(for word: String) {
        fetchDefinition(for: word) { definition in
            guard let definition = definition else {
                print("Definition not found for \(word)")
                return
            }
            let displayPosition = SIMD3<Float>(0, 0, -1) // Example position
            DispatchQueue.main.async {
                self.addTextToARScene(definition, at: displayPosition)
            }
        }
    }

    func addTextToARScene(_ text: String, at position: SIMD3<Float>) {
        let anchorEntity = AnchorEntity(world: position)
        let textEntity = createTextEntity(with: text)

        anchorEntity.addChild(textEntity)

        arView?.scene.addAnchor(anchorEntity)

//        let translationMatrix = matrix_float4x4.translation(position)
//        let anchor = ARAnchor(name: "definition", transform: translationMatrix)
//
//        // You'll need to keep a reference to your ARView to add anchors to it
//        arView?.session.add(anchor: anchor)
//
//        // Create a text entity to display the definition
//        let textEntity = createTextEntity(with: text)
//
//        // Attach the text entity to the anchor
//        // Note: This requires a RealityKit ARView, adjust if using SceneKit
//        arView?.scene.anchors.append(anchor)
//        anchor.addChild(textEntity)
    }

    func createTextEntity(with text: String) -> Entity {
        // Create an entity with text
        let textMesh = MeshResource.generateText(text,
                                                 extrusionDepth: 0.1,
                                                 font: .systemFont(ofSize: 0.5),
                                                 containerFrame: CGRect.zero,
                                                 alignment: .left,
                                                 lineBreakMode: .byTruncatingTail)
        let material = SimpleMaterial(color: .white, isMetallic: false)
        return ModelEntity(mesh: textMesh, materials: [material])
    }
}

#Preview {
    ContentView()
}
