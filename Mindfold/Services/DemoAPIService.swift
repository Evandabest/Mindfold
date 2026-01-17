//
//  DemoAPIService.swift
//  Mindfold
//
//  Created by Evan Haque on 1/17/26.
//

import Foundation

class DemoAPIService: APIServiceProtocol {
    static let shared = DemoAPIService()
    
    private var demoData: [String: Any]?
    
    private init() {
        loadDemoData()
    }
    
    private func loadDemoData() {
        guard let url = Bundle.main.url(forResource: "sample_data", withExtension: "json") else {
            print("Could not find sample_data.json")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            demoData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print("Error loading demo data: \(error)")
        }
    }
    
    func generateShikaku(rows: Int = 8, cols: Int = 7, targetRects: Int? = nil, maxRectArea: Int? = nil, seed: Int? = nil) async throws -> ShikakuPuzzle {
        guard let demoData = demoData, let shikakuData = demoData["shikaku"] as? [String: Any] else {
            throw APIError.apiError("Demo data not available")
        }
        let jsonData = try JSONSerialization.data(withJSONObject: shikakuData)
        let decoder = JSONDecoder()
        let puzzle = try decoder.decode(ShikakuPuzzleResponse.self, from: jsonData)
        return ShikakuPuzzle(rows: puzzle.rows, cols: puzzle.cols, board: puzzle.board, rectangles: puzzle.rectangles)
    }
    
    func generateTakuzu(size: Int = 8, givensRatio: Double = 0.25, ensureUnique: Bool = true, seed: Int? = nil) async throws -> TakuzuPuzzle {
        guard let demoData = demoData, let takuzuData = demoData["takuzu"] as? [String: Any] else {
            throw APIError.apiError("Demo data not available")
        }
        let jsonData = try JSONSerialization.data(withJSONObject: takuzuData)
        let decoder = JSONDecoder()
        let puzzle = try decoder.decode(TakuzuPuzzleResponse.self, from: jsonData)
        return TakuzuPuzzle(size: puzzle.size, puzzle: puzzle.puzzle, solution: puzzle.solution)
    }
    
    func generateStarBattle(size: Int = 8, ensureUnique: Bool = false, seed: Int? = nil) async throws -> StarBattlePuzzle {
        guard let demoData = demoData, let starBattleData = demoData["starbattle"] as? [String: Any] else {
            throw APIError.apiError("Demo data not available")
        }
        let jsonData = try JSONSerialization.data(withJSONObject: starBattleData)
        let decoder = JSONDecoder()
        let puzzle = try decoder.decode(StarBattlePuzzleResponse.self, from: jsonData)
        return StarBattlePuzzle(size: puzzle.size, regions: puzzle.regions, solutionStars: puzzle.solutionStars, starPositions: puzzle.starPositions ?? [])
    }
    
    func generateNetwalk(rows: Int = 6, cols: Int = 6, seed: Int? = nil, allowCross: Bool = true, preferSourceDegree: Int = 2) async throws -> NetwalkPuzzle {
        guard let demoData = demoData, let netwalkData = demoData["netwalk"] as? [String: Any] else {
            throw APIError.apiError("Demo data not available")
        }
        let jsonData = try JSONSerialization.data(withJSONObject: netwalkData)
        let decoder = JSONDecoder()
        let puzzle = try decoder.decode(NetwalkPuzzleResponse.self, from: jsonData)
        return NetwalkPuzzle(rows: puzzle.rows, cols: puzzle.cols, source: puzzle.source, puzzleMasks: puzzle.puzzleMasks, solutionMasks: puzzle.solutionMasks, rotations: puzzle.rotations, tiles: puzzle.tiles)
    }
    
