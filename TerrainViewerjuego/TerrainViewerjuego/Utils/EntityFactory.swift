//
//  EntityFactory.swift
//  TerrainViewerjuego
//
//  Created by Ansal on 13/11/25.
//

import SwiftUI
import RealityKit
import Combine

// MARK: - Entity Factory (Creates 3D Models)
class EntityFactory {
    static func createTree(at point: SIMD2<Double>, size: Int, elevationData: ElevationData) -> ModelEntity? {
        let lon = point.x
        let lat = point.y
        
        // Calculate position in the elevation grid - same as polygons
        let lonIndex = (lon - elevationData.minLongitude) / elevationData.step
        let latIndex = (elevationData.maxLatitude - lat) / elevationData.step
        
        let x = Float(lonIndex)
        let z = Float(latIndex)
        
        let latInt = Int(latIndex)
        let lonInt = Int(lonIndex)
        
        guard latInt >= 0 && latInt < elevationData.latPoints &&
              lonInt >= 0 && lonInt < elevationData.longPoints else {
            return nil
        }
        
        let elevation = Float(elevationData.elevationArray[latInt][lonInt]) * 0.1
        
        let trunkHeight: Float = 1.0 + Float(size) * 0.3
        let canopyRadius: Float = 1.0 + Float(size) * 0.3
        
        let trunkMesh = MeshResource.generateCylinder(height: trunkHeight, radius: 0.2)
        var trunkMaterial = SimpleMaterial()
        trunkMaterial.color = .init(tint: .init(red: 0.4, green: 0.3, blue: 0.2, alpha: 1.0))
        let trunk = ModelEntity(mesh: trunkMesh, materials: [trunkMaterial])
        trunk.position.y = trunkHeight / 2
        
        let canopyMesh = MeshResource.generateSphere(radius: canopyRadius)
        var canopyMaterial = SimpleMaterial()
        canopyMaterial.color = .init(tint: .init(red: 0.1, green: 0.5, blue: 0.1, alpha: 1.0))
        let canopy = ModelEntity(mesh: canopyMesh, materials: [canopyMaterial])
        canopy.position.y = trunkHeight + canopyRadius
        
        let tree = ModelEntity()
        tree.addChild(trunk)
        tree.addChild(canopy)
        
        let centerX = Float(elevationData.longPoints) / 2.0
        let centerZ = Float(elevationData.latPoints) / 2.0
        tree.position = SIMD3<Float>(x - centerX, elevation, z - centerZ)
        
        return tree
    }
    
    static func createPolygon(points: [SIMD2<Double>], elevationData: ElevationData, height: Float, color: UIColor) -> ModelEntity? {
        guard points.count >= 3 else { return nil }
        
        var positions: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        
        let centerX = Float(elevationData.longPoints) / 2.0
        let centerZ = Float(elevationData.latPoints) / 2.0
        
        for point in points {
            // Convert lat/lon to grid coordinates - matching terrain mesh
            let lon = point.x
            let lat = point.y
            
            // Calculate position in the elevation grid
            let lonIndex = (lon - elevationData.minLongitude) / elevationData.step
            let latIndex = (elevationData.maxLatitude - lat) / elevationData.step
            
            let x = Float(lonIndex)
            let z = Float(latIndex)
            
            let latInt = Int(latIndex)
            let lonInt = Int(lonIndex)
            
            guard latInt >= 0 && latInt < elevationData.latPoints &&
                  lonInt >= 0 && lonInt < elevationData.longPoints else {
                continue
            }
            
            let elevation = Float(elevationData.elevationArray[latInt][lonInt]) * 0.1
            positions.append(SIMD3<Float>(x - centerX, elevation + height, z - centerZ))
        }
        
        guard positions.count >= 3 else { return nil }
        
        for i in 1..<(positions.count - 1) {
            indices.append(contentsOf: [0, UInt32(i), UInt32(i + 1)])
        }
        
        var descriptor = MeshDescriptor(name: "polygon")
        descriptor.positions = MeshBuffer(positions)
        descriptor.primitives = .triangles(indices)
        
        let mesh = try! MeshResource.generate(from: [descriptor])
        
        var material = SimpleMaterial()
        material.color = .init(tint: color)
        material.roughness = .float(0.8)
        
        return ModelEntity(mesh: mesh, materials: [material])
    }
    
    static func createMarker(at point: SIMD2<Double>, elevationData: ElevationData, color: UIColor, radius: Float) -> ModelEntity? {
        let lon = point.x
        let lat = point.y
        
        // Calculate position in the elevation grid - same as polygons
        let lonIndex = (lon - elevationData.minLongitude) / elevationData.step
        let latIndex = (elevationData.maxLatitude - lat) / elevationData.step
        
        let x = Float(lonIndex)
        let z = Float(latIndex)
        
        let latInt = Int(latIndex)
        let lonInt = Int(lonIndex)
        
        guard latInt >= 0 && latInt < elevationData.latPoints &&
              lonInt >= 0 && lonInt < elevationData.longPoints else {
            return nil
        }
        
        let elevation = Float(elevationData.elevationArray[latInt][lonInt]) * 0.1
        
        let markerMesh = MeshResource.generateSphere(radius: radius)
        var markerMaterial = SimpleMaterial()
        markerMaterial.color = .init(tint: color)
        let marker = ModelEntity(mesh: markerMesh, materials: [markerMaterial])
        
        let centerX = Float(elevationData.longPoints) / 2.0
        let centerZ = Float(elevationData.latPoints) / 2.0
        marker.position = SIMD3<Float>(x - centerX, elevation + radius, z - centerZ)
        
        return marker
    }
    
