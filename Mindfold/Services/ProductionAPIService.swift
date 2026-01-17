//
//  ProductionAPIService.swift
//  Mindfold
//
//  Created by Evan Haque on 1/17/26.
//

import Foundation

// Production API Service that makes real HTTP calls
class ProductionAPIService: APIServiceProtocol {
    static let shared = ProductionAPIService()
    
    private init() {}
    
    // API base URL from environment variable, Info.plist, or default
    private var baseURL: String {
        // First check environment variable (can be set in Xcode scheme or command line)
        if let url = ProcessInfo.processInfo.environment["API_BASE_URL"], !url.isEmpty {
            return url
        }
        
        // Then check Info.plist
        if let url = Bundle.main.infoDictionary?["API_BASE_URL"] as? String, !url.isEmpty {
            return url
        }
        
        // Default fallback
        return "http://localhost:6000"
    }
    
    func generateShikaku(
        rows: Int = 8,
        cols: Int = 7,
        targetRects: Int? = nil,
        maxRectArea: Int? = nil,
        seed: Int? = nil
    ) async throws -> ShikakuPuzzle {
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
        
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        let puzzle = try decoder.decode(ShikakuPuzzleResponse.self, from: data)
        
        guard puzzle.success else {
            throw APIError.apiError(puzzle.error ?? "Unknown error")
        }
        
        return ShikakuPuzzle(
            rows: puzzle.rows,
            cols: puzzle.cols,
            board: puzzle.board,
            rectangles: puzzle.rectangles
        )
    }
    
    func generateTakuzu(
        size: Int = 8,
        givensRatio: Double = 0.25,
        ensureUnique: Bool = true,
        seed: Int? = nil
    ) async throws -> TakuzuPuzzle {
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
        
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        let puzzle = try decoder.decode(TakuzuPuzzleResponse.self, from: data)
        
        guard puzzle.success else {
            throw APIError.apiError(puzzle.error ?? "Unknown error")
        }
        
        return TakuzuPuzzle(
            size: puzzle.size,
            puzzle: puzzle.puzzle,
            solution: puzzle.solution
        )
    }
    
