//
//  TerrainViewModel.swift
//  TerrainViewerjuego
//
//  Created by Ansal on 13/11/25.
//

import SwiftUI
import RealityKit
import Combine


// MARK: - ViewModel
class TerrainViewModel: ObservableObject {
    @Published var isLoading = true
    @Published var errorMessage: String?
    
    var elevationData: ElevationData?
    var vectorData: VectorData?
    
    var cameraDistance: Float = 150.0
    var cameraRotation: SIMD2<Float> = SIMD2(120, 33)
    var cameraTarget: SIMD3<Float> = SIMD3(0, 0, 0) // Will be set to terrain center
    
    init() {
        loadData()
    }
    
    func loadData() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            guard let elevationURL = Bundle.main.url(forResource: "Elevation", withExtension: "json"),
                  let elevationDataContent = try? Data(contentsOf: elevationURL),
                  let elevation = try? JSONDecoder().decode(ElevationData.self, from: elevationDataContent) else {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to load Elevation.json"
                    self.isLoading = false
                }
                return
            }
            
            guard let vectorURL = Bundle.main.url(forResource: "vector", withExtension: "json"),
                  let vectorDataContent = try? Data(contentsOf: vectorURL),
                  let vector = try? JSONDecoder().decode(VectorData.self, from: vectorDataContent) else {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to load vector.json"
                    self.isLoading = false
                }
                return
            }
            
            DispatchQueue.main.async {
                self.elevationData = elevation
                self.vectorData = vector
                self.isLoading = false
            }
        }
    }
    
    func updateCamera(distance: Float? = nil, rotation: SIMD2<Float>? = nil) {
        if let distance = distance {
            self.cameraDistance = max(30, min(500, distance))
        }
        if let rotation = rotation {
            self.cameraRotation = rotation
            self.cameraRotation.x = max(10, min(170, self.cameraRotation.x))
        }
    }
}
