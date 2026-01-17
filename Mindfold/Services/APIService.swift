//
//  APIService.swift
//  Mindfold
//
//  Created by Evan Haque on 1/9/26.
//

import Foundation

class APIService {
    // API base URL from environment variable, Info.plist, or default
    private static var baseURL: String {
        if let url = ProcessInfo.processInfo.environment["API_BASE_URL"], !url.isEmpty {
            return url
        }
        if let url = Bundle.main.infoDictionary?["API_BASE_URL"] as? String, !url.isEmpty {
            return url
        }
        return "http://localhost:8000"
    }
    
    // Demo data cache
    private static var demoDataCache: [String: Any]?
    
    private static func loadDemoData<T: Decodable>(for gameType: String) throws -> T {
        // Load and cache demo data
        if demoDataCache == nil {
            guard let url = Bundle.main.url(forResource: "sample_data", withExtension: "json") else {
                throw APIError.apiError("Could not find sample_data.json")
            }
            let data = try Data(contentsOf: url)
            demoDataCache = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        }
        
        guard let demoData = demoDataCache,
              let gameData = demoData[gameType] as? [String: Any] else {
            throw APIError.apiError("Demo data not available for \(gameType)")
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: gameData)
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: jsonData)
    }
    
    static func generateShikaku(
        rows: Int = 8,
        cols: Int = 7,
        targetRects: Int? = nil,
        maxRectArea: Int? = nil,
        seed: Int? = nil
    ) async throws -> ShikakuPuzzle {
        if SettingsManager.shared.demoModeEnabled {
            let response: ShikakuPuzzleResponse = try loadDemoData(for: "shikaku")
            return ShikakuPuzzle(rows: response.rows, cols: response.cols, board: response.board, rectangles: response.rectangles)
        }
        
        var components = URLComponents(string: "\(baseURL)/api/generate/shikaku")!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "rows", value: String(rows)),
            URLQueryItem(name: "cols", value: String(cols))
        ]
        if let targetRects = targetRects {
            queryItems.append(URLQueryItem(name: "target_rects", value: String(targetRects)))
        }
        if let maxRectArea = maxRectArea {
            queryItems.append(URLQueryItem(name: "max_rect_area", value: String(maxRectArea)))
        }
        if let seed = seed {
            queryItems.append(URLQueryItem(name: "seed", value: String(seed)))
        }
        components.queryItems = queryItems
        
        guard let url = components.url else { throw APIError.invalidURL }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let puzzle = try JSONDecoder().decode(ShikakuPuzzleResponse.self, from: data)
        guard puzzle.success else { throw APIError.apiError(puzzle.error ?? "Unknown error") }
        
        return ShikakuPuzzle(rows: puzzle.rows, cols: puzzle.cols, board: puzzle.board, rectangles: puzzle.rectangles)
    }
    
    static func generateTakuzu(
        size: Int = 8,
        givensRatio: Double = 0.25,
        ensureUnique: Bool = true,
        seed: Int? = nil
    ) async throws -> TakuzuPuzzle {
        if SettingsManager.shared.demoModeEnabled {
            let response: TakuzuPuzzleResponse = try loadDemoData(for: "takuzu")
            return TakuzuPuzzle(size: response.size, puzzle: response.puzzle, solution: response.solution)
        }
        
        var components = URLComponents(string: "\(baseURL)/api/generate/takuzu")!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "size", value: String(size)),
            URLQueryItem(name: "givens_ratio", value: String(givensRatio)),
            URLQueryItem(name: "ensure_unique", value: String(ensureUnique))
        ]
        if let seed = seed {
            queryItems.append(URLQueryItem(name: "seed", value: String(seed)))
        }
        components.queryItems = queryItems
        
        guard let url = components.url else { throw APIError.invalidURL }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let puzzle = try JSONDecoder().decode(TakuzuPuzzleResponse.self, from: data)
        guard puzzle.success else { throw APIError.apiError(puzzle.error ?? "Unknown error") }
        
        return TakuzuPuzzle(size: puzzle.size, puzzle: puzzle.puzzle, solution: puzzle.solution)
    }
    
    static func generateStarBattle(
        size: Int = 8,
        ensureUnique: Bool = false,
        seed: Int? = nil
    ) async throws -> StarBattlePuzzle {
        if SettingsManager.shared.demoModeEnabled {
            let response: StarBattlePuzzleResponse = try loadDemoData(for: "starbattle")
            return StarBattlePuzzle(size: response.size, regions: response.regions, solutionStars: response.solutionStars, starPositions: response.starPositions ?? [])
        }
        
        var components = URLComponents(string: "\(baseURL)/api/generate/starbattle")!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "size", value: String(size)),
            URLQueryItem(name: "ensure_unique", value: String(ensureUnique))
        ]
        if let seed = seed {
            queryItems.append(URLQueryItem(name: "seed", value: String(seed)))
        }
        components.queryItems = queryItems
        
        guard let url = components.url else { throw APIError.invalidURL }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let puzzle = try JSONDecoder().decode(StarBattlePuzzleResponse.self, from: data)
        guard puzzle.success else { throw APIError.apiError(puzzle.error ?? "Unknown error") }
        
        return StarBattlePuzzle(size: puzzle.size, regions: puzzle.regions, solutionStars: puzzle.solutionStars, starPositions: puzzle.starPositions ?? [])
    }
    
    static func generateNetwalk(
        rows: Int = 6,
        cols: Int = 6,
        seed: Int? = nil,
        allowCross: Bool = true,
        preferSourceDegree: Int = 2
    ) async throws -> NetwalkPuzzle {
        if SettingsManager.shared.demoModeEnabled {
            let response: NetwalkPuzzleResponse = try loadDemoData(for: "netwalk")
            return NetwalkPuzzle(rows: response.rows, cols: response.cols, source: response.source, puzzleMasks: response.puzzleMasks, solutionMasks: response.solutionMasks, rotations: response.rotations, tiles: response.tiles)
        }
        
        var components = URLComponents(string: "\(baseURL)/api/generate/netwalk")!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "rows", value: String(rows)),
            URLQueryItem(name: "cols", value: String(cols)),
            URLQueryItem(name: "allow_cross", value: String(allowCross)),
            URLQueryItem(name: "prefer_source_degree_at_least", value: String(preferSourceDegree))
        ]
        if let seed = seed {
            queryItems.append(URLQueryItem(name: "seed", value: String(seed)))
        }
        components.queryItems = queryItems
        
        guard let url = components.url else { throw APIError.invalidURL }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let puzzle = try JSONDecoder().decode(NetwalkPuzzleResponse.self, from: data)
        guard puzzle.success else { throw APIError.apiError(puzzle.error ?? "Unknown error") }
        
        return NetwalkPuzzle(rows: puzzle.rows, cols: puzzle.cols, source: puzzle.source, puzzleMasks: puzzle.puzzleMasks, solutionMasks: puzzle.solutionMasks, rotations: puzzle.rotations, tiles: puzzle.tiles)
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
        if SettingsManager.shared.demoModeEnabled {
            let response: LITSPuzzleResponse = try loadDemoData(for: "lits")
            return LITSPuzzle(rows: response.rows, cols: response.cols, regions: response.regions, solutionShape: response.solutionShape, solutionFilled: response.solutionFilled, placements: response.placements)
        }
        
        var components = URLComponents(string: "\(baseURL)/api/generate/lits")!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "rows", value: String(rows)),
            URLQueryItem(name: "cols", value: String(cols)),
            URLQueryItem(name: "min_region_size", value: String(minRegionSize)),
            URLQueryItem(name: "max_region_size", value: String(maxRegionSize)),
            URLQueryItem(name: "ensure_unique", value: String(ensureUnique)),
            URLQueryItem(name: "max_region_attempts", value: String(maxRegionAttempts)),
            URLQueryItem(name: "max_solve_attempts_per_region_map", value: String(maxSolveAttemptsPerRegionMap))
        ]
        if let seed = seed {
            queryItems.append(URLQueryItem(name: "seed", value: String(seed)))
        }
        components.queryItems = queryItems
        
        guard let url = components.url else { throw APIError.invalidURL }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let puzzle = try JSONDecoder().decode(LITSPuzzleResponse.self, from: data)
        guard puzzle.success else { throw APIError.apiError(puzzle.error ?? "Unknown error") }
        
        return LITSPuzzle(rows: puzzle.rows, cols: puzzle.cols, regions: puzzle.regions, solutionShape: puzzle.solutionShape, solutionFilled: puzzle.solutionFilled, placements: puzzle.placements)
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
        if SettingsManager.shared.demoModeEnabled {
            let response: MastermindPuzzleResponse = try loadDemoData(for: "mastermind")
            return MastermindPuzzle(code: response.code, codeLen: response.codeLen, numColors: response.numColors, allowRepeats: response.allowRepeats, maxAttempts: response.maxAttempts)
        }
        
        var components = URLComponents(string: "\(baseURL)/api/generate/mastermind")!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "code_len", value: String(codeLen)),
            URLQueryItem(name: "num_colors", value: String(numColors)),
            URLQueryItem(name: "allow_repeats", value: String(allowRepeats)),
            URLQueryItem(name: "avoid_trivial", value: String(avoidTrivial)),
            URLQueryItem(name: "max_attempts", value: String(maxAttempts)),
            URLQueryItem(name: "enforce_solvable_within_attempts", value: String(enforceSolvableWithinAttempts)),
            URLQueryItem(name: "max_tries", value: String(maxTries))
        ]
        if let seed = seed {
            queryItems.append(URLQueryItem(name: "seed", value: String(seed)))
        }
        components.queryItems = queryItems
        
        guard let url = components.url else { throw APIError.invalidURL }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let puzzle = try JSONDecoder().decode(MastermindPuzzleResponse.self, from: data)
        guard puzzle.success else { throw APIError.apiError(puzzle.error ?? "Unknown error") }
        
        return MastermindPuzzle(code: puzzle.code, codeLen: puzzle.codeLen, numColors: puzzle.numColors, allowRepeats: puzzle.allowRepeats, maxAttempts: puzzle.maxAttempts)
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
        if SettingsManager.shared.demoModeEnabled {
            let response: FloodfillPuzzleResponse = try loadDemoData(for: "floodfill")
            return FloodfillPuzzle(rows: response.rows, cols: response.cols, numColors: response.numColors, moveLimit: response.moveLimit, grid: response.grid, solution: response.solution)
        }
        
        var components = URLComponents(string: "\(baseURL)/api/generate/floodfill")!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "rows", value: String(rows)),
            URLQueryItem(name: "cols", value: String(cols)),
            URLQueryItem(name: "num_colors", value: String(numColors)),
            URLQueryItem(name: "move_limit", value: String(moveLimit)),
            URLQueryItem(name: "ensure_solvable", value: String(ensureSolvable)),
            URLQueryItem(name: "max_tries", value: String(maxTries)),
            URLQueryItem(name: "noise_blocks", value: String(noiseBlocks))
        ]
        if let seed = seed {
            queryItems.append(URLQueryItem(name: "seed", value: String(seed)))
        }
        components.queryItems = queryItems
        
        guard let url = components.url else { throw APIError.invalidURL }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let puzzle = try JSONDecoder().decode(FloodfillPuzzleResponse.self, from: data)
        guard puzzle.success else { throw APIError.apiError(puzzle.error ?? "Unknown error") }
        
        return FloodfillPuzzle(rows: puzzle.rows, cols: puzzle.cols, numColors: puzzle.numColors, moveLimit: puzzle.moveLimit, grid: puzzle.grid, solution: puzzle.solution)
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
        if SettingsManager.shared.demoModeEnabled {
            let response: BridgesPuzzleResponse = try loadDemoData(for: "bridges")
            return BridgesPuzzle(rows: response.rows, cols: response.cols, nodes: response.nodes, solutionEdges: response.solutionEdges)
        }
        
        var components = URLComponents(string: "\(baseURL)/api/generate/bridges")!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "rows", value: String(rows)),
            URLQueryItem(name: "cols", value: String(cols)),
            URLQueryItem(name: "num_nodes", value: String(numNodes)),
            URLQueryItem(name: "extra_edge_factor", value: String(extraEdgeFactor)),
            URLQueryItem(name: "double_edge_chance", value: String(doubleEdgeChance)),
            URLQueryItem(name: "max_tries", value: String(maxTries))
        ]
        if let seed = seed {
            queryItems.append(URLQueryItem(name: "seed", value: String(seed)))
        }
        components.queryItems = queryItems
        
        guard let url = components.url else { throw APIError.invalidURL }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let puzzle = try JSONDecoder().decode(BridgesPuzzleResponse.self, from: data)
        guard puzzle.success else { throw APIError.invalidResponse }
        
        return BridgesPuzzle(rows: puzzle.rows, cols: puzzle.cols, nodes: puzzle.nodes, solutionEdges: puzzle.solutionEdges)
    }
    
    static func generateNumberSnake(
        rows: Int = 5,
        cols: Int = 5,
        numClues: Int = 6,
        seed: Int? = nil,
        keepEndpointsLabeled: Bool = true,
        maxTries: Int = 2000
    ) async throws -> NumberSnakePuzzle {
        if SettingsManager.shared.demoModeEnabled {
            let response: NumberSnakePuzzleResponse = try loadDemoData(for: "numbersnake")
            return NumberSnakePuzzle(rows: response.rows, cols: response.cols, clues: response.clues, solutionPath: response.solutionPath)
        }
        
        var components = URLComponents(string: "\(baseURL)/api/generate/numbersnake")!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "rows", value: String(rows)),
            URLQueryItem(name: "cols", value: String(cols)),
            URLQueryItem(name: "num_clues", value: String(numClues)),
            URLQueryItem(name: "keep_endpoints_labeled", value: String(keepEndpointsLabeled)),
            URLQueryItem(name: "max_tries", value: String(maxTries))
        ]
        if let seed = seed {
            queryItems.append(URLQueryItem(name: "seed", value: String(seed)))
        }
        components.queryItems = queryItems
        
        guard let url = components.url else { throw APIError.invalidURL }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let puzzle = try JSONDecoder().decode(NumberSnakePuzzleResponse.self, from: data)
        guard puzzle.success else { throw APIError.invalidResponse }
        
        return NumberSnakePuzzle(rows: puzzle.rows, cols: puzzle.cols, clues: puzzle.clues, solutionPath: puzzle.solutionPath)
    }
}

