//
//  LITSGameState.swift
//  Mindfold
//
//  Created by Evan Haque on 1/9/26.
//

import Foundation
import SwiftUI

// Cell state for LITS
enum LITSCellState: Equatable {
    case empty
    case filled  // Cell is selected/filled
    case marked  // X mark (user marked as empty)
}

// Game state
class LITSGameState: ObservableObject {
    @Published var grid: [[LITSCellState]]
    @Published var isComplete: Bool = false
    @Published var updateTrigger: Int = 0
    @Published var validRegions: Set<Int> = []  // Regions with valid tetromino shapes
    @Published var violationCells: Set<GridPosition> = []  // Cells that violate rules
    
    var rows: Int
    var cols: Int
    var regions: [[Int]]  // Region ID map
    var solutionShape: [[String?]]  // For validation
    var solutionFilled: [[Bool]]  // For validation
    
    // Region colors for display (more vibrant)
    private let regionColors: [Color] = [
        Color(red: 1.0, green: 0.5, blue: 0.2),  // Vibrant Orange
        Color(red: 0.2, green: 0.9, blue: 0.4),   // Vibrant Green
        Color(red: 0.2, green: 0.6, blue: 1.0),  // Vibrant Blue
        Color(red: 0.8, green: 0.3, blue: 1.0),  // Vibrant Purple
        Color(red: 1.0, green: 0.9, blue: 0.2),  // Vibrant Yellow
        Color(red: 1.0, green: 0.2, blue: 0.5),  // Vibrant Pink
        Color(red: 0.2, green: 0.8, blue: 0.9),  // Vibrant Cyan
    ]
    
    init(rows: Int, cols: Int, regions: [[Int]], solutionShape: [[String?]], solutionFilled: [[Bool]]) {
        self.rows = rows
        self.cols = cols
        self.regions = regions
        self.solutionShape = solutionShape
        self.solutionFilled = solutionFilled
        
        // Initialize empty grid
        self.grid = Array(repeating: Array(repeating: LITSCellState.empty, count: cols), count: rows)
    }
    
    // Update game state with new puzzle data
    func update(rows: Int, cols: Int, regions: [[Int]], solutionShape: [[String?]], solutionFilled: [[Bool]]) {
        self.rows = rows
        self.cols = cols
        self.regions = regions
        self.solutionShape = solutionShape
        self.solutionFilled = solutionFilled
        
        // Reset grid
        self.grid = Array(repeating: Array(repeating: LITSCellState.empty, count: cols), count: rows)
        isComplete = false
        updateTrigger += 1
        objectWillChange.send()
    }
    
    // Reset game state
    func reset() {
        grid = Array(repeating: Array(repeating: LITSCellState.empty, count: cols), count: rows)
        validRegions = []
        violationCells = []
        isComplete = false
        updateTrigger += 1
        objectWillChange.send()
    }
    
    // Get region ID at position
    func getRegionId(row: Int, col: Int) -> Int? {
        guard row >= 0 && row < rows && col >= 0 && col < cols else { return nil }
        return regions[row][col]
    }
    
    // Get color for a region
    func getRegionColor(regionId: Int) -> Color {
        let index = regionId % regionColors.count
        return regionColors[index]
    }
    
    // Toggle cell between empty, marked, and filled
    func toggleCell(row: Int, col: Int) {
        guard row >= 0 && row < rows && col >= 0 && col < cols else { return }
        
        switch grid[row][col] {
        case .empty:
            grid[row][col] = .filled
        case .filled:
            grid[row][col] = .marked
        case .marked:
            grid[row][col] = .empty
        }
        
        updateTrigger += 1
        objectWillChange.send()
        validateRegionShapes()
        checkCompletion()
    }
    
    // Set a cell as filled
    func setCellFilled(row: Int, col: Int) {
        guard row >= 0 && row < rows && col >= 0 && col < cols else { return }
        grid[row][col] = .filled
        updateTrigger += 1
        objectWillChange.send()
        validateRegionShapes()
        checkCompletion()
    }
    
    // Set a cell as empty
    func setCellEmpty(row: Int, col: Int) {
        guard row >= 0 && row < rows && col >= 0 && col < cols else { return }
        grid[row][col] = .empty
        updateTrigger += 1
        objectWillChange.send()
        validateRegionShapes()
        checkCompletion()
    }
    
    // Check if a region has a valid tetromino shape
    func isRegionValid(regionId: Int) -> Bool {
        return validRegions.contains(regionId)
    }
    
