//
//  ContentView.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/19/23.
//

import ARKit

import os
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

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return hypot(x - point.x, y - point.y)
    }
}

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}

func isValidWord(_ word: String) -> Bool {
    // Implement logic to check if the word is valid. This could be as simple as
    // checking the word's length, or as complex as consulting a dictionary.
    return word.count > 1 // Example: simple length check
}

class ImageSaveCoordinator: NSObject {
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Error saving image: \(error.localizedDescription)")
        } else {
            print("Image saved successfully")
        }
    }
}

func getImageOrientation() -> UIImage.Orientation {
    switch UIDevice.current.orientation {
    case .portrait:
        return .right
    case .portraitUpsideDown:
        return .left
    case .landscapeLeft:
        return .up
    case .landscapeRight:
        return .down
    default:
        return .right // Default to portrait
    }
}

func convertToOrientationCorrectedCoordinates(_ imageCoordinates: CGPoint, ciImage: CIImage, viewportSize: CGSize) -> CGPoint {
    // Assuming portrait orientation; adjust as needed for other orientations
    let adjustedX = imageCoordinates.y * (ciImage.extent.size.width / viewportSize.height)
    let adjustedY = (1 - imageCoordinates.x) * (ciImage.extent.size.height / viewportSize.width)
    return CGPoint(x: adjustedX, y: adjustedY)
}

let logger = Logger()

struct ContentView: View {
    @State private var isARSessionActive = true
    @State private var recognizedWords = [String]()
    @State private var arView: ARView? = ARView(frame: .zero)
    @State private var selectedWord: String = ""
    @State private var isShowingDefinition = false
    @State private var definitionText = ""
    @State private var currentTextAnchor: AnchorEntity?
    private let imageSaveCoordinator = ImageSaveCoordinator()
    func saveImageToPhotos(_ ciImage: CIImage) {
        if let cgImage = CIContext().createCGImage(ciImage, from: ciImage.extent) {
            let uiImage = UIImage(cgImage: cgImage)
            UIImageWriteToSavedPhotosAlbum(uiImage, imageSaveCoordinator, #selector(ImageSaveCoordinator.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }

    var body: some View {
        ZStack {
            ARTextView(isActive: $isARSessionActive, fetchWordAndDefinition: fetchWordAndDefinition, arView: $arView, isShowingDefinition: $isShowingDefinition)
                .edgesIgnoringSafeArea(.all)
                .disabled(!isARSessionActive)

            // Crosshair in the center
            Image(systemName: "target")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(.red)

            if isShowingDefinition {
                Text(definitionText)
                    .foregroundColor(.black) // Ensure text color contrasts with background
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .frame(width: 300, height: 200)
                    .overlay(
                        Button(action: {
                            self.isShowingDefinition = false
                        }) {
                            Image(systemName: "xmark.circle")
                                .foregroundColor(.black)
                                .padding()
                        }, alignment: .topTrailing
                    )
                    .id(UUID()) // Use an id modifier to refresh the view
            }
        }
    }

    func fetchWordAndDefinition(at transform: matrix_float4x4) {
        guard let currentFrame = arView?.session.currentFrame else {
            print("Unable to get current AR frame.")
            return
        }

        let pixelBuffer = currentFrame.capturedImage

        // Convert the AR frame to a CIImage
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let viewportSize = arView?.bounds.size ?? CGSize(width: 1, height: 1)
        let regionWidth = min(ciImage.extent.size.width, viewportSize.width)
        let regionHeight: CGFloat = 200 // Adjust the height as needed

        // Define the region at the center of the image for OCR
        let regionSize = CGSize(width: 800, height: 200) // Adjust as needed
        let regionRect = CGRect(x: (ciImage.extent.size.width - regionWidth) / 2,
                                y: (ciImage.extent.size.height - regionHeight) / 2,
                                width: regionWidth,
                                height: regionHeight)

        // Crop the CIImage to this region
        let croppedCIImage = ciImage.cropped(to: regionRect)

        // Perform OCR on the cropped CIImage
        let requestHandler = VNImageRequestHandler(ciImage: croppedCIImage, orientation: .up, options: [:])
        let request = VNRecognizeTextRequest(completionHandler: { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                print("No text recognized or error occurred: \(String(describing: error))")
                return
            }

            // Process the recognized text
            let recognizedStrings = observations.flatMap { $0.topCandidates(1).map { $0.string } }

            logger.info("recognizedStrings: \(recognizedStrings)")
            // Split the recognized strings at spaces and filter valid words
            let words = recognizedStrings.flatMap { $0.split(whereSeparator: { $0.isWhitespace }) }
            let validWords = words.map(String.init).filter { isValidWord($0) }

            if let firstValidWord = validWords.first {
                print("Recognized word: \(firstValidWord)")
                DispatchQueue.main.async {
                    // Fetch the definition of the recognized word
                    fetchFormattedDefinition(for: firstValidWord) { definition, _ in
                        logger.info("Definition: \(definition ?? "")")
                        if let definition = definition {
                            self.definitionText = definition ?? "Definition not found"
                        } else {
                            self.definitionText = "\(firstValidWord) \n Definition not found"
                        }
                        self.isShowingDefinition = true
                    }
                }
            } else {
                print("No word found at the center.")
            }
        })

        // Process the request
        do {
            try requestHandler.perform([request])
        } catch {
            print("Failed to perform OCR: \(error)")
        }
    }

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