    func generateStarBattle(
        size: Int = 8,
        ensureUnique: Bool = false,
        seed: Int? = nil
    ) async throws -> StarBattlePuzzle {
        var components = URLComponents(string: "\(baseURL)/api/generate/starbattle")!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "size", value: String(size)),
            URLQueryItem(name: "ensure_unique", value: String(ensureUnique))
        ]
        
        if let seed = seed {
            queryItems.append(URLQueryItem(name: "seed", value: String(seed)))
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        let puzzle = try decoder.decode(StarBattlePuzzleResponse.self, from: data)
        
        guard puzzle.success else {
            throw APIError.apiError(puzzle.error ?? "Unknown error")
        }
        
        return StarBattlePuzzle(
            size: puzzle.size,
            regions: puzzle.regions,
            solutionStars: puzzle.solutionStars,
            starPositions: puzzle.starPositions ?? []
        )
    }
    
    func generateNetwalk(
        rows: Int = 6,
        cols: Int = 6,
        seed: Int? = nil,
        allowCross: Bool = true,
        preferSourceDegree: Int = 2
    ) async throws -> NetwalkPuzzle {
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
        
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        let puzzle = try decoder.decode(NetwalkPuzzleResponse.self, from: data)
        
        guard puzzle.success else {
            throw APIError.apiError(puzzle.error ?? "Unknown error")
        }
        
        return NetwalkPuzzle(
            rows: puzzle.rows,
            cols: puzzle.cols,
            source: puzzle.source,
            puzzleMasks: puzzle.puzzleMasks,
            solutionMasks: puzzle.solutionMasks,
            rotations: puzzle.rotations,
            tiles: puzzle.tiles
        )
    }
    
    func generateLITS(
        rows: Int = 6,
        cols: Int = 7,
        seed: Int? = nil,
        minRegionSize: Int = 4,
        maxRegionSize: Int = 8,
        ensureUnique: Bool = true,
        maxRegionAttempts: Int = 2000,
        maxSolveAttemptsPerRegionMap: Int = 500
    ) async throws -> LITSPuzzle {
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
        
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        let puzzle = try decoder.decode(LITSPuzzleResponse.self, from: data)
        
        guard puzzle.success else {
            throw APIError.apiError(puzzle.error ?? "Unknown error")
        }
        
        return LITSPuzzle(
            rows: puzzle.rows,
            cols: puzzle.cols,
            regions: puzzle.regions,
            solutionShape: puzzle.solutionShape,
            solutionFilled: puzzle.solutionFilled,
            placements: puzzle.placements
        )
    }
    
    func generateMastermind(
        codeLen: Int = 4,
        numColors: Int = 4,
        allowRepeats: Bool = true,
        avoidTrivial: Bool = true,
        maxAttempts: Int = 10,
        enforceSolvableWithinAttempts: Bool = true,
        maxTries: Int = 50000,
        seed: Int? = nil
    ) async throws -> MastermindPuzzle {
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
        
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        let puzzle = try decoder.decode(MastermindPuzzleResponse.self, from: data)
        
        guard puzzle.success else {
            throw APIError.apiError(puzzle.error ?? "Unknown error")
        }
        
        return MastermindPuzzle(
            code: puzzle.code,
            codeLen: puzzle.codeLen,
            numColors: puzzle.numColors,
            allowRepeats: puzzle.allowRepeats,
            maxAttempts: puzzle.maxAttempts
        )
    }
    
    func generateFloodfill(
        rows: Int = 12,
        cols: Int = 12,
        numColors: Int = 4,
        moveLimit: Int = 8,
        seed: Int? = nil,
        ensureSolvable: Bool = true,
        maxTries: Int = 500,
        noiseBlocks: Int = 14
    ) async throws -> FloodfillPuzzle {
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
        
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        let puzzle = try decoder.decode(FloodfillPuzzleResponse.self, from: data)
        
        guard puzzle.success else {
            throw APIError.apiError(puzzle.error ?? "Unknown error")
        }
        
        return FloodfillPuzzle(
            rows: puzzle.rows,
            cols: puzzle.cols,
            numColors: puzzle.numColors,
            moveLimit: puzzle.moveLimit,
            grid: puzzle.grid,
            solution: puzzle.solution
        )
    }
    
    func generateBridges(
        rows: Int = 9,
        cols: Int = 9,
        numNodes: Int = 16,
        extraEdgeFactor: Double = 0.40,
        doubleEdgeChance: Double = 0.35,
        seed: Int? = nil,
        maxTries: Int = 500
    ) async throws -> BridgesPuzzle {
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
        
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        let puzzle = try decoder.decode(BridgesPuzzleResponse.self, from: data)
        
        guard puzzle.success else {
            throw APIError.invalidResponse
        }
        
        return BridgesPuzzle(
            rows: puzzle.rows,
            cols: puzzle.cols,
            nodes: puzzle.nodes,
            solutionEdges: puzzle.solutionEdges
        )
    }
    
    func generateNumberSnake(
        rows: Int = 5,
        cols: Int = 5,
        numClues: Int = 6,
        seed: Int? = nil,
        keepEndpointsLabeled: Bool = true,
        maxTries: Int = 2000
    ) async throws -> NumberSnakePuzzle {
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
        
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        let puzzle = try decoder.decode(NumberSnakePuzzleResponse.self, from: data)
        
        guard puzzle.success else {
            throw APIError.invalidResponse
        }
        
        return NumberSnakePuzzle(
            rows: puzzle.rows,
            cols: puzzle.cols,
            clues: puzzle.clues,
            solutionPath: puzzle.solutionPath
        )
    }
}
