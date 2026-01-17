//
//  APIService.swift
//  Mindfold
//
//  Created by Evan Haque on 1/9/26.
//

import Foundation

// Convenience wrapper that uses the factory
class APIService {
    static func generateShikaku(
        rows: Int = 8,
        cols: Int = 7,
        targetRects: Int? = nil,
        maxRectArea: Int? = nil,
        seed: Int? = nil
    ) async throws -> ShikakuPuzzle {
        return try await APIServiceFactory.getService().generateShikaku(
            rows: rows,
            cols: cols,
            targetRects: targetRects,
            maxRectArea: maxRectArea,
            seed: seed
        )
    }
    
    static func generateTakuzu(
        size: Int = 8,
        givensRatio: Double = 0.25,
        ensureUnique: Bool = true,
        seed: Int? = nil
    ) async throws -> TakuzuPuzzle {
        return try await APIServiceFactory.getService().generateTakuzu(
            size: size,
            givensRatio: givensRatio,
            ensureUnique: ensureUnique,
            seed: seed
        )
    }
    
    static func generateStarBattle(
        size: Int = 8,
        ensureUnique: Bool = false,
        seed: Int? = nil
    ) async throws -> StarBattlePuzzle {
        return try await APIServiceFactory.getService().generateStarBattle(
            size: size,
            ensureUnique: ensureUnique,
            seed: seed
        )
    }
    
    static func generateNetwalk(
        rows: Int = 6,
        cols: Int = 6,
        seed: Int? = nil,
        allowCross: Bool = true,
        preferSourceDegree: Int = 2
    ) async throws -> NetwalkPuzzle {
        return try await APIServiceFactory.getService().generateNetwalk(
            rows: rows,
            cols: cols,
            seed: seed,
            allowCross: allowCross,
            preferSourceDegree: preferSourceDegree
        )
    }
    
    static func generateLITS(
        rows: Int = 6,
        cols: Int = 7,
        seed: Int? = nil,
        minRegionSize: Int = 4,
        maxRegionSize: Int = 8,
        ensureUnique: Bool = true,
        maxRegionAttempts: Int = 2000,
        maxSolveAttemptsPerRegionMap: Int = 500
    ) async throws -> LITSPuzzle {
        return try await APIServiceFactory.getService().generateLITS(
            rows: rows,
            cols: cols,
            seed: seed,
            minRegionSize: minRegionSize,
            maxRegionSize: maxRegionSize,
            ensureUnique: ensureUnique,
            maxRegionAttempts: maxRegionAttempts,
            maxSolveAttemptsPerRegionMap: maxSolveAttemptsPerRegionMap
        )
    }
    
    static func generateMastermind(
        codeLen: Int = 4,
        numColors: Int = 4,
        allowRepeats: Bool = true,
        avoidTrivial: Bool = true,
        maxAttempts: Int = 10,
        enforceSolvableWithinAttempts: Bool = true,
        maxTries: Int = 50000,
        seed: Int? = nil
    ) async throws -> MastermindPuzzle {
        return try await APIServiceFactory.getService().generateMastermind(
            codeLen: codeLen,
            numColors: numColors,
            allowRepeats: allowRepeats,
            avoidTrivial: avoidTrivial,
            maxAttempts: maxAttempts,
            enforceSolvableWithinAttempts: enforceSolvableWithinAttempts,
            maxTries: maxTries,
            seed: seed
        )
    }
    
    static func generateFloodfill(
        rows: Int = 12,
        cols: Int = 12,
        numColors: Int = 4,
        moveLimit: Int = 8,
        seed: Int? = nil,
        ensureSolvable: Bool = true,
        maxTries: Int = 500,
        noiseBlocks: Int = 14
    ) async throws -> FloodfillPuzzle {
        return try await APIServiceFactory.getService().generateFloodfill(
            rows: rows,
            cols: cols,
            numColors: numColors,
            moveLimit: moveLimit,
            seed: seed,
            ensureSolvable: ensureSolvable,
            maxTries: maxTries,
            noiseBlocks: noiseBlocks
        )
    }
    
