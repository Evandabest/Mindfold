//
//  StarBattleGameState.swift
//  Mindfold
//
//  Created by Evan Haque on 1/9/26.
//

import Foundation
import SwiftUI

// Cell state for Star Battle
enum StarBattleCellState: Equatable {
    case empty
    case dot  // User has marked as occupied (black dot)
    case star  // User has placed a star
}

// Game state
class StarBattleGameState: ObservableObject {
    @Published var grid: [[StarBattleCellState]]
    @Published var isComplete: Bool = false
    @Published var violationCells: Set<GridPosition> = []  // Cells that violate rules
    
    let size: Int
    var regions: [[Int]]  // Region IDs for each cell (var so it can be updated)
    var solutionStars: [[Bool]]  // Solution for validation (var so it can be updated)
    
    // Track which dots were placed by autofill (not manually by user)
    private var autofilledDots: Set<GridPosition> = []
    
    // Predefined vibrant colors for regions
    private let regionColors: [Color] = [
        Color(red: 0.4, green: 0.6, blue: 0.9),  // Bright blue
        Color(red: 0.9, green: 0.4, blue: 0.5),  // Bright pink/red
        Color(red: 0.4, green: 0.8, blue: 0.5),  // Bright green
        Color(red: 0.95, green: 0.75, blue: 0.3),  // Bright orange/yellow
        Color(red: 0.7, green: 0.4, blue: 0.9),  // Bright purple
        Color(red: 0.3, green: 0.8, blue: 0.9),  // Bright cyan
        Color(red: 0.9, green: 0.6, blue: 0.3),  // Bright orange
        Color(red: 0.5, green: 0.7, blue: 0.9),  // Bright light blue
    ]
    
    init(size: Int, regions: [[Int]], solutionStars: [[Bool]]) {
        self.size = size
        self.regions = regions
        self.solutionStars = solutionStars
        
        // Initialize empty grid
        self.grid = Array(repeating: Array(repeating: StarBattleCellState.empty, count: size), count: size)
        
        // Check for initial violations
        checkViolations()
    }
    
    // Toggle cell state (empty -> dot -> star -> empty)
    func toggleCell(row: Int, col: Int, autofill: Bool = false) {
        var newGrid = grid
        let currentState = newGrid[row][col]
        
        switch currentState {
        case .empty:
            newGrid[row][col] = .dot
            // If manually placing a dot (autofill is false), remove from autofilledDots if it was there
            // This handles the case where a user manually places a dot in a cell that was previously autofilled
            if !autofill {
                autofilledDots.remove(GridPosition(row: row, col: col))
            }
        case .dot:
            newGrid[row][col] = .star
            // Remove from autofilledDots since it's now a star
            autofilledDots.remove(GridPosition(row: row, col: col))
            if autofill {
                // Autofill row, column, and surrounding cells with dots
                autofillFromStar(row: row, col: col, grid: &newGrid)
            }
        case .star:
            newGrid[row][col] = .empty
            if autofill {
                // Reverse autofill - remove dots that aren't needed by other stars
                reverseAutofillFromStar(row: row, col: col, grid: &newGrid)
            }
        }
        
        grid = newGrid
        objectWillChange.send()
        
        // Check for violations and completion
        checkViolations()
        checkCompletion()
    }
    
    // Autofill row, column, surrounding cells, and entire region with dots when placing a star
    private func autofillFromStar(row: Int, col: Int, grid: inout [[StarBattleCellState]]) {
        let regionId = regions[row][col]
        
        // Fill entire region with dots (except the star cell and existing stars)
        for r in 0..<size {
            for c in 0..<size {
                if regions[r][c] == regionId && !(r == row && c == col) && grid[r][c] != .star {
                    if grid[r][c] == .empty {
                        grid[r][c] = .dot
                        autofilledDots.insert(GridPosition(row: r, col: c))
                    }
                }
            }
        }
        
        // Fill entire row with dots (except the star cell)
        for c in 0..<size {
            if c != col && grid[row][c] == .empty {
                grid[row][c] = .dot
                autofilledDots.insert(GridPosition(row: row, col: c))
            }
        }
        
        // Fill entire column with dots (except the star cell)
        for r in 0..<size {
            if r != row && grid[r][col] == .empty {
                grid[r][col] = .dot
                autofilledDots.insert(GridPosition(row: r, col: col))
            }
        }
        
        // Fill surrounding 8 cells with dots (except if they're already stars)
        for dr in -1...1 {
            for dc in -1...1 {
                if dr == 0 && dc == 0 { continue }  // Skip the star cell itself
                
                let nr = row + dr
                let nc = col + dc
                
                if nr >= 0 && nr < size && nc >= 0 && nc < size {
                    if grid[nr][nc] == .empty {
                        grid[nr][nc] = .dot
                        autofilledDots.insert(GridPosition(row: nr, col: nc))
                    }
                }
            }
        }
    }
    
