//
//  ContentView.swift
//  TerrainViewer
//
//  SwiftUI + RealityKit Terrain Viewer with Trees and Gestures
//

import SwiftUI
import RealityKit
import Combine

struct ContentView: View {
    @StateObject private var viewModel = TerrainViewModel()
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView("Loading terrain...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else if let error = viewModel.errorMessage {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
            } else {
                TerrainView(viewModel: viewModel)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Golf Course Viewer")
                                .font(.headline)
                                .foregroundColor(.white)
                            if let holeCount = viewModel.vectorData?.HoleCount {
                                Text("\(holeCount) Holes")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        .padding(8)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(8)
                        Spacer()
                    }
                    .padding()
                    Spacer()
                    
                    // Controls hint
                    Text("Pinch to zoom • Pan to rotate")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(8)
                        .padding(.bottom)
                }
            }
        }
    }
}
// MARK: - Extensions
extension simd_quatf {
    init(lookAt target: SIMD3<Float>, from position: SIMD3<Float>, up: SIMD3<Float>) {
        let forward = normalize(target - position)
        let right = normalize(cross(up, forward))
        let newUp = cross(forward, right)
        
        let m00 = right.x
        let m01 = right.y
        let m02 = right.z
        let m10 = newUp.x
        let m11 = newUp.y
        let m12 = newUp.z
        let m20 = forward.x
        let m21 = forward.y
        let m22 = forward.z
        
        let trace = m00 + m11 + m22
        
        if trace > 0 {
            let s = sqrt(trace + 1.0) * 2
            let w = 0.25 * s
            let x = (m21 - m12) / s
            let y = (m02 - m20) / s
            let z = (m10 - m01) / s
            self.init(ix: x, iy: y, iz: z, r: w)
        } else if m00 > m11 && m00 > m22 {
            let s = sqrt(1.0 + m00 - m11 - m22) * 2
            let w = (m21 - m12) / s
            let x = 0.25 * s
            let y = (m01 + m10) / s
            let z = (m02 + m20) / s
            self.init(ix: x, iy: y, iz: z, r: w)
        } else if m11 > m22 {
            let s = sqrt(1.0 + m11 - m00 - m22) * 2
            let w = (m02 - m20) / s
            let x = (m01 + m10) / s
            let y = 0.25 * s
            let z = (m12 + m21) / s
            self.init(ix: x, iy: y, iz: z, r: w)
        } else {
            let s = sqrt(1.0 + m22 - m00 - m11) * 2
            let w = (m10 - m01) / s
            let x = (m02 + m20) / s
            let y = (m12 + m21) / s
            let z = 0.25 * s
            self.init(ix: x, iy: y, iz: z, r: w)
        }
    }
}
