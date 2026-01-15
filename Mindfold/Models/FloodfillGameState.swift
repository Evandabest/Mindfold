//
//  FloodfillGameState.swift
//  Mindfold
//
//  Created by Evan Haque on 1/15/26.
//

import SwiftUI

class FloodfillGameState: ObservableObject {
    // Game configuration
    let rows: Int
    let cols: Int
    let numColors: Int
    let moveLimit: Int
    let initialGrid: [[Int]]
    
    // Game state
    @Published var grid: [[Int]]
    @Published var movesRemaining: Int
    @Published var selectedColorIndex: Int = 0
    @Published var isComplete: Bool = false
    @Published var isWon: Bool = false
    @Published var moveHistory: [[[Int]]] = []  // Stack of previous grids for undo
    
    // Color palette
    static let colorPalette: [Color] = [
        Color(red: 0.4, green: 0.9, blue: 0.9),   // Cyan
        Color(red: 0.7, green: 0.5, blue: 0.9),   // Purple  
        Color(red: 0.5, green: 0.7, blue: 1.0),   // Blue
        Color(white: 0.5),                         // Gray
        Color(red: 1.0, green: 0.7, blue: 0.3),   // Orange
        Color(red: 0.4, green: 0.9, blue: 0.5),   // Green
        Color(red: 1.0, green: 0.5, blue: 0.6),   // Pink
        Color(red: 1.0, green: 0.9, blue: 0.3),   // Yellow
    ]
    
    init(puzzle: FloodfillPuzzle) {
        self.rows = puzzle.rows
        self.cols = puzzle.cols
        self.numColors = puzzle.numColors
        self.moveLimit = puzzle.moveLimit
        self.initialGrid = puzzle.grid
        self.grid = puzzle.grid
        self.movesRemaining = puzzle.moveLimit
    }
    
    // For preview/testing
    init(rows: Int = 12, cols: Int = 12, numColors: Int = 4, moveLimit: Int = 4) {
        self.rows = rows
        self.cols = cols
        self.numColors = numColors
        self.moveLimit = moveLimit
        
        // Create a simple test grid
        var testGrid: [[Int]] = []
        for _ in 0..<rows {
            var row: [Int] = []
            for _ in 0..<cols {
                row.append(Int.random(in: 0..<numColors))
            }
            testGrid.append(row)
        }
        self.initialGrid = testGrid
        self.grid = testGrid
        self.movesRemaining = moveLimit
    }
    
    // Update with new puzzle
    func update(with puzzle: FloodfillPuzzle) {
        // Can't change let properties, but we can reset the game
        self.grid = puzzle.grid
        self.movesRemaining = puzzle.moveLimit
        self.selectedColorIndex = 0
        self.isComplete = false
        self.isWon = false
        self.moveHistory = []
        objectWillChange.send()
    }
    
    // Get color for a color index
    func getColor(for index: Int) -> Color {
        guard index >= 0 && index < Self.colorPalette.count else {
            return .gray
        }
        return Self.colorPalette[index]
    }
    
    // Get the connected component starting from (row, col)
    private func getComponent(row: Int, col: Int) -> Set<GridPosition> {
        let color = grid[row][col]
        var component: Set<GridPosition> = []
        var queue: [GridPosition] = [GridPosition(row: row, col: col)]
        var visited: Set<GridPosition> = [GridPosition(row: row, col: col)]
        
        while !queue.isEmpty {
            let current = queue.removeFirst()
            component.insert(current)
            
            // Check 4-connected neighbors
            let neighbors = [
                GridPosition(row: current.row - 1, col: current.col),  // North
                GridPosition(row: current.row + 1, col: current.col),  // South
                GridPosition(row: current.row, col: current.col - 1),  // West
                GridPosition(row: current.row, col: current.col + 1)   // East
            ]
            
            for neighbor in neighbors {
                guard neighbor.row >= 0 && neighbor.row < rows &&
                      neighbor.col >= 0 && neighbor.col < cols else { continue }
                guard !visited.contains(neighbor) else { continue }
                guard grid[neighbor.row][neighbor.col] == color else { continue }
                
                visited.insert(neighbor)
                queue.append(neighbor)
            }
        }
        
        return component
    }
    
    // Apply a move: fill component at (row, col) with selected color
    func applyMove(row: Int, col: Int) {
        guard !isComplete else { return }
        guard movesRemaining > 0 else { return }
        
        let oldColor = grid[row][col]
        let newColor = selectedColorIndex
        
        // No-op if same color
        if oldColor == newColor { return }
        
        // Save current state for undo
        moveHistory.append(grid)
        
        // Get the component to fill
        let component = getComponent(row: row, col: col)
        
        // Fill the component with new color
        var newGrid = grid
        for cell in component {
            newGrid[cell.row][cell.col] = newColor
        }
        
        grid = newGrid
        movesRemaining -= 1
        
        // Check for win
        checkCompletion()
        
        objectWillChange.send()
    }
    
    // Undo last move
    func undo() {
        guard !moveHistory.isEmpty else { return }
        guard !isComplete else { return }
        
        grid = moveHistory.removeLast()
        movesRemaining += 1
        
        objectWillChange.send()
    }
    
    // Check if the game is complete
    private func checkCompletion() {
        // Check if all cells are the same color
        let firstColor = grid[0][0]
        var allSame = true
        
        for r in 0..<rows {
            for c in 0..<cols {
                if grid[r][c] != firstColor {
                    allSame = false
                    break
                }
            }
            if !allSame { break }
        }
        
        if allSame {
            isComplete = true
            isWon = true
        } else if movesRemaining == 0 {
            isComplete = true
            isWon = false
        }
    }
    
    // Reset the game
    func reset() {
        grid = initialGrid
        movesRemaining = moveLimit
        selectedColorIndex = 0
        isComplete = false
        isWon = false
        moveHistory = []
        objectWillChange.send()
    }
    
    // Can undo?
    var canUndo: Bool {
        return !moveHistory.isEmpty && !isComplete
    }
}

