////
////  Scanner.swift
////  DefineLens
////
////  Created by Sai Sandeep Vaddi on 11/25/23.
////
//
// import Foundation
// import VisionKit
//
// @MainActor @objc
// class ScannerManager: UIViewController, ObservableObject {
//    @Published var isRunning: Bool = false
//    let viewController = DataScannerViewController(
//        recognizedDataTypes: [.text()],
//        qualityLevel: .fast,
//        recognizesMultipleItems: true,
//        isHighFrameRateTrackingEnabled: true,
//        isHighlightingEnabled: true
//    )
//
//    func startScanner() async {
//        do {
//            if isRunning {
//                print("Already running")
//                return
//            }
//            var scannerAvailable: Bool {
//                DataScannerViewController.isSupported &&
//                    DataScannerViewController.isAvailable
//            }
//            if !scannerAvailable {
//                print("Scanner not available to start")
//                return
//            }
//            try viewController.startScanning()
//            isRunning = true
//            print("Scanner started")
//        } catch {
//            print("Unable to start scanner: \(error)")
//        }
//    }
//
//    func stopScanner() async {
//        if !isRunning {
//            print("Not running")
//        }
//        var scannerAvailable: Bool {
//            DataScannerViewController.isSupported &&
//                DataScannerViewController.isAvailable
//        }
//        if !scannerAvailable {
//            print("Scanner not available to stop")
//            return
//        }
//        viewController.stopScanning()
//        viewController.dismiss(animated: true)
//        isRunning = false
//        print("Scanner stopped")
//    }
// }
//
// extension ScannerManager: DataScannerViewControllerDelegate {
//    func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
//        switch item {
//        case .text(let text):
//            print("Found text: \(text)")
//
//        default:
//            print("Default case")
//        }
//    }
//
//    func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
//        addedItems.forEach { item in
//            switch item {
//            case .text(let text):
//                print("Added text: \(text)")
//
//            default:
//                print("Default case")
//            }
//        }
//    }
//
//    func dataScanner(_ dataScanner: DataScannerViewController, didRemove removedItems: [RecognizedItem], allItems: [RecognizedItem]) {
//        removedItems.forEach { item in
//            switch item {
//            case .text(let text):
//                print("Removed text: \(text)")
//
//            default:
//                print("Default case")
//            }
//        }
//    }
// }