    static func generateBridges(
        rows: Int = 9,
        cols: Int = 9,
        numNodes: Int = 16,
        extraEdgeFactor: Double = 0.40,
        doubleEdgeChance: Double = 0.35,
        seed: Int? = nil,
        maxTries: Int = 500
    ) async throws -> BridgesPuzzle {
        return try await APIServiceFactory.getService().generateBridges(
            rows: rows,
            cols: cols,
            numNodes: numNodes,
            extraEdgeFactor: extraEdgeFactor,
            doubleEdgeChance: doubleEdgeChance,
            seed: seed,
            maxTries: maxTries
        )
    }
    
    static func generateNumberSnake(
        rows: Int = 5,
        cols: Int = 5,
        numClues: Int = 6,
        seed: Int? = nil,
        keepEndpointsLabeled: Bool = true,
        maxTries: Int = 2000
    ) async throws -> NumberSnakePuzzle {
        return try await APIServiceFactory.getService().generateNumberSnake(
            rows: rows,
            cols: cols,
            numClues: numClues,
            seed: seed,
            keepEndpointsLabeled: keepEndpointsLabeled,
            maxTries: maxTries
        )
    }
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .apiError(let message):
            return message
        }
    }
}

// Response models
struct ShikakuPuzzleResponse: Codable {
    let success: Bool
    let rows: Int
    let cols: Int
    let board: [[Int]]
    let rectangles: [RectangleData]
    let numRectangles: Int
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case success, rows, cols, board, rectangles
        case numRectangles = "num_rectangles"
        case error
    }
}

struct RectangleData: Codable {
    let r0: Int
    let c0: Int
    let r1: Int
    let c1: Int
    let h: Int
    let w: Int
    let area: Int
}

// Puzzle model
struct ShikakuPuzzle {
    let rows: Int
    let cols: Int
    let board: [[Int]]  // 2D array where numbers indicate rectangle areas
    let rectangles: [RectangleData]
}

// Takuzu response models
struct TakuzuPuzzleResponse: Codable {
    let success: Bool
    let size: Int
    let puzzle: [[Int?]]  // None becomes nil in Swift
    let solution: [[Int]]
    let givensRatio: Double?
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case success, size, puzzle, solution
        case givensRatio = "givens_ratio"
        case error
    }
}

// Takuzu puzzle model
struct TakuzuPuzzle {
    let size: Int
    let puzzle: [[Int?]]  // nil = empty, 0 or 1 = given value
    let solution: [[Int]]  // Full solution (0 or 1)
}

// Star Battle response models
struct StarBattlePuzzleResponse: Codable {
    let success: Bool
    let size: Int
    let regions: [[Int]]  // n x n grid of region IDs
    let solutionStars: [[Bool]]  // n x n grid of star positions
    let starPositions: [StarPosition]?
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case success, size, regions
        case solutionStars = "solution_stars"
        case starPositions = "star_positions"
        case error
    }
}

struct StarPosition: Codable {
    let row: Int
    let col: Int
}

// Star Battle puzzle model
struct StarBattlePuzzle {
    let size: Int
    let regions: [[Int]]  // n x n grid of region IDs [0..n-1]
    let solutionStars: [[Bool]]  // n x n grid of star positions
    let starPositions: [StarPosition]
}

// Netwalk response models
struct NetwalkPuzzleResponse: Codable {
    let success: Bool
    let rows: Int
    let cols: Int
    let source: SourcePosition
    let puzzleMasks: [[Int]]
    let solutionMasks: [[Int]]
    let rotations: [[Int]]
    let tiles: [[NetwalkTileData]]
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case success, rows, cols, source
        case puzzleMasks = "puzzle_masks"
        case solutionMasks = "solution_masks"
        case rotations, tiles, error
    }
}

struct SourcePosition: Codable {
    let row: Int
    let col: Int
}

struct NetwalkTileData: Codable {
    let row: Int
    let col: Int
    let mask: Int
    let rotation: Int
    let openings: [String]
    let degree: Int
    let kind: String
    let isSource: Bool
    let isPowered: Bool
    
    enum CodingKeys: String, CodingKey {
        case row, col, mask, rotation, openings, degree, kind
        case isSource = "is_source"
        case isPowered = "is_powered"
    }
}

// Netwalk puzzle model
struct NetwalkPuzzle {
    let rows: Int
    let cols: Int
    let source: SourcePosition
    let puzzleMasks: [[Int]]  // Current masks (rotated)
    let solutionMasks: [[Int]]  // Solution masks (correct orientation)
    let rotations: [[Int]]  // Initial rotations
    let tiles: [[NetwalkTileData]]  // Tile metadata
}

