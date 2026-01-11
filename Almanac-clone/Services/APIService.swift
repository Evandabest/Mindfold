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

