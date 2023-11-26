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
    @State var recognizedStrings = [String]()

    var body: some View {
        ZStack {
            ScannerView(startScanning: $startScanning, recognizedStrings: $recognizedStrings)
                .edgesIgnoringSafeArea(.all)
            CrosshairView()
                .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                Button(startScanning ? "Stop" : "Start") {
                    startScanning.toggle()
                }.frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .font(.title)
                    .cornerRadius(20)
            }
        }
    }
}

#Preview {
    DataScannerView()
}