    func generateLITS(rows: Int = 6, cols: Int = 7, seed: Int? = nil, minRegionSize: Int = 4, maxRegionSize: Int = 8, ensureUnique: Bool = true, maxRegionAttempts: Int = 2000, maxSolveAttemptsPerRegionMap: Int = 500) async throws -> LITSPuzzle {
        guard let demoData = demoData, let litsData = demoData["lits"] as? [String: Any] else {
            throw APIError.apiError("Demo data not available")
        }
        let jsonData = try JSONSerialization.data(withJSONObject: litsData)
        let decoder = JSONDecoder()
        let puzzle = try decoder.decode(LITSPuzzleResponse.self, from: jsonData)
        return LITSPuzzle(rows: puzzle.rows, cols: puzzle.cols, regions: puzzle.regions, solutionShape: puzzle.solutionShape, solutionFilled: puzzle.solutionFilled, placements: puzzle.placements)
    }
    
    func generateMastermind(codeLen: Int = 4, numColors: Int = 4, allowRepeats: Bool = true, avoidTrivial: Bool = true, maxAttempts: Int = 10, enforceSolvableWithinAttempts: Bool = true, maxTries: Int = 50000, seed: Int? = nil) async throws -> MastermindPuzzle {
        guard let demoData = demoData, let mastermindData = demoData["mastermind"] as? [String: Any] else {
            throw APIError.apiError("Demo data not available")
        }
        let jsonData = try JSONSerialization.data(withJSONObject: mastermindData)
        let decoder = JSONDecoder()
        let puzzle = try decoder.decode(MastermindPuzzleResponse.self, from: jsonData)
        return MastermindPuzzle(code: puzzle.code, codeLen: puzzle.codeLen, numColors: puzzle.numColors, allowRepeats: puzzle.allowRepeats, maxAttempts: puzzle.maxAttempts)
    }
    
    func generateFloodfill(rows: Int = 12, cols: Int = 12, numColors: Int = 4, moveLimit: Int = 8, seed: Int? = nil, ensureSolvable: Bool = true, maxTries: Int = 500, noiseBlocks: Int = 14) async throws -> FloodfillPuzzle {
        guard let demoData = demoData, let floodfillData = demoData["floodfill"] as? [String: Any] else {
            throw APIError.apiError("Demo data not available")
        }
        let jsonData = try JSONSerialization.data(withJSONObject: floodfillData)
        let decoder = JSONDecoder()
        let puzzle = try decoder.decode(FloodfillPuzzleResponse.self, from: jsonData)
        return FloodfillPuzzle(rows: puzzle.rows, cols: puzzle.cols, numColors: puzzle.numColors, moveLimit: puzzle.moveLimit, grid: puzzle.grid, solution: puzzle.solution)
    }
    
    func generateBridges(rows: Int = 9, cols: Int = 9, numNodes: Int = 16, extraEdgeFactor: Double = 0.40, doubleEdgeChance: Double = 0.35, seed: Int? = nil, maxTries: Int = 500) async throws -> BridgesPuzzle {
        guard let demoData = demoData, let bridgesData = demoData["bridges"] as? [String: Any] else {
            throw APIError.apiError("Demo data not available")
        }
        let jsonData = try JSONSerialization.data(withJSONObject: bridgesData)
        let decoder = JSONDecoder()
        let puzzle = try decoder.decode(BridgesPuzzleResponse.self, from: jsonData)
        return BridgesPuzzle(rows: puzzle.rows, cols: puzzle.cols, nodes: puzzle.nodes, solutionEdges: puzzle.solutionEdges)
    }
    
    func generateNumberSnake(rows: Int = 5, cols: Int = 5, numClues: Int = 6, seed: Int? = nil, keepEndpointsLabeled: Bool = true, maxTries: Int = 2000) async throws -> NumberSnakePuzzle {
        guard let demoData = demoData, let numbersnakeData = demoData["numbersnake"] as? [String: Any] else {
            throw APIError.apiError("Demo data not available")
        }
        let jsonData = try JSONSerialization.data(withJSONObject: numbersnakeData)
        let decoder = JSONDecoder()
        let puzzle = try decoder.decode(NumberSnakePuzzleResponse.self, from: jsonData)
        return NumberSnakePuzzle(rows: puzzle.rows, cols: puzzle.cols, clues: puzzle.clues, solutionPath: puzzle.solutionPath)
    }
}