    static func createHoleNumberMarker(number: Int, at point: SIMD2<Double>, elevationData: ElevationData) -> ModelEntity? {
        let lon = point.x
        let lat = point.y
        
        // Calculate position in the elevation grid - same as polygons
        let lonIndex = (lon - elevationData.minLongitude) / elevationData.step
        let latIndex = (elevationData.maxLatitude - lat) / elevationData.step
        
        let x = Float(lonIndex)
        let z = Float(latIndex)
        
        let latInt = Int(latIndex)
        let lonInt = Int(lonIndex)
        
        guard latInt >= 0 && latInt < elevationData.latPoints &&
              lonInt >= 0 && lonInt < elevationData.longPoints else {
            return nil
        }
        
        let elevation = Float(elevationData.elevationArray[latInt][lonInt]) * 0.1
        
        // Create a tall cylinder as a flag pole with a sphere on top
        let poleMesh = MeshResource.generateCylinder(height: 5.0, radius: 0.1)
        var poleMaterial = SimpleMaterial()
        poleMaterial.color = .init(tint: .white)
        let pole = ModelEntity(mesh: poleMesh, materials: [poleMaterial])
        pole.position.y = 2.5
        
        // Create flag (small box)
        let flagMesh = MeshResource.generateBox(size: [1.5, 1.0, 0.1])
        var flagMaterial = SimpleMaterial()
        flagMaterial.color = .init(tint: .init(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0))
        let flag = ModelEntity(mesh: flagMesh, materials: [flagMaterial])
        flag.position = SIMD3<Float>(0.75, 4.5, 0)
        
        let marker = ModelEntity()
        marker.addChild(pole)
        marker.addChild(flag)
        
        let centerX = Float(elevationData.longPoints) / 2.0
        let centerZ = Float(elevationData.latPoints) / 2.0
        marker.position = SIMD3<Float>(x - centerX, elevation, z - centerZ)
        
        return marker
    }
    
    static func createPath(points: [SIMD2<Double>], elevationData: ElevationData, width: Float, color: UIColor) -> ModelEntity? {
        guard points.count >= 2 else { return nil }
        
        var positions: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        
        let centerX = Float(elevationData.longPoints) / 2.0
        let centerZ = Float(elevationData.latPoints) / 2.0
        let halfWidth = width / 2.0
        
        for i in 0..<points.count {
            let point = points[i]
            
            // Convert lat/lon to grid coordinates - matching terrain mesh
            let lon = point.x
            let lat = point.y
            
            // Calculate position in the elevation grid
            let lonIndex = (lon - elevationData.minLongitude) / elevationData.step
            let latIndex = (elevationData.maxLatitude - lat) / elevationData.step
            
            let x = Float(lonIndex)
            let z = Float(latIndex)
            
            let latInt = Int(latIndex)
            let lonInt = Int(lonIndex)
            
            guard latInt >= 0 && latInt < elevationData.latPoints &&
                  lonInt >= 0 && lonInt < elevationData.longPoints else {
                continue
            }
            
            let elevation = Float(elevationData.elevationArray[latInt][lonInt]) * 0.1
            
            var perpendicular = SIMD2<Float>(0, 1)
            if i < points.count - 1 {
                let next = points[i + 1]
                let direction = SIMD2<Float>(Float(next.x - point.x), Float(next.y - point.y))
                if length(direction) > 0 {
                    let normalized = normalize(direction)
                    perpendicular = SIMD2<Float>(-normalized.y, normalized.x)
                }
            }
            
            let basePos = SIMD3<Float>(x - centerX, elevation + 0.1, z - centerZ)
            positions.append(basePos + SIMD3<Float>(perpendicular.x * halfWidth, 0, perpendicular.y * halfWidth))
            positions.append(basePos - SIMD3<Float>(perpendicular.x * halfWidth, 0, perpendicular.y * halfWidth))
        }
        
        for i in 0..<(positions.count - 2) {
            if i % 2 == 0 {
                indices.append(contentsOf: [UInt32(i), UInt32(i + 2), UInt32(i + 1)])
                indices.append(contentsOf: [UInt32(i + 1), UInt32(i + 2), UInt32(i + 3)])
            }
        }
        
        guard !positions.isEmpty && !indices.isEmpty else { return nil }
        
        var descriptor = MeshDescriptor(name: "path")
        descriptor.positions = MeshBuffer(positions)
        descriptor.primitives = .triangles(indices)
        
        let mesh = try! MeshResource.generate(from: [descriptor])
        
        var material = SimpleMaterial()
        material.color = .init(tint: color)
        material.roughness = .float(0.7)
        
        return ModelEntity(mesh: mesh, materials: [material])
    }
    
    static func createWater(points: [SIMD2<Double>], elevationData: ElevationData) -> ModelEntity? {
        guard let baseEntity = createPolygon(
            points: points,
            elevationData: elevationData,
            height: 0.05,
            color: .clear
        ) else { return nil }
        
        // Create custom water material with reflective properties
        var material = SimpleMaterial()
        material.color = .init(tint: .init(red: 0.15, green: 0.45, blue: 0.75, alpha: 0.8))
        material.roughness = .float(0.1) // Shiny water
        material.metallic = .float(0.3) // Slight metallic for reflection
        
        baseEntity.model?.materials = [material]
        
        return baseEntity
    }
}


