//
//  Coordinator.swift
//  TerrainViewerjuego
//
//  Created by Ansal on 13/11/25.
//
import SwiftUI
import RealityKit
import Combine

class Coordinator: NSObject {
        weak var arView: ARView?
        var viewModel: TerrainViewModel?
        var cameraEntity: PerspectiveCamera?
        var cameraAnchor: AnchorEntity?
        var terrainAnchor: AnchorEntity?
        
        var lastPanLocation: CGPoint?
        
        func setupScene() {
            guard let arView = arView,
                  let viewModel = viewModel,
                  let elevationData = viewModel.elevationData,
                  let vectorData = viewModel.vectorData else {
                return
            }
            
            // Create main anchor
            let anchor = AnchorEntity(world: .zero)
            arView.scene.addAnchor(anchor)
            self.terrainAnchor = anchor
            
            // Create camera
            let camera = PerspectiveCamera()
            let cameraAnchor = AnchorEntity(world: .zero)
            cameraAnchor.addChild(camera)
            arView.scene.addAnchor(cameraAnchor)
            
            self.cameraEntity = camera
            self.cameraAnchor = cameraAnchor
            
            // Build terrain
            let terrainBuilder = TerrainBuilder(elevationData: elevationData, vectorData: vectorData)
            terrainBuilder.buildTerrain(in: anchor)
            
            
            // Position camera
            updateCameraPosition()
        }
        
        func updateCameraPosition() {
            guard let cameraAnchor = cameraAnchor,
                  let viewModel = viewModel else { return }
            
            let rotX = viewModel.cameraRotation.x * .pi / 180.0
            let rotZ = viewModel.cameraRotation.y * .pi / 180.0
            
            let y = viewModel.cameraDistance * sin(rotX)
            let horizontalDistance = viewModel.cameraDistance * cos(rotX)
            let x = horizontalDistance * cos(rotZ)
            let z = horizontalDistance * sin(rotZ)
            
            let cameraPosition = viewModel.cameraTarget + SIMD3<Float>(x, y, z)
            
            let lookAtTransform = Transform(
                rotation: simd_quatf(lookAt: viewModel.cameraTarget, from: cameraPosition, up: [0, 1, 0]),
                translation: cameraPosition
            )
            
            cameraAnchor.transform = lookAtTransform
        }
        
        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            guard let viewModel = viewModel else { return }
            
            if gesture.state == .changed {
                let scale = Float(gesture.scale)
                let newDistance = viewModel.cameraDistance / scale
                viewModel.updateCamera(distance: newDistance)
                gesture.scale = 1.0
                updateCameraPosition()
            }
        }
        
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let viewModel = viewModel else { return }
            
            let location = gesture.location(in: gesture.view)
            
            if gesture.state == .began {
                lastPanLocation = location
            } else if gesture.state == .changed {
                guard let lastLocation = lastPanLocation else { return }
                
                let delta = CGPoint(
                    x: location.x - lastLocation.x,
                    y: location.y - lastLocation.y
                )
                
                var newRotation = viewModel.cameraRotation
                newRotation.y += Float(delta.x) * 0.3
                newRotation.x -= Float(delta.y) * 0.3
                
                viewModel.updateCamera(rotation: newRotation)
                
                lastPanLocation = location
                updateCameraPosition()
            } else if gesture.state == .ended {
                lastPanLocation = nil
            }
        }
    }