    // Reverse autofill - remove dots that aren't needed by other stars
    private func reverseAutofillFromStar(row: Int, col: Int, grid: inout [[StarBattleCellState]]) {
        let regionId = regions[row][col]
        
        // Check region - remove dots only if no other star in this region
        var hasOtherStarInRegion = false
        for r in 0..<size {
            for c in 0..<size {
                if regions[r][c] == regionId && !(r == row && c == col) && grid[r][c] == .star {
                    hasOtherStarInRegion = true
                    break
                }
            }
            if hasOtherStarInRegion { break }
        }
        
        if !hasOtherStarInRegion {
            // No other star in region - remove dots from this region
            for r in 0..<size {
                for c in 0..<size {
                    if regions[r][c] == regionId && !(r == row && c == col) && grid[r][c] == .dot {
                        // Check if this cell is affected by other stars (row, column, or surrounding)
                        if !isCellAffectedByOtherStars(row: r, col: c, excludeRow: row, excludeCol: col, grid: grid) {
                            grid[r][c] = .empty
                            autofilledDots.remove(GridPosition(row: r, col: c))
                        }
                    }
                }
            }
        }
        
        // Check row - remove dots only if no other star in this row
        var hasOtherStarInRow = false
        for c in 0..<size {
            if c != col && grid[row][c] == .star {
                hasOtherStarInRow = true
                break
            }
        }
        
        if !hasOtherStarInRow {
            // No other star in row - remove dots from this row
            for c in 0..<size {
                if c != col && grid[row][c] == .dot {
                    // Check if this cell is affected by other stars (column or surrounding)
                    if !isCellAffectedByOtherStars(row: row, col: c, excludeRow: row, excludeCol: col, grid: grid) {
                        grid[row][c] = .empty
                        autofilledDots.remove(GridPosition(row: row, col: c))
                    }
                }
            }
        }
        
        // Check column - remove dots only if no other star in this column
        var hasOtherStarInCol = false
        for r in 0..<size {
            if r != row && grid[r][col] == .star {
                hasOtherStarInCol = true
                break
            }
        }
        
        if !hasOtherStarInCol {
            // No other star in column - remove dots from this column
            for r in 0..<size {
                if r != row && grid[r][col] == .dot {
                    // Check if this cell is affected by other stars (row or surrounding)
                    if !isCellAffectedByOtherStars(row: r, col: col, excludeRow: row, excludeCol: col, grid: grid) {
                        grid[r][col] = .empty
                        autofilledDots.remove(GridPosition(row: r, col: col))
                    }
                }
            }
        }
        
        // Check surrounding cells - remove dots only if not affected by other stars
        for dr in -1...1 {
            for dc in -1...1 {
                if dr == 0 && dc == 0 { continue }  // Skip the removed star cell
                
                let nr = row + dr
                let nc = col + dc
                
                if nr >= 0 && nr < size && nc >= 0 && nc < size {
                    if grid[nr][nc] == .dot {
                        // Check if this cell is affected by other stars
                        if !isCellAffectedByOtherStars(row: nr, col: nc, excludeRow: row, excludeCol: col, grid: grid) {
                            grid[nr][nc] = .empty
                            autofilledDots.remove(GridPosition(row: nr, col: nc))
                        }
                    }
                }
            }
        }
    }
    
