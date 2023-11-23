//
//  DataModel.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/22/23.
//
import SwiftUI

final class DataModel: ObservableObject {
    let camera = Camera()
    @Published var viewfinderImage: Image?

    init() {
        Task {
            await handleCameraPreviews()
        }
    }

    func handleCameraPreviews() async {
        let imageStream = camera.previewStream
            .map { $0.cgImage }

        for await image in imageStream {
            Task { @MainActor in
                viewfinderImage = image
            }
        }
    }
}