// LITS response models
struct LITSPuzzleResponse: Codable {
    let success: Bool
    let rows: Int
    let cols: Int
    let regions: [[Int]]  // Region ID map
    let solutionShape: [[String?]]  // Shape letters (L/I/T/S) or nil
    let solutionFilled: [[Bool]]  // Filled cells
    let placements: [String: LITSPlacementData]  // Region ID -> placement
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case success, rows, cols, regions
        case solutionShape = "solution_shape"
        case solutionFilled = "solution_filled"
        case placements, error
    }
}

struct LITSPlacementData: Codable {
    let regionId: Int
    let shape: String
    let mask: Int
    let adjMask: Int
    let blocks: [Int]
    let cells: [[Int]]  // [[r, c], ...]
    
    enum CodingKeys: String, CodingKey {
        case regionId = "region_id"
        case shape, mask
        case adjMask = "adj_mask"
        case blocks, cells
    }
}

// LITS puzzle model
struct LITSPuzzle {
    let rows: Int
    let cols: Int
    let regions: [[Int]]  // Region ID map
    let solutionShape: [[String?]]  // Shape letters (L/I/T/S) or nil
    let solutionFilled: [[Bool]]  // Filled cells
    let placements: [String: LITSPlacementData]  // Region ID -> placement
}

// Mastermind/Tower response model
struct MastermindPuzzleResponse: Codable {
    let success: Bool
    let code: [Int]  // Secret code (color indices 0..num_colors-1)
    let codeLen: Int
    let numColors: Int
    let allowRepeats: Bool
    let maxAttempts: Int
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case success, code, error
        case codeLen = "code_len"
        case numColors = "num_colors"
        case allowRepeats = "allow_repeats"
        case maxAttempts = "max_attempts"
    }
}

// Mastermind/Tower puzzle model
struct MastermindPuzzle {
    let code: [Int]  // Secret code (color indices)
    let codeLen: Int
    let numColors: Int
    let allowRepeats: Bool
    let maxAttempts: Int
}

// Floodfill/Mosaic response model
struct FloodfillPuzzleResponse: Codable {
    let success: Bool
    let rows: Int
    let cols: Int
    let numColors: Int
    let moveLimit: Int
    let grid: [[Int]]  // Color indices 0..numColors-1
    let solution: [[Int]]?  // Optional solution moves [[r, c, new_color], ...]
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case success, rows, cols, grid, solution, error
        case numColors = "num_colors"
        case moveLimit = "move_limit"
    }
}

// Floodfill/Mosaic puzzle model
struct FloodfillPuzzle {
    let rows: Int
    let cols: Int
    let numColors: Int
    let moveLimit: Int
    let grid: [[Int]]  // Color indices
    let solution: [[Int]]?  // Optional solution
}

// Bridges response model
struct BridgesPuzzleResponse: Codable {
    let success: Bool
    let rows: Int
    let cols: Int
    let nodes: [BridgesNode]
    let solutionEdges: [BridgesEdge]
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case success, rows, cols, nodes, error
        case solutionEdges = "solution_edges"
    }
}

struct BridgesNode: Codable, Identifiable {
    let row: Int
    let col: Int
    let degree: Int
    
    var id: String { "\(row),\(col)" }
}

struct BridgesEdge: Codable {
    let u: Int
    let v: Int
    let count: Int
}

// Bridges puzzle model
struct BridgesPuzzle {
    let rows: Int
    let cols: Int
    let nodes: [BridgesNode]
    let solutionEdges: [BridgesEdge]
}

// Number Snake response model
struct NumberSnakePuzzleResponse: Codable {
    let success: Bool
    let rows: Int
    let cols: Int
    let clues: [NumberSnakeClue]
    let solutionPath: [[Int]]
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case success, rows, cols, clues, error
        case solutionPath = "solution_path"
    }
}

struct NumberSnakeClue: Codable, Identifiable {
    let value: Int
    let row: Int
    let col: Int
    
    var id: String { "\(row),\(col)" }
}

// Number Snake puzzle model
struct NumberSnakePuzzle {
    let rows: Int
    let cols: Int
    let clues: [NumberSnakeClue]
    let solutionPath: [[Int]]
}
