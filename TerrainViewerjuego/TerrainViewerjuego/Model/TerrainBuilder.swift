//
//  TerrainBuilder.swift
//  TerrainViewerjuego
//
//  Created by Ansal on 13/11/25.
//

import SwiftUI
import RealityKit
import Combine

class TerrainBuilder {
    let elevationData: ElevationData
    let vectorData: VectorData
    
    init(elevationData: ElevationData, vectorData: VectorData) {
        self.elevationData = elevationData
        self.vectorData = vectorData
    }
    
    func buildTerrain(in anchor: AnchorEntity) {
        // Add sky first (furthest back)
        addSky(to: anchor)
        
        // Add background
        addBackground(to: anchor)
        
        // Create terrain mesh
        let terrainEntity = createTerrainMesh()
        anchor.addChild(terrainEntity)
        
        // Add all features in layered order
        addWater(to: anchor)
        addCreeks(to: anchor)
        addHoles(to: anchor)
        addPaths(to: anchor)
        addBridges(to: anchor)
        addTrees(to: anchor)
        addClubhouse(to: anchor)
    }
    
    private func addSky(to anchor: AnchorEntity) {
        let skyMesh = MeshResource.generateSphere(radius: 500)
        var skyMaterial = SimpleMaterial()
        
        // Sky blue color
        skyMaterial.color = .init(tint: .init(red: 0.53, green: 0.81, blue: 0.92, alpha: 1.0))
        //skyMaterial.isMetallic = false
        
        let sky = ModelEntity(mesh: skyMesh, materials: [skyMaterial])
        sky.scale = SIMD3<Float>(-1, 1, 1) // Invert to see inside
        
        anchor.addChild(sky)
    }
    
    private func createTerrainMesh() -> ModelEntity {
        let latPoints = elevationData.latPoints
        let longPoints = elevationData.longPoints
        
        var positions: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        var textureCoordinates: [SIMD2<Float>] = []
        
        for lat in 0..<latPoints {
            for lon in 0..<longPoints {
                let x = Float(lon)
                let z = Float(lat)
                let y = Float(elevationData.elevationArray[lat][lon]) * 0.1
                
                positions.append(SIMD3<Float>(x, y, z))
                
                let u = Float(lon) / Float(longPoints) * 10.0
                let v = Float(lat) / Float(latPoints) * 10.0
                textureCoordinates.append(SIMD2<Float>(u, v))
            }
        }
        
        for lat in 0..<(latPoints - 1) {
            for lon in 0..<(longPoints - 1) {
                let topLeft = UInt32(lat * longPoints + lon)
                let topRight = topLeft + 1
                let bottomLeft = UInt32((lat + 1) * longPoints + lon)
                let bottomRight = bottomLeft + 1
                
                indices.append(contentsOf: [topLeft, bottomLeft, topRight])
                indices.append(contentsOf: [topRight, bottomLeft, bottomRight])
            }
        }
        
        var descriptor = MeshDescriptor(name: "terrain")
        descriptor.positions = MeshBuffer(positions)
        descriptor.primitives = .triangles(indices)
        descriptor.textureCoordinates = MeshBuffer(textureCoordinates)
        
        let normals = MeshUtils.generateNormals(positions: positions, indices: indices)
        descriptor.normals = MeshBuffer(normals)
        
        let mesh = try! MeshResource.generate(from: [descriptor])
        
        var material = SimpleMaterial()
        // More realistic grass color
        material.color = .init(tint: .init(red: 0.34, green: 0.52, blue: 0.25, alpha: 1.0))
        material.roughness = .float(0.95)
        material.metallic = .float(0.0)
        
        let terrainEntity = ModelEntity(mesh: mesh, materials: [material])
        
        let centerX = Float(longPoints) / 2.0
        let centerZ = Float(latPoints) / 2.0
        terrainEntity.position = SIMD3<Float>(-centerX, 0, -centerZ)
        
        return terrainEntity
    }
    
    private func addTrees(to anchor: AnchorEntity) {
        guard let trees = vectorData.Tree?.Shapes?.Shape else { return }
        
        for tree in trees {
            let points = tree.parsedPoints
            guard let firstPoint = points.first else { continue }
            
            if let entity = EntityFactory.createTree(
                at: firstPoint,
                size: tree.Attributes?.Size ?? 1,
                elevationData: elevationData
            ) {
                anchor.addChild(entity)
            }
        }
    }
    
    private func addClubhouse(to anchor: AnchorEntity) {
        guard let clubhouses = vectorData.Clubhouse?.Shapes?.Shape else { return }
        
        for clubhouse in clubhouses {
            if let entity = EntityFactory.createPolygon(
                points: clubhouse.parsedPoints,
                elevationData: elevationData,
                height: 5.0,
                color: .init(red: 0.7, green: 0.6, blue: 0.5, alpha: 1.0)
            ) {
                anchor.addChild(entity)
            }
        }
    }
    
    private func addWater(to anchor: AnchorEntity) {
        guard let waterShapes = vectorData.Water?.Shapes?.Shape else { return }
        
        for water in waterShapes {
            if let entity = EntityFactory.createWater(
                points: water.parsedPoints,
                elevationData: elevationData
            ) {
                anchor.addChild(entity)
            }
        }
    }
    
