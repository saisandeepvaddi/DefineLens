//
//  ScannerView.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/25/23.
//

import SwiftUI
import VisionKit

@MainActor
struct ScannerView: UIViewControllerRepresentable {
    typealias UIViewControllerType = DataScannerViewController

    @Binding var startScanning: Bool
    @Binding var recognizedStrings: [String]

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let viewController = DataScannerViewController(
            recognizedDataTypes: [.text()],
            qualityLevel: .accurate,
            recognizesMultipleItems: true,
//            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )

//        let midX = UIScreen.main.bounds.midX
//        let midY = UIScreen.main.bounds.midY

//        viewController.regionOfInterest = CGRect(x: midX, y: midY, width: .infinity, height: 20)
        viewController.delegate = context.coordinator

        return viewController
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        if startScanning {
            try? uiViewController.startScanning()
            print("Bounds: \(uiViewController.view.bounds)")
            print("Started")
        } else {
            uiViewController.stopScanning()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        var parent: ScannerView

        init(_ parent: ScannerView) {
            self.parent = parent
        }

//        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
//            switch item {
//            case .text(let text):
//                print("Found text: \(text)")
//
//            default:
//                print("Default case")
//            }
//        }

        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            addedItems.forEach { item in
                switch item {
                case .text(let text):

                    let crosshairX = UIScreen.main.bounds.midX
                    let crosshairY = UIScreen.main.bounds.midY
                    let scale = UIScreen.main.scale
                    let viewBounds = dataScanner.view.bounds
                    let crosshairPoint = CGPoint(x: crosshairX / viewBounds.width, y: crosshairY / viewBounds.height)

                    let observation = text.observation
                    let boundingBox = observation.boundingBox

                    if boundingBox.contains(crosshairPoint) {
                        guard let candidate = observation.topCandidates(1).first else { return }
                        let fullString = text.transcript
                        let words = fullString.split(separator: " ").map(String.init)
                        for word in words {
                            if let wordRange = fullString.range(of: word) {
                                do {
                                    let boxObservation = try candidate.boundingBox(for: wordRange)
                                    guard let boxObservation = boxObservation else {
                                        continue
                                    }

                                    let wordBoundingBox = boxObservation.boundingBox
                                    if wordBoundingBox.contains(crosshairPoint) {
                                        print("Word: \(word) \(wordRange) \(wordBoundingBox)")
                                        self.parent.recognizedStrings.append(word)
                                    }
                                } catch {
                                    print("Error in wordRange")
                                }
                            }
                        }
                    }

                default:
                    print("Default case")
                }
            }
        }

//        func dataScanner(_ dataScanner: DataScannerViewController, didRemove removedItems: [RecognizedItem], allItems: [RecognizedItem]) {
//            removedItems.forEach { item in
//                switch item {
//                case .text(let text):
//                    print("Removed text: \(text)")
//
//                default:
//                    print("Default case")
//                }
//            }
//        }
    }
}
