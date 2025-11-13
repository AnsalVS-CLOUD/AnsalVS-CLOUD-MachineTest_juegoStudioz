//
//  TerrainView.swift
//  TerrainViewerjuego
//
//  Created by Ansal on 13/11/25.
//

import SwiftUI
import RealityKit

struct TerrainView: UIViewRepresentable {
    @ObservedObject var viewModel: TerrainViewModel
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.environment.lighting.intensityExponent = 1.5
        
        // Store reference
        context.coordinator.arView = arView
        context.coordinator.viewModel = viewModel
        
        // Setup scene
        context.coordinator.setupScene()
        
        // Add gesture recognizers
        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        
        arView.addGestureRecognizer(pinchGesture)
        arView.addGestureRecognizer(panGesture)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}