    private func addHoles(to anchor: AnchorEntity) {
        guard let holes = vectorData.Holes?.Hole else { return }
        
        for hole in holes {
            // Perimeter (outline of the hole)
            if let perimeterShapes = hole.Perimeter?.Shapes?.Shape {
                for shape in perimeterShapes {
                    if let entity = EntityFactory.createPath(
                        points: shape.parsedPoints,
                        elevationData: elevationData,
                        width: 1.0,
                        color: .init(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
                    ) {
                        anchor.addChild(entity)
                    }
                }
            }
            
            // Fairways - lighter, vibrant green
            if let fairwayShapes = hole.Fairway?.Shapes?.Shape {
                for shape in fairwayShapes {
                    if let entity = EntityFactory.createPolygon(
                        points: shape.parsedPoints,
                        elevationData: elevationData,
                        height: 0.05,
                        color: .init(red: 0.45, green: 0.68, blue: 0.35, alpha: 1.0)
                    ) {
                        anchor.addChild(entity)
                    }
                }
            }
            
            // Greens - darker, richer green
            if let greenShapes = hole.Green?.Shapes?.Shape {
                for shape in greenShapes {
                    if let entity = EntityFactory.createPolygon(
                        points: shape.parsedPoints,
                        elevationData: elevationData,
                        height: 0.08,
                        color: .init(red: 0.25, green: 0.55, blue: 0.25, alpha: 1.0)
                    ) {
                        anchor.addChild(entity)
                    }
                }
            }
            
            // Teeboxes - sandy/tan color
            if let teeboxShapes = hole.Teebox?.Shapes?.Shape {
                for shape in teeboxShapes {
                    if let entity = EntityFactory.createPolygon(
                        points: shape.parsedPoints,
                        elevationData: elevationData,
                        height: 0.08,
                        color: .init(red: 0.8, green: 0.7, blue: 0.5, alpha: 1.0)
                    ) {
                        anchor.addChild(entity)
                    }
                }
            }
            
            // Central path (line from tee to green)
            if let centralPathShapes = hole.Centralpath?.Shapes?.Shape {
                for shape in centralPathShapes {
                    if let entity = EntityFactory.createPath(
                        points: shape.parsedPoints,
                        elevationData: elevationData,
                        width: 0.5,
                        color: .init(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.6)
                    ) {
                        anchor.addChild(entity)
                    }
                }
            }
            
            // Green center marker
            if let greenCenterShapes = hole.Greencenter?.Shapes?.Shape {
                for shape in greenCenterShapes {
                    let points = shape.parsedPoints
                    if let firstPoint = points.first,
                       let entity = EntityFactory.createMarker(
                        at: firstPoint,
                        elevationData: elevationData,
                        color: .init(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0),
                        radius: 0.5
                    ) {
                        anchor.addChild(entity)
                    }
                }
            }
            
            // Teebox center marker
            if let teeboxCenterShapes = hole.Teeboxcenter?.Shapes?.Shape {
                for shape in teeboxCenterShapes {
                    let points = shape.parsedPoints
                    if let firstPoint = points.first,
                       let entity = EntityFactory.createMarker(
                        at: firstPoint,
                        elevationData: elevationData,
                        color: .init(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0),
                        radius: 0.4
                    ) {
                        anchor.addChild(entity)
                    }
                }
            }
            
            // Hole number text
            if let holeNumber = hole.HoleNumber,
               let greenCenterShapes = hole.Greencenter?.Shapes?.Shape,
               let firstShape = greenCenterShapes.first,
               let centerPoint = firstShape.parsedPoints.first {
                if let entity = EntityFactory.createHoleNumberMarker(
                    number: holeNumber,
                    at: centerPoint,
                    elevationData: elevationData
                ) {
                    anchor.addChild(entity)
                }
            }
        }
    }
    
    private func addPaths(to anchor: AnchorEntity) {
        guard let pathShapes = vectorData.Path?.Shapes?.Shape else { return }
        
        for path in pathShapes {
            if let entity = EntityFactory.createPath(
                points: path.parsedPoints,
                elevationData: elevationData,
                width: 2.0,
                color: .init(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
            ) {
                anchor.addChild(entity)
            }
        }
    }
    
    private func addBridges(to anchor: AnchorEntity) {
        guard let bridgeShapes = vectorData.Bridge?.Shapes?.Shape else { return }
        
        for bridge in bridgeShapes {
            if let entity = EntityFactory.createPolygon(
                points: bridge.parsedPoints,
                elevationData: elevationData,
                height: 2.5,
                color: .init(red: 0.6, green: 0.4, blue: 0.2, alpha: 1.0)
            ) {
                anchor.addChild(entity)
            }
        }
    }
    
    private func addBackground(to anchor: AnchorEntity) {
        guard let backgroundShapes = vectorData.Background?.Shapes?.Shape else { return }
        
        for background in backgroundShapes {
            // Different colors based on description type
            let description = background.Attributes?.Description ?? 0
            var color: UIColor
            
            switch description {
            case 0:
                color = .init(red: 0.85, green: 0.85, blue: 0.75, alpha: 1.0)
            case 1:
                color = .init(red: 0.2, green: 0.4, blue: 0.2, alpha: 1.0)
            case 2:
                color = .init(red: 0.6, green: 0.6, blue: 0.5, alpha: 1.0)
            default:
                color = .init(red: 0.5, green: 0.6, blue: 0.4, alpha: 1.0)
            }
            
            if let entity = EntityFactory.createPolygon(
                points: background.parsedPoints,
                elevationData: elevationData,
                height: 0.01,
                color: color
            ) {
                anchor.addChild(entity)
            }
        }
    }
    
    private func addCreeks(to anchor: AnchorEntity) {
        guard let creekShapes = vectorData.Creek?.Shapes?.Shape else { return }
        
        for creek in creekShapes {
            if let entity = EntityFactory.createPath(
                points: creek.parsedPoints,
                elevationData: elevationData,
                width: 3.0,
                color: .init(red: 0.3, green: 0.6, blue: 0.9, alpha: 0.8)
            ) {
                anchor.addChild(entity)
            }
        }
    }
}
