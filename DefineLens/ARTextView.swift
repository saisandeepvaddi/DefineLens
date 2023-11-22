////
////  ARTextView.swift
////  DefineLens
////
////  Created by Sai Sandeep Vaddi on 11/19/23.
////

import ARKit
import RealityKit
import simd
import SwiftUI

struct ARTextView: UIViewRepresentable {
    @Binding var isActive: Bool
    var fetchWordAndDefinition: (matrix_float4x4) -> Void
    @Binding var arView: ARView?
    @Binding var isShowingDefinition: Bool
    func makeUIView(context: Context) -> ARView {
        let view = arView ?? ARView(frame: .zero)
        view.session.delegate = context.coordinator

        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        view.addGestureRecognizer(tapGesture)

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
        Coordinator(self, fetchWordAndDefinition: fetchWordAndDefinition, isShowingDefinition: isShowingDefinition)
    }

    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARTextView
        var fetchWordAndDefinition: (matrix_float4x4) -> Void
        var isShowingDefinition: Bool
        init(_ parent: ARTextView, fetchWordAndDefinition: @escaping (matrix_float4x4) -> Void, isShowingDefinition: Bool) {
            self.parent = parent
            self.fetchWordAndDefinition = fetchWordAndDefinition
            self.isShowingDefinition = isShowingDefinition
        }

        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            if isShowingDefinition {
                return
            }
            guard let arView = sender.view as? ARView else { return }
            let centerPoint = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)

            let hitTestResults = arView.hitTest(centerPoint, types: [.featurePoint])
            if let result = hitTestResults.first {
                fetchWordAndDefinition(result.worldTransform)
            }
        }
    }
}
