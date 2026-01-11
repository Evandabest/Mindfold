//
//  APIService.swift
//  Almanac-clone
//
//  Created by Evan Haque on 1/9/26.
//

import Foundation

class APIService {
    // API base URL from environment variable, Info.plist, or default
    static var baseURL: String {
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
    
    static func generateShikaku(
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
    
    static func generateTakuzu(
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
    
    static func generateStarBattle(
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