    // Validate tetromino shapes in all regions
    private func validateRegionShapes() {
        var newValidRegions: Set<Int> = []
        
        // Get all unique regions
        var uniqueRegions = Set<Int>()
        for r in 0..<rows {
            for c in 0..<cols {
                uniqueRegions.insert(regions[r][c])
            }
        }
        
        // Check each region
        for regionId in uniqueRegions {
            // Get all filled cells in this region
            var filledCells: [(row: Int, col: Int)] = []
            for r in 0..<rows {
                for c in 0..<cols {
                    if regions[r][c] == regionId && grid[r][c] == .filled {
                        filledCells.append((row: r, col: c))
                    }
                }
            }
            
            // Must have exactly 4 cells to be a valid tetromino
            guard filledCells.count == 4 else { continue }
            
            // Check if it's a 2x2 square (not a valid tetromino)
            if is2x2Square(cells: filledCells) {
                continue  // Skip 2x2 squares - they're not valid tetrominoes
            }
            
            // Check if it forms a valid tetromino (connected, 4 cells, not 2x2)
            // AND it must be one of the canonical L, I, T, S shapes
            if isValidTetromino(cells: filledCells) && identifyShape(cells: filledCells) != nil {
                newValidRegions.insert(regionId)
            }
        }
        
        validRegions = newValidRegions
        validateRules()  // Check for violations after updating valid regions
    }
    
    // Check if cells form a 2x2 square (not a valid tetromino)
    private func is2x2Square(cells: [(row: Int, col: Int)]) -> Bool {
        guard cells.count == 4 else { return false }
        
        // Get min/max row and col
        let rows = cells.map { $0.row }
        let cols = cells.map { $0.col }
        let minRow = rows.min()!
        let maxRow = rows.max()!
        let minCol = cols.min()!
        let maxCol = cols.max()!
        
        // Check if it's exactly a 2x2 square
        if maxRow - minRow == 1 && maxCol - minCol == 1 {
            // Check if all 4 corners are present
            let corners = [
                (minRow, minCol),
                (minRow, maxCol),
                (maxRow, minCol),
                (maxRow, maxCol)
            ]
            
            let allCornersPresent = corners.allSatisfy { (r, c) in
                cells.contains(where: { $0.row == r && $0.col == c })
            }
            
            return allCornersPresent
        }
        
        return false
    }
    
    // Check if cells form a valid tetromino shape
    private func isValidTetromino(cells: [(row: Int, col: Int)]) -> Bool {
        guard cells.count == 4 else { return false }
        
        // Check if all cells are connected (BFS)
        var visited: Set<GridPosition> = []
        var queue: [GridPosition] = []
        
        let start = GridPosition(row: cells[0].row, col: cells[0].col)
        queue.append(start)
        visited.insert(start)
        
        while !queue.isEmpty {
            let current = queue.removeFirst()
            
            // Check neighbors
            let neighbors = [
                GridPosition(row: current.row - 1, col: current.col),
                GridPosition(row: current.row + 1, col: current.col),
                GridPosition(row: current.row, col: current.col - 1),
                GridPosition(row: current.row, col: current.col + 1)
            ]
            
            for neighbor in neighbors {
                if visited.contains(neighbor) { continue }
                
                // Check if neighbor is in our cell set
                if cells.contains(where: { $0.row == neighbor.row && $0.col == neighbor.col }) {
                    visited.insert(neighbor)
                    queue.append(neighbor)
                }
            }
        }
        
        // All 4 cells must be connected
        return visited.count == 4
    }
    