    // Check if a cell is affected by other stars (in its row, column, or surrounding)
    private func isCellAffectedByOtherStars(row: Int, col: Int, excludeRow: Int, excludeCol: Int, grid: [[StarBattleCellState]]) -> Bool {
        // Check if there's a star in the same row
        for c in 0..<size {
            if c != col && grid[row][c] == .star {
                return true
            }
        }
        
        // Check if there's a star in the same column
        for r in 0..<size {
            if r != row && grid[r][col] == .star {
                return true
            }
        }
        
        // Check if there's a star in the surrounding 8 cells
        for dr in -1...1 {
            for dc in -1...1 {
                if dr == 0 && dc == 0 { continue }  // Skip self
                
                let nr = row + dr
                let nc = col + dc
                
                if nr >= 0 && nr < size && nc >= 0 && nc < size {
                    if grid[nr][nc] == .star {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    // Get region color for a cell
    func getRegionColor(row: Int, col: Int) -> Color {
        let regionId = regions[row][col]
        return regionColors[regionId % regionColors.count]
    }
    
    // Check if cell has a star
    func hasStar(row: Int, col: Int) -> Bool {
        return grid[row][col] == .star
    }
    
    // Check if cell is marked (dot or star)
    func isMarked(row: Int, col: Int) -> Bool {
        return grid[row][col] != .empty
    }
    
    // Clear all black dots (called when autofill is toggled off)
    func clearAllDots() {
        var newGrid = grid
        var removedAny = false
        
        // Remove all dots from the board
        for row in 0..<size {
            for col in 0..<size {
                if newGrid[row][col] == .dot {
                    newGrid[row][col] = .empty
                    removedAny = true
                }
            }
        }
        
        if removedAny {
            // Clear the autofilledDots set
            autofilledDots.removeAll()
            
            grid = newGrid
            objectWillChange.send()
            
            // Recheck violations and completion
            checkViolations()
            checkCompletion()
        }
    }
    
    // Reset game to initial state
    func reset() {
        grid = Array(repeating: Array(repeating: StarBattleCellState.empty, count: size), count: size)
        isComplete = false
        violationCells = []
        autofilledDots = []
        objectWillChange.send()
    }
    
    // Check for rule violations and update violationCells
    private func checkViolations() {
        var violations: Set<GridPosition> = []
        
        // Check each row - must have exactly 1 star (only check if there are stars)
        for row in 0..<size {
            var starCount = 0
            for col in 0..<size {
                if grid[row][col] == .star {
                    starCount += 1
                }
            }
            
            // Only mark as violation if there's more than 1 star, or if row is complete with wrong count
            // Don't mark as violation if there are 0 stars (user is still placing)
            if starCount > 1 {
                // Mark all star cells in this row as violations
                for col in 0..<size {
                    if grid[row][col] == .star {
                        violations.insert(GridPosition(row: row, col: col))
                    }
                }
            }
        }
        
        // Check each column - must have exactly 1 star
        for col in 0..<size {
            var starCount = 0
            for row in 0..<size {
                if grid[row][col] == .star {
                    starCount += 1
                }
            }
            
            // Only mark as violation if there's more than 1 star
            if starCount > 1 {
                // Mark all star cells in this column as violations
                for row in 0..<size {
                    if grid[row][col] == .star {
                        violations.insert(GridPosition(row: row, col: col))
                    }
                }
            }
        }
        
        // Check each region - must have exactly 1 star
        for regionId in 0..<size {
            var starCount = 0
            var starCells: [GridPosition] = []
            
            for row in 0..<size {
                for col in 0..<size {
                    if regions[row][col] == regionId && grid[row][col] == .star {
                        starCount += 1
                        starCells.append(GridPosition(row: row, col: col))
                    }
                }
            }
            
            // Only mark as violation if there's more than 1 star
            if starCount > 1 {
                // Mark all star cells in this region as violations
                for cell in starCells {
                    violations.insert(cell)
                }
            }
        }
        
        // Check for touching stars (including diagonals)
        for row in 0..<size {
            for col in 0..<size {
                if grid[row][col] == .star {
                    // Check all 8 neighbors (including diagonals)
                    for dr in -1...1 {
                        for dc in -1...1 {
                            if dr == 0 && dc == 0 { continue }  // Skip self
                            
                            let nr = row + dr
                            let nc = col + dc
                            
                            if nr >= 0 && nr < size && nc >= 0 && nc < size {
                                if grid[nr][nc] == .star {
                                    // Both cells violate the no-touch rule
                                    violations.insert(GridPosition(row: row, col: col))
                                    violations.insert(GridPosition(row: nr, col: nc))
                                }
                            }
                        }
                    }
                }
            }
        }
        
        violationCells = violations
    }
    
    // Check if puzzle is complete and correct
    private func checkCompletion() {
        // Check if all cells are filled (but we don't need all cells - just need to check rules)
        // Actually, Star Battle doesn't require all cells to be filled
        // We just need to check if the solution matches
        
        // Check if solution matches
        var matches = true
        for row in 0..<size {
            for col in 0..<size {
                let hasStar = grid[row][col] == .star
                if hasStar != solutionStars[row][col] {
                    matches = false
                    break
                }
            }
            if !matches { break }
        }
        
        // Also check that there are no violations
        if matches && violationCells.isEmpty {
            isComplete = true
        } else {
            isComplete = false
        }
    }
}

