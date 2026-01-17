//
//  APIServiceProtocol.swift
//  Mindfold
//
//  Created by Evan Haque on 1/17/26.
//

import Foundation

protocol APIServiceProtocol {
    func generateShikaku(rows: Int, cols: Int, targetRects: Int?, maxRectArea: Int?, seed: Int?) async throws -> ShikakuPuzzle
    func generateTakuzu(size: Int, givensRatio: Double, ensureUnique: Bool, seed: Int?) async throws -> TakuzuPuzzle
    func generateStarBattle(size: Int, ensureUnique: Bool, seed: Int?) async throws -> StarBattlePuzzle
    func generateNetwalk(rows: Int, cols: Int, seed: Int?, allowCross: Bool, preferSourceDegree: Int) async throws -> NetwalkPuzzle
    func generateLITS(rows: Int, cols: Int, seed: Int?, minRegionSize: Int, maxRegionSize: Int, ensureUnique: Bool, maxRegionAttempts: Int, maxSolveAttemptsPerRegionMap: Int) async throws -> LITSPuzzle
    func generateMastermind(codeLen: Int, numColors: Int, allowRepeats: Bool, avoidTrivial: Bool, maxAttempts: Int, enforceSolvableWithinAttempts: Bool, maxTries: Int, seed: Int?) async throws -> MastermindPuzzle
    func generateFloodfill(rows: Int, cols: Int, numColors: Int, moveLimit: Int, seed: Int?, ensureSolvable: Bool, maxTries: Int, noiseBlocks: Int) async throws -> FloodfillPuzzle
    func generateBridges(rows: Int, cols: Int, numNodes: Int, extraEdgeFactor: Double, doubleEdgeChance: Double, seed: Int?, maxTries: Int) async throws -> BridgesPuzzle
    func generateNumberSnake(rows: Int, cols: Int, numClues: Int, seed: Int?, keepEndpointsLabeled: Bool, maxTries: Int) async throws -> NumberSnakePuzzle
}

// Factory to get the appropriate service based on demo mode
class APIServiceFactory {
    static func getService() -> APIServiceProtocol {
        if SettingsManager.shared.demoModeEnabled {
            return DemoAPIService.shared
        } else {
            return ProductionAPIService.shared
        }
    }
}
