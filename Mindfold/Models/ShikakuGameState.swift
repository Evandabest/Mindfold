//
//  ShikakuGameState.swift
//  Mindfold
//
//  Created by Evan Haque on 1/9/26.
//

import Foundation
import SwiftUI

// Grid cell state
enum CellState: Equatable {
    case empty
    case hint(Int)  // Cell contains a hint number
    case occupied(color: Color, rectangleId: UUID, hintValue: Int?)  // Cell is part of a rectangle, may have hint
}

// Rectangle data
struct PlacedRectangle: Identifiable {
    let id: UUID
    let rect: GridRect
    let color: Color
    let hintValue: Int
}

// Grid rectangle (0-indexed)
struct GridRect: Equatable {
    let x: Int  // column (0-indexed)
    let y: Int  // row (0-indexed)
    let width: Int
    let height: Int
    
    var area: Int {
        width * height
    }
    
    // Check if this rect contains a specific point
    func contains(x: Int, y: Int) -> Bool {
        return x >= self.x && x < self.x + width &&
               y >= self.y && y < self.y + height
    }
    
    // Check if this rect intersects with another rect
    func intersects(with other: GridRect) -> Bool {
        return !(self.x + self.width <= other.x ||
                other.x + other.width <= self.x ||
                self.y + self.height <= other.y ||
                other.y + other.height <= self.y)
    }
    
    // Get all cells in this rectangle
    func allCells() -> [(x: Int, y: Int)] {
        var cells: [(x: Int, y: Int)] = []
        for y in y..<(y + height) {
            for x in x..<(x + width) {
                cells.append((x: x, y: y))
            }
        }
        return cells
    }
}

// Game state
class ShikakuGameState: ObservableObject {
    @Published var grid: [[CellState]]
    @Published var placedRectangles: [PlacedRectangle] = []
    @Published var isComplete: Bool = false
    @Published var updateTrigger: Int = 0  // Force view updates
    
    let rows: Int
    let cols: Int
    var hintPositions: [(x: Int, y: Int, value: Int)]  // Changed to var so it can be updated in reset()
    
    // Predefined colors for rectangles
    private let rectangleColors: [Color] = [
        .green,
        .blue,
        Color(red: 0.96, green: 0.96, blue: 0.86), // Beige
        .purple,
        .red,
        .orange,
        .cyan,
        .yellow,
        .pink
    ]
    private var nextColorIndex = 0
    
    init(rows: Int, cols: Int, board: [[Int]]) {
        self.rows = rows
        self.cols = cols
        
        // Initialize grid and extract hint positions
        var hints: [(x: Int, y: Int, value: Int)] = []
        var initialGrid = Array(repeating: Array(repeating: CellState.empty, count: cols), count: rows)
        
        for y in 0..<rows {
            for x in 0..<cols {
                if board[y][x] > 0 {
                    let value = board[y][x]
                    initialGrid[y][x] = .hint(value)
                    hints.append((x: x, y: y, value: value))
                }
            }
        }
        
        self.hintPositions = hints
        self.grid = initialGrid
    }
    
    // Reset game state with new board
    func reset(with board: [[Int]]) {
        // Reset grid and extract hint positions
        var newGrid = Array(repeating: Array(repeating: CellState.empty, count: cols), count: rows)
        var newHints: [(x: Int, y: Int, value: Int)] = []
        
        // Extract hints from the board
        for y in 0..<rows {
            for x in 0..<cols {
                if board[y][x] > 0 {
                    let value = board[y][x]
                    newGrid[y][x] = .hint(value)
                    newHints.append((x: x, y: y, value: value))
                }
            }
        }
        
        // Update grid and hint positions
        self.grid = newGrid
        self.hintPositions = newHints
        
        // Reset game state
        placedRectangles = []
        isComplete = false
        nextColorIndex = 0
        
        // Force UI update
        objectWillChange.send()
        
        print("✅ Reset complete. Found \(newHints.count) hints: \(newHints)")
    }
    
    // Get next color for a rectangle
    private func getNextColor() -> Color {
        let color = rectangleColors[nextColorIndex % rectangleColors.count]
        nextColorIndex += 1
        return color
    }
    
