//
//  ARTextView.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/19/23.
//

import ARKit
import RealityKit
import SwiftUI
import Vision

let commonWords = Set(["the", "and", "of", "to", "in", "a", "is", "that", "it", "for", "on", "as", "with", "are", "this", "by", "be", "was", "from"])

struct ARTextView: UIViewRepresentable {
    @Binding var isActive: Bool
    @Binding var recognizedWords: [String]
    @Binding var arView: ARView?
    var onRecognizeWord: (String) -> Void

    func makeUIView(context: Context) -> ARView {
        let view = arView ?? ARView(frame: .zero)
        view.session.delegate = context.coordinator

        // Configure ARKit session
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
            configuration.frameSemantics.insert(.personSegmentationWithDepth)
        }
        view.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])

        return view
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        if isActive {
            uiView.session.run(ARWorldTrackingConfiguration())
        } else {
            uiView.session.pause()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, onRecognizeWord: onRecognizeWord)
    }

    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARTextView
        var lastProcessedTime = TimeInterval(0)
        var onRecognizeWord: (String) -> Void

        init(_ parent: ARTextView, onRecognizeWord: @escaping (String) -> Void) {
            self.parent = parent
            self.onRecognizeWord = onRecognizeWord
        }

        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            DispatchQueue.global(qos: .userInitiated).async { [self] in
                let currentTime = frame.timestamp
                if currentTime - self.lastProcessedTime > 2 {
                    lastProcessedTime = currentTime

                    let request = VNRecognizeTextRequest { request, error in
                        guard let observations = request.results as? [VNRecognizedTextObservation],
                              error == nil
                        else {
                            // Handle any errors (e.g., print them out)
                            return
                        }

//                        var processedWords = 0
                        for observation in observations {
//                            if processedWords >= 5 {
//                                break
//                            }
                            guard let topCandidate = observation.topCandidates(1).first else {
                                continue // No candidate, continue to next observation
                            }
                            let recognizedText = topCandidate.string.lowercased()
                            if recognizedText.count > 1,
                               recognizedText.rangeOfCharacter(from: CharacterSet.letters.inverted) == nil
                            {
                                DispatchQueue.main.async {
                                    self.onRecognizeWord(recognizedText)
                                }
                            }
//                            if recognizedText.count > 1 && recognizedText.rangeOfCharacter(from: CharacterSet.letters.inverted) == nil {
//                                if !commonWords.contains(recognizedText) {
//                                    if let cachedDefinition = WordDefinitionCache.shared.definition(for: recognizedText) {
//                                        print("Cached Definition of \(recognizedText): \(cachedDefinition)")
//                                    } else {
//                                        fetchDefinition(for: recognizedText) { definition in
//                                            guard let definition = definition else {
//                                                print("Definition not found for \(recognizedText)")
//                                                return
//                                            }
//                                            // Save to cache
//                                            WordDefinitionCache.shared.setDefinition(definition, for: recognizedText)
//                                            print("Fetched Definition of \(recognizedText): \(definition)")
//                                        }
//                                    }
//                                }
//                            }
//                            processedWords += 1
                        }
                    }

                    request.recognitionLanguages = ["en-US"]
//                    request.recognitionLevel = .fast
                    // 3. Convert the ARFrame to a format Vision can work with.
                    let pixelBuffer = frame.capturedImage

                    // 4. Perform the request on the pixel buffer.
                    let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
                    try? handler.perform([request])
                }
            }
        }
    }
}
