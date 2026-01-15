//
//  NumberSnakeGameState.swift
//  Mindfold
//
//  Created by Evan Haque on 1/15/26.
//

import SwiftUI

// Grid position for path cells
struct GridPos: Hashable, Equatable {
    let row: Int
    let col: Int
}

class NumberSnakeGameState: ObservableObject {
    // Game configuration
    var rows: Int
    var cols: Int
    var clues: [NumberSnakeClue]
    let solutionPath: [[Int]]
    
    // Game state
    @Published var path: [GridPos] = []  // Current path drawn by user
    @Published var isComplete: Bool = false
    @Published var errorMessage: String? = nil
    @Published var currentClueIndex: Int = 0  // Which clue number we're expecting next
    
    // Helper: Clue positions for quick lookup
    private var cluePositions: [GridPos: Int] = [:]  // Position -> Clue value
    
    init(puzzle: NumberSnakePuzzle) {
        self.rows = puzzle.rows
        self.cols = puzzle.cols
        self.clues = puzzle.clues
        self.solutionPath = puzzle.solutionPath
        
        // Build clue position map
        for clue in clues {
            cluePositions[GridPos(row: clue.row, col: clue.col)] = clue.value
        }
    }
    
    // For preview/testing
    init(rows: Int = 5, cols: Int = 5, clues: [NumberSnakeClue] = []) {
        self.rows = rows
        self.cols = cols
        self.clues = clues
        self.solutionPath = []
        
        for clue in clues {
            cluePositions[GridPos(row: clue.row, col: clue.col)] = clue.value
        }
    }
    
    func update(puzzle: NumberSnakePuzzle) {
        self.rows = puzzle.rows
        self.cols = puzzle.cols
        self.clues = puzzle.clues
        self.path = []
        self.isComplete = false
        self.errorMessage = nil
        self.currentClueIndex = 0
        
        // Rebuild clue position map
        cluePositions.removeAll()
        for clue in puzzle.clues {
            cluePositions[GridPos(row: clue.row, col: clue.col)] = clue.value
        }
    }
    
    // MARK: - Path Management
    
    func startPath(at pos: GridPos) {
        // Check if starting at a valid cell
        guard isValidPosition(pos) else { return }
        
        // Check if this position is already in the path
        if let index = path.firstIndex(of: pos) {
            // If it's a clue, reset path from this clue onwards
            if let clueValue = cluePositions[pos] {
                path = Array(path[0...index])
                currentClueIndex = clueValue
                errorMessage = nil
                return
            }
        }
        
        // Must start at clue 1
        if let clueValue = cluePositions[pos], clueValue == 1 {
            path = [pos]
            currentClueIndex = 1
            errorMessage = nil
        } else {
            errorMessage = "Start at number 1!"
        }
    }
    
    func extendPath(to pos: GridPos) {
        guard isValidPosition(pos) else { return }
        
        // Can't add if path is empty
        guard !path.isEmpty else { return }
        
        // Check if this position is already in path (going backwards)
        if let index = path.firstIndex(of: pos) {
            // If it's the last position, do nothing (dragging over same cell)
            if path.last == pos {
                return
            }
            
            // Going backwards - truncate path to this position
            if index < path.count - 1 {
                path = Array(path[0...index])
                
                // Update currentClueIndex to the last clue we're still on
                for i in stride(from: index, through: 0, by: -1) {
                    if let clueValue = cluePositions[path[i]] {
                        currentClueIndex = clueValue
                        break
                    }
                }
                errorMessage = nil
                isComplete = false  // Going backwards means we're no longer complete
                return
            }
        }
        
        // Check if adjacent to last position
        guard let last = path.last, areAdjacent(last, pos) else {
            return
        }
        
        // Add to path first
        path.append(pos)
        
        // Check if we're hitting the correct next clue
        if let clueValue = cluePositions[pos] {
            if clueValue == currentClueIndex + 1 {
                // Correct next number!
                currentClueIndex = clueValue
                errorMessage = nil
                
                // If this is the last clue, verify all cells are filled
                let maxClueValue = clues.map { $0.value }.max() ?? 0
                if clueValue == maxClueValue {
                    let totalCells = rows * cols
                    if path.count == totalCells {
                        // All cells filled - complete!
                        checkCompletion()
                        return
                    } else {
                        // Not all cells filled - invalid
                        errorMessage = "Fill all cells before reaching the last number!"
                        path.removeLast()
                        currentClueIndex = clueValue - 1
                        return
                    }
                }
            } else {
                // Wrong number order
                errorMessage = "Follow the numbers in order!"
                // Remove the position we just added since it's wrong
                path.removeLast()
                return
            }
        }
        
        // Check completion for non-clue cells
        checkCompletion()
    }
    
    func clearPath() {
        path = []
        currentClueIndex = 0
        errorMessage = nil
        isComplete = false
    }
    
    // MARK: - Validation
    
    func isValidPosition(_ pos: GridPos) -> Bool {
        return pos.row >= 0 && pos.row < rows && pos.col >= 0 && pos.col < cols
    }
    
    func areAdjacent(_ pos1: GridPos, _ pos2: GridPos) -> Bool {
        let rowDiff = abs(pos1.row - pos2.row)
        let colDiff = abs(pos1.col - pos2.col)
        return (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1)
    }
    
    func checkCompletion() {
        // Must visit all cells
        let totalCells = rows * cols
        guard path.count == totalCells else {
            isComplete = false
            return
        }
        
        // Must hit all clues in order
        let maxClueValue = clues.map { $0.value }.max() ?? 0
        guard currentClueIndex == maxClueValue else {
            isComplete = false
            return
        }
        
        // Path must be continuous (already enforced by extendPath, but double-check)
        for i in 0..<path.count - 1 {
            if !areAdjacent(path[i], path[i + 1]) {
                isComplete = false
                return
            }
        }
        
        isComplete = true
        errorMessage = nil
    }
    
    // MARK: - Helper: Get path segment between two clues
    
    func getPathSegmentColor(for pos: GridPos) -> Color? {
        guard let index = path.firstIndex(of: pos) else { return nil }
        
        // Calculate color based on position in path
        let progress = Double(index) / Double(max(1, path.count - 1))
        return Color(
            hue: 0.3 + progress * 0.4,  // Green to yellow gradient
            saturation: 0.6,
            brightness: 0.9
        )
    }
    
    func isInPath(_ pos: GridPos) -> Bool {
        return path.contains(pos)
    }
    
    func reset() {
        clearPath()
    }
}

