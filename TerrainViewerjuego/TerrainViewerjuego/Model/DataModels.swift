//
//  DataModels.swift
//  TerrainViewer
//
//  Created by Ansal on 12/11/25.
//

import Foundation
import simd

// MARK: - Elevation Data
struct ElevationData: Codable {
    let maxLatitude: Double
    let longPoints: Int
    let step: Double
    let elevationArray: [[Double]]
    let stepLongitudeMeters: Double
    let stepLatitudeMeters: Double
    let latPoints: Int
    let minLongitude: Double
    
    var minLatitude: Double {
        return maxLatitude - (Double(latPoints) * step)
    }
    
    var maxLongitude: Double {
        return minLongitude + (Double(longPoints) * step)
    }
}

// MARK: - Vector Data Structures
struct VectorData: Codable {
    let Tree: TreeData?
    let Clubhouse: ClubhouseData?
    let HoleCount: Int?
    let Holes: HolesData?
    let Creek: CreekData?
    let Path: PathData?
    let Background: BackgroundData?
    let Bridge: BridgeData?
    let Water: WaterData?
}

// MARK: - Tree Data with Attributes
struct TreeData: Codable {
    let Shapes: TreeShapes?
    let ShapeCount: Int?
}

struct TreeShapes: Codable {
    let Shape: [TreeShape]?
}

struct TreeShape: Codable {
    let Attributes: TreeAttributes?
    let Points: String?
    
    var parsedPoints: [SIMD2<Double>] {
        guard let pointsString = Points else { return [] }
        return parsePointsString(pointsString)
    }
}

struct TreeAttributes: Codable {
    let treeType: Int?
    let Size: Int?
    
    enum CodingKeys: String, CodingKey {
        case treeType = "Type"
        case Size
    }
}

// MARK: - Holes Data
struct HolesData: Codable {
    let Hole: [HoleData]?
}

struct HoleData: Codable {
    let Perimeter: HoleComponent?
    let Teebox: HoleComponent?
    let Centralpath: HoleComponent?
    let Green: HoleComponent?
    let Greencenter: HoleComponent?
    let Fairway: HoleComponent?
    let Teeboxcenter: HoleComponent?
    let HoleNumber: Int?
}

struct HoleComponent: Codable {
    let Shapes: ComponentShapes?
    let ShapeCount: Int?
}

struct ComponentShapes: Codable {
    let Shape: [ComponentShape]?
}

struct ComponentShape: Codable {
    let Points: String?
    
    var parsedPoints: [SIMD2<Double>] {
        guard let pointsString = Points else { return [] }
        return parsePointsString(pointsString)
    }
}

// MARK: - Other Features
struct WaterData: Codable {
    let Shapes: WaterShapes?
    let ShapeCount: Int?
}

struct WaterShapes: Codable {
    let Shape: [WaterShape]?
}

struct WaterShape: Codable {
    let Points: String?
    
    var parsedPoints: [SIMD2<Double>] {
        guard let pointsString = Points else { return [] }
        return parsePointsString(pointsString)
    }
}

struct BridgeData: Codable {
    let Shapes: BridgeShapes?
    let ShapeCount: Int?
}

struct BridgeShapes: Codable {
    let Shape: [BridgeShape]?
}

struct BridgeShape: Codable {
    let Points: String?
    
    var parsedPoints: [SIMD2<Double>] {
        guard let pointsString = Points else { return [] }
        return parsePointsString(pointsString)
    }
}

struct PathData: Codable {
    let Shapes: PathShapes?
    let ShapeCount: Int?
}

struct PathShapes: Codable {
    let Shape: [PathShape]?
}

struct PathShape: Codable {
    let Points: String?
    
    var parsedPoints: [SIMD2<Double>] {
        guard let pointsString = Points else { return [] }
        return parsePointsString(pointsString)
    }
}

struct BackgroundData: Codable {
    let Shapes: BackgroundShapes?
    let ShapeCount: Int?
}

struct BackgroundShapes: Codable {
    let Shape: [BackgroundShape]?
}

struct BackgroundShape: Codable {
    let Attributes: BackgroundAttributes?
    let Points: String?
    
    var parsedPoints: [SIMD2<Double>] {
        guard let pointsString = Points else { return [] }
        return parsePointsString(pointsString)
    }
}

struct BackgroundAttributes: Codable {
    let Description: Int?
}

struct CreekData: Codable {
    let Shapes: CreekShapes?
    let ShapeCount: Int?
}

struct CreekShapes: Codable {
    let Shape: [CreekShape]?
}

struct CreekShape: Codable {
    let Points: String?
    
    var parsedPoints: [SIMD2<Double>] {
        guard let pointsString = Points else { return [] }
        return parsePointsString(pointsString)
    }
}

struct ClubhouseData: Codable {
    let Shapes: ClubhouseShapes?
    let ShapeCount: Int?
}

struct ClubhouseShapes: Codable {
    let Shape: [ClubhouseShape]?
}

struct ClubhouseShape: Codable {
    let Points: String?
    
    var parsedPoints: [SIMD2<Double>] {
        guard let pointsString = Points else { return [] }
        return parsePointsString(pointsString)
    }
}

// MARK: - Utility Function for Parsing Points
func parsePointsString(_ pointsString: String) -> [SIMD2<Double>] {
    var points: [SIMD2<Double>] = []
    
    let components = pointsString.split(separator: ",")
    for component in components {
        let coordinates = component.split(separator: " ").compactMap { Double($0) }
        if coordinates.count == 2 {
            points.append(SIMD2<Double>(coordinates[0], coordinates[1]))
        }
    }
    
    return points
}
