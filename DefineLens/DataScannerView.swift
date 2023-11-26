//
//  DataScannerView.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/25/23.
//

import SwiftUI
import UIKit
import VisionKit

@MainActor
struct DataScannerView: View {
    @State var startScanning = false

    var body: some View {
        ZStack {
            ScannerView(startScanning: $startScanning)

            Button(startScanning ? "Stop" : "Start") {
                startScanning.toggle()
            }
        }
    }
}

#Preview {
    DataScannerView()
}
