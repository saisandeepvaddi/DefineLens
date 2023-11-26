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

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let viewController = DataScannerViewController(
            recognizedDataTypes: [.text()],
            qualityLevel: .fast,
            recognizesMultipleItems: true,
            isHighFrameRateTrackingEnabled: true,
            isHighlightingEnabled: true
        )

        viewController.delegate = context.coordinator

        return viewController
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        if startScanning {
            try? uiViewController.startScanning()
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

//        func startScanner() {
//            guard let dataScannerViewController = dataScannerViewController else {
//                print("dataScannerViewController is not initialized in startScanner...")
//                return
//            }
//            if self.isRunning {
//                print("Already running")
//                return
//            }
//
//            var scannerAvailable: Bool = DataScannerViewController.isSupported &&
//                DataScannerViewController.isAvailable
//            do {
//                if !scannerAvailable {
//                    print("Scanner not available to start")
//                    return
//                }
//                try dataScannerViewController.startScanning()
//                self.isRunning = true
//                print("Scanner started")
//            } catch {
//                print("Unable to start scanner: \(error)")
//            }
//        }
//
//        func stopScanner() {
//            DispatchQueue.main.async {
//                guard let dataScannerViewController = dataScannerViewController else {
//                    print("dataScannerViewController is not initialized in stopScanner...")
//                    return
//                }
//                if !self.isRunning {
//                    print("Not running")
//                }
//                var scannerAvailable: Bool = DataScannerViewController.isSupported &&
//                    DataScannerViewController.isAvailable
//
//                if !scannerAvailable {
//                    print("Scanner not available to stop")
//                    return
//                }
//                dataScannerViewController.stopScanning()
//                dataScannerViewController.dismiss(animated: true)
//                self.isRunning = false
//                print("Scanner stopped")
//            }
//        }

        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .text(let text):
                print("Found text: \(text)")

            default:
                print("Default case")
            }
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            addedItems.forEach { item in
                switch item {
                case .text(let text):
                    print("Added text: \(text)")

                default:
                    print("Default case")
                }
            }
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didRemove removedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            removedItems.forEach { item in
                switch item {
                case .text(let text):
                    print("Removed text: \(text)")

                default:
                    print("Default case")
                }
            }
        }
    }
}