// MARK: - Error Types
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

// MARK: - Response Models
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

struct ShikakuPuzzle {
    let rows: Int
    let cols: Int
    let board: [[Int]]
    let rectangles: [RectangleData]
}

struct TakuzuPuzzleResponse: Codable {
    let success: Bool
    let size: Int
    let puzzle: [[Int?]]
    let solution: [[Int]]
    let givensRatio: Double?
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case success, size, puzzle, solution
        case givensRatio = "givens_ratio"
        case error
    }
}

struct TakuzuPuzzle {
    let size: Int
    let puzzle: [[Int?]]
    let solution: [[Int]]
}

struct StarBattlePuzzleResponse: Codable {
    let success: Bool
    let size: Int
    let regions: [[Int]]
    let solutionStars: [[Bool]]
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

struct StarBattlePuzzle {
    let size: Int
    let regions: [[Int]]
    let solutionStars: [[Bool]]
    let starPositions: [StarPosition]
}

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

struct NetwalkPuzzle {
    let rows: Int
    let cols: Int
    let source: SourcePosition
    let puzzleMasks: [[Int]]
    let solutionMasks: [[Int]]
    let rotations: [[Int]]
    let tiles: [[NetwalkTileData]]
}

struct LITSPuzzleResponse: Codable {
    let success: Bool
    let rows: Int
    let cols: Int
    let regions: [[Int]]
    let solutionShape: [[String?]]
    let solutionFilled: [[Bool]]
    let placements: [String: LITSPlacementData]
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
    let cells: [[Int]]
    