    // Validate and place a rectangle
    func placeRectangle(_ rect: GridRect) -> Bool {
        // Check bounds
        guard rect.x >= 0 && rect.y >= 0 &&
              rect.x + rect.width <= cols &&
              rect.y + rect.height <= rows else {
            print("❌ Validation failed: Out of bounds - x=\(rect.x), y=\(rect.y), w=\(rect.width), h=\(rect.height), cols=\(cols), rows=\(rows)")
            return false
        }
        
        // Check for collisions with existing rectangles
        for placedRect in placedRectangles {
            if rect.intersects(with: placedRect.rect) {
                print("❌ Validation failed: Collision with existing rectangle")
                return false
            }
        }
        
        // Check that all cells in rectangle are empty or contain hints (not already occupied)
        for cell in rect.allCells() {
            switch grid[cell.y][cell.x] {
            case .empty, .hint:
                break
            case .occupied:
                print("❌ Validation failed: Cell at (\(cell.x), \(cell.y)) is already occupied")
                return false  // Already occupied
            }
        }
        
        // Find hints within this rectangle
        var hintsInRect: [(x: Int, y: Int, value: Int)] = []
        for hint in hintPositions {
            if rect.contains(x: hint.x, y: hint.y) {
                hintsInRect.append(hint)
            }
        }
        
        // Must contain exactly one hint
        guard hintsInRect.count == 1 else {
            print("❌ Validation failed: Found \(hintsInRect.count) hints in rect (need exactly 1). Hints: \(hintsInRect)")
            return false
        }
        
        let hint = hintsInRect[0]
        let rectArea = rect.area
        
        // Area must match the hint value
        guard rectArea == hint.value else {
            print("❌ Validation failed: Area mismatch - rect area=\(rectArea), hint value=\(hint.value)")
            return false
        }
        
        // Valid! Place the rectangle
        let color = getNextColor()
        let placedRect = PlacedRectangle(
            id: UUID(),
            rect: rect,
            color: color,
            hintValue: hint.value
        )
        
        placedRectangles.append(placedRect)
        
        // Mark cells as occupied - preserve hint value if present
        // Create a new grid array to trigger @Published update
        var newGrid = grid
        for cell in rect.allCells() {
            let currentState = newGrid[cell.y][cell.x]
            let hintValue: Int?
            if case .hint(let value) = currentState {
                hintValue = value
            } else {
                hintValue = nil
            }
            newGrid[cell.y][cell.x] = .occupied(color: color, rectangleId: placedRect.id, hintValue: hintValue)
        }
        
        // Reassign grid to trigger @Published
        grid = newGrid
        
        // Force view update
        updateTrigger += 1
        
        // Check if game is complete
        checkCompletion()
        
        return true
    }
    
    // Remove a rectangle (for undo functionality)
    func removeRectangle(id: UUID) {
        guard let index = placedRectangles.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        let rect = placedRectangles[index].rect
        
        // Create a new grid array to trigger @Published update
        var newGrid = grid
        
        // Restore cells to their original state
        for cell in rect.allCells() {
            // Check if this cell had a hint (from the occupied state or original)
            if case .occupied(_, _, let hintValue) = newGrid[cell.y][cell.x], let hint = hintValue {
                newGrid[cell.y][cell.x] = .hint(hint)
            } else if let hint = hintPositions.first(where: { $0.x == cell.x && $0.y == cell.y }) {
                newGrid[cell.y][cell.x] = .hint(hint.value)
            } else {
                newGrid[cell.y][cell.x] = .empty
            }
        }
        
        grid = newGrid
        placedRectangles.remove(at: index)
        
        // Force UI update
        objectWillChange.send()
        
        checkCompletion()
    }
    
    // Find rectangle at a specific grid position
    func findRectangleAt(x: Int, y: Int) -> UUID? {
        for placedRect in placedRectangles {
            if placedRect.rect.contains(x: x, y: y) {
                return placedRect.id
            }
        }
        return nil
    }
    
    // Check if all hints are satisfied and grid is complete
    private func checkCompletion() {
        // Check if all cells are occupied
        var allOccupied = true
        for y in 0..<rows {
            for x in 0..<cols {
                if case .empty = grid[y][x] {
                    allOccupied = false
                    break
                }
            }
            if !allOccupied { break }
        }
        
        // Check if all hints are covered (either occupied or still showing as hint means not fully placed)
        var allHintsCovered = true
        for hint in hintPositions {
            switch grid[hint.y][hint.x] {
            case .hint:
                allHintsCovered = false
            case .occupied(_, _, _):
                // Hint is covered by a rectangle
                break
            case .empty:
                allHintsCovered = false
            }
        }
        
        isComplete = allOccupied && allHintsCovered
    }
    
    // Get the color for a cell
    func getCellColor(x: Int, y: Int) -> Color? {
        switch grid[y][x] {
        case .occupied(let color, _, _):
            return color
        default:
            return nil
        }
    }
}

