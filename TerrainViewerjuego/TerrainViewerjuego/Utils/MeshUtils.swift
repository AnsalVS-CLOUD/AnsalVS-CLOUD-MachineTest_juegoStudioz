//
//  MeshUtils.swift
//  TerrainViewerjuego
//
//  Created by Ansal on 13/11/25.
//
import SwiftUI
import RealityKit
import Combine

class MeshUtils {
    static func generateNormals(positions: [SIMD3<Float>], indices: [UInt32]) -> [SIMD3<Float>] {
        var normals = [SIMD3<Float>](repeating: SIMD3<Float>(0, 1, 0), count: positions.count)
        
        for i in stride(from: 0, to: indices.count, by: 3) {
            let i0 = Int(indices[i])
            let i1 = Int(indices[i + 1])
            let i2 = Int(indices[i + 2])
            
            let v0 = positions[i0]
            let v1 = positions[i1]
            let v2 = positions[i2]
            
            let edge1 = v1 - v0
            let edge2 = v2 - v0
            let normal = normalize(cross(edge1, edge2))
            
            normals[i0] += normal
            normals[i1] += normal
            normals[i2] += normal
        }
        
        return normals.map { normalize($0) }
    }
}