    // Identify the LITS shape (L, I, T, S) from a set of 4 cells
    // Returns the shape letter or nil if it doesn't match any canonical shape
    private func identifyShape(cells: [(row: Int, col: Int)]) -> String? {
        guard cells.count == 4 else { return nil }
        
        // Normalize: translate so min row and col are 0
        let rows = cells.map { $0.row }
        let cols = cells.map { $0.col }
        let minRow = rows.min()!
        let minCol = cols.min()!
        
        let normalizedSet = Set(cells.map { GridPosition(row: $0.row - minRow, col: $0.col - minCol) })
        
        // L shape rotations (includes both L and mirrored L/J - both are "L" in LITS)
        let L_patterns: [Set<GridPosition>] = [
            // L rotations
            [GridPosition(row: 0, col: 0), GridPosition(row: 1, col: 0), GridPosition(row: 2, col: 0), GridPosition(row: 2, col: 1)],  // L original
            [GridPosition(row: 0, col: 0), GridPosition(row: 0, col: 1), GridPosition(row: 0, col: 2), GridPosition(row: 1, col: 0)],  // L rot 90
            [GridPosition(row: 0, col: 0), GridPosition(row: 0, col: 1), GridPosition(row: 1, col: 1), GridPosition(row: 2, col: 1)],  // L rot 180
            [GridPosition(row: 0, col: 2), GridPosition(row: 1, col: 0), GridPosition(row: 1, col: 1), GridPosition(row: 1, col: 2)],  // L rot 270
            // J rotations (mirrored L - also "L" in LITS)
            [GridPosition(row: 0, col: 1), GridPosition(row: 1, col: 1), GridPosition(row: 2, col: 0), GridPosition(row: 2, col: 1)],  // J original
            [GridPosition(row: 0, col: 0), GridPosition(row: 1, col: 0), GridPosition(row: 1, col: 1), GridPosition(row: 1, col: 2)],  // J rot 90
            [GridPosition(row: 0, col: 0), GridPosition(row: 0, col: 1), GridPosition(row: 1, col: 0), GridPosition(row: 2, col: 0)],  // J rot 180
            [GridPosition(row: 0, col: 0), GridPosition(row: 0, col: 1), GridPosition(row: 0, col: 2), GridPosition(row: 1, col: 2)]   // J rot 270
        ].map(Set.init)
        
        // I shape rotations
        let I_patterns: [Set<GridPosition>] = [
            [GridPosition(row: 0, col: 0), GridPosition(row: 0, col: 1), GridPosition(row: 0, col: 2), GridPosition(row: 0, col: 3)],  // horizontal
            [GridPosition(row: 0, col: 0), GridPosition(row: 1, col: 0), GridPosition(row: 2, col: 0), GridPosition(row: 3, col: 0)]   // vertical
        ].map(Set.init)
        
        // T shape rotations
        let T_patterns: [Set<GridPosition>] = [
            [GridPosition(row: 0, col: 0), GridPosition(row: 0, col: 1), GridPosition(row: 0, col: 2), GridPosition(row: 1, col: 1)],  // T pointing down
            [GridPosition(row: 0, col: 0), GridPosition(row: 1, col: 0), GridPosition(row: 1, col: 1), GridPosition(row: 2, col: 0)],  // T pointing right
            [GridPosition(row: 0, col: 1), GridPosition(row: 1, col: 0), GridPosition(row: 1, col: 1), GridPosition(row: 1, col: 2)],  // T pointing up
            [GridPosition(row: 0, col: 1), GridPosition(row: 1, col: 0), GridPosition(row: 1, col: 1), GridPosition(row: 2, col: 1)]   // T pointing left
        ].map(Set.init)
        
        // S shape rotations (includes Z)
        let S_patterns: [Set<GridPosition>] = [
            [GridPosition(row: 0, col: 1), GridPosition(row: 0, col: 2), GridPosition(row: 1, col: 0), GridPosition(row: 1, col: 1)],  // S horizontal
            [GridPosition(row: 0, col: 0), GridPosition(row: 1, col: 0), GridPosition(row: 1, col: 1), GridPosition(row: 2, col: 1)],  // S vertical
            [GridPosition(row: 0, col: 0), GridPosition(row: 0, col: 1), GridPosition(row: 1, col: 1), GridPosition(row: 1, col: 2)],  // Z horizontal
            [GridPosition(row: 0, col: 1), GridPosition(row: 1, col: 0), GridPosition(row: 1, col: 1), GridPosition(row: 2, col: 0)]   // Z vertical
        ].map(Set.init)
        
        for pattern in L_patterns {
            if pattern == normalizedSet { return "L" }
        }
        for pattern in I_patterns {
            if pattern == normalizedSet { return "I" }
        }
        for pattern in T_patterns {
            if pattern == normalizedSet { return "T" }
        }
        for pattern in S_patterns {
            if pattern == normalizedSet { return "S" }
        }
        
        return nil  // Not a recognized LITS shape
    }
    