    enum CodingKeys: String, CodingKey {
        case regionId = "region_id"
        case shape, mask
        case adjMask = "adj_mask"
        case blocks, cells
    }
}

struct LITSPuzzle {
    let rows: Int
    let cols: Int
    let regions: [[Int]]
    let solutionShape: [[String?]]
    let solutionFilled: [[Bool]]
    let placements: [String: LITSPlacementData]
}

struct MastermindPuzzleResponse: Codable {
    let success: Bool
    let code: [Int]
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

struct MastermindPuzzle {
    let code: [Int]
    let codeLen: Int
    let numColors: Int
    let allowRepeats: Bool
    let maxAttempts: Int
}

struct FloodfillPuzzleResponse: Codable {
    let success: Bool
    let rows: Int
    let cols: Int
    let numColors: Int
    let moveLimit: Int
    let grid: [[Int]]
    let solution: [[Int]]?
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case success, rows, cols, grid, solution, error
        case numColors = "num_colors"
        case moveLimit = "move_limit"
    }
}

struct FloodfillPuzzle {
    let rows: Int
    let cols: Int
    let numColors: Int
    let moveLimit: Int
    let grid: [[Int]]
    let solution: [[Int]]?
}

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

struct BridgesPuzzle {
    let rows: Int
    let cols: Int
    let nodes: [BridgesNode]
    let solutionEdges: [BridgesEdge]
}

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

struct NumberSnakePuzzle {
    let rows: Int
    let cols: Int
    let clues: [NumberSnakeClue]
    let solutionPath: [[Int]]
}