    // Validate all rules and mark violations
    private func validateRules() {
        var newViolationCells: Set<GridPosition> = []
        
        // Rule 1: Check for 2x2 filled squares
        for r in 0..<(rows - 1) {
            for c in 0..<(cols - 1) {
                let cells = [
                    grid[r][c],
                    grid[r][c + 1],
                    grid[r + 1][c],
                    grid[r + 1][c + 1]
                ]
                
                let allFilled = cells.allSatisfy { cell in
                    if case .filled = cell {
                        return true
                    }
                    return false
                }
                
                if allFilled {
                    // Violation: 2x2 filled square - mark all 4 cells
                    newViolationCells.insert(GridPosition(row: r, col: c))
                    newViolationCells.insert(GridPosition(row: r, col: c + 1))
                    newViolationCells.insert(GridPosition(row: r + 1, col: c))
                    newViolationCells.insert(GridPosition(row: r + 1, col: c + 1))
                }
            }
        }
        
        // Rule 2: Check same shapes touching by edges
        // Identify the actual shape for each valid region from filled cells
        var regionShapes: [Int: String] = [:]
        
        for regionId in validRegions {
            // Get all filled cells in this region
            var filledCells: [(row: Int, col: Int)] = []
            for r in 0..<rows {
                for c in 0..<cols {
                    if regions[r][c] == regionId && grid[r][c] == .filled {
                        filledCells.append((row: r, col: c))
                    }
                }
            }
            
            // Identify what shape these cells form
            if let shape = identifyShape(cells: filledCells) {
                regionShapes[regionId] = shape
            }
        }
        
        // Check if cells with same shape are touching
        // Only check cells that are part of valid regions
        for r in 0..<rows {
            for c in 0..<cols {
                guard grid[r][c] == .filled else { continue }
                
                let currentRegion = regions[r][c]
                // Only check if this region is valid
                guard validRegions.contains(currentRegion) else { continue }
                guard let currentShape = regionShapes[currentRegion] else { continue }
                
                // Check neighbors (edges only, not diagonals)
                let neighbors = [
                    (r - 1, c),  // North
                    (r + 1, c),  // South
                    (r, c - 1),  // West
                    (r, c + 1)   // East
                ]
                
                for (nr, nc) in neighbors {
                    guard nr >= 0 && nr < rows && nc >= 0 && nc < cols else { continue }
                    guard grid[nr][nc] == .filled else { continue }
                    
                    let neighborRegion = regions[nr][nc]
                    // Only check if neighbor region is also valid
                    guard validRegions.contains(neighborRegion) else { continue }
                    guard let neighborShape = regionShapes[neighborRegion] else { continue }
                    
                    // If same shape and touching by edge, mark as violation
                    // But only if they're from different regions (same region is fine)
                    if currentShape == neighborShape && currentRegion != neighborRegion {
                        newViolationCells.insert(GridPosition(row: r, col: c))
                        newViolationCells.insert(GridPosition(row: nr, col: nc))
                    }
                }
            }
        }
        
        violationCells = newViolationCells
    }
    
    // Check if game is complete
    private func checkCompletion() {
        // ===== ALTERNATE COMPLETION CHECK (currently active) =====
        // This method only checks if each region has exactly 1 valid tetromino shape
        // and no rule violations. It does NOT require all cells to be covered.
        // This is more lenient and accepts multiple solutions.
        
        // Get all unique regions
        var uniqueRegions = Set<Int>()
        for r in 0..<rows {
            for c in 0..<cols {
                uniqueRegions.insert(regions[r][c])
            }
        }
        
        // Check if all regions have valid tetrominoes
        let allRegionsValid = uniqueRegions.allSatisfy { regionId in
            validRegions.contains(regionId)
        }
        
        // Check if there are no violations
        let noViolations = violationCells.isEmpty
        
        // Game is complete if:
        // 1. All regions have valid tetrominoes (exactly 4 connected cells, not 2x2)
        // 2. No rule violations (no 2x2 squares, no same shapes touching)
        isComplete = allRegionsValid && noViolations
        
        /* ===== ORIGINAL STRICT COMPLETION CHECK (currently disabled) =====
        // This method requires all cells to be covered (filled or marked)
        // Uncomment this section to use the stricter completion criteria
        
        // Get all unique regions
        var uniqueRegions = Set<Int>()
        for r in 0..<rows {
            for c in 0..<cols {
                uniqueRegions.insert(regions[r][c])
            }
        }
        
        // Check if all regions have valid tetrominoes
        let allRegionsValid = uniqueRegions.allSatisfy { regionId in
            validRegions.contains(regionId)
        }
        
        // Check if there are no violations
        let noViolations = violationCells.isEmpty
        
        // Check if all cells are either filled or marked (no empty cells)
        var allCellsCovered = true
        for r in 0..<rows {
            for c in 0..<cols {
                if case .empty = grid[r][c] {
                    allCellsCovered = false
                    break
                }
            }
            if !allCellsCovered { break }
        }
        
        // Game is complete if:
        // 1. All regions have valid tetrominoes (exactly 4 connected cells, not 2x2)
        // 2. No rule violations (no 2x2 squares, no same shapes touching)
        // 3. All cells are covered (filled or marked)
        isComplete = allRegionsValid && noViolations && allCellsCovered
        */
    }
    
    // Check if cell is filled
    func isFilled(row: Int, col: Int) -> Bool {
        guard row >= 0 && row < rows && col >= 0 && col < cols else { return false }
        return grid[row][col] == .filled
    }
    
    // Toggle mark (X) on a cell
    func toggleMark(row: Int, col: Int) {
        guard row >= 0 && row < rows && col >= 0 && col < cols else { return }
        
        switch grid[row][col] {
        case .empty:
            grid[row][col] = .marked
        case .marked:
            grid[row][col] = .empty
        case .filled:
            // Can't mark filled cells
            return
        }
        
        updateTrigger += 1
        objectWillChange.send()
    }
}

