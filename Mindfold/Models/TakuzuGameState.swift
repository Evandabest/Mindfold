//
//  TakuzuGameState.swift
//  Mindfold
//
//  Created by Evan Haque on 1/9/26.
//

import Foundation
import SwiftUI

// Position struct for Hashable Set
struct GridPosition: Hashable {
    let row: Int
    let col: Int
}

// Cell state for Takuzu
enum TakuzuCellState: Equatable {
    case empty
    case given(Int)  // Given value (0 or 1) - cannot be changed
    case filled(Int)  // User-filled value (0 or 1) - can be changed
}

// Move history for undo
struct TakuzuMove {
    let row: Int
    let col: Int
    let previousState: TakuzuCellState
}

// Game state
class TakuzuGameState: ObservableObject {
    @Published var grid: [[TakuzuCellState]]
    @Published var isComplete: Bool = false
    @Published var violationCells: Set<GridPosition> = []  // Cells that violate rules
    
    let size: Int
    var solution: [[Int]]  // Changed to var so it can be updated
    private var moveHistory: [TakuzuMove] = []  // Track moves for undo
    
    // Computed property for given positions (based on current grid state)
    var givenPositions: Set<GridPosition> {
        var positions: Set<GridPosition> = []
        for row in 0..<size {
            for col in 0..<size {
                if case .given = grid[row][col] {
                    positions.insert(GridPosition(row: row, col: col))
                }
            }
        }
        return positions
    }
    
    init(size: Int, puzzle: [[Int?]], solution: [[Int]]) {
        self.size = size
        self.solution = solution
        
        var initialGrid = Array(repeating: Array(repeating: TakuzuCellState.empty, count: size), count: size)
        
        // Initialize grid from puzzle
        for row in 0..<size {
            for col in 0..<size {
                if let value = puzzle[row][col] {
                    initialGrid[row][col] = .given(value)
                }
            }
        }
        
        self.grid = initialGrid
        // Check for initial violations
        checkViolations()
    }
    
    // Toggle cell value (empty -> 0 -> 1 -> empty)
    func toggleCell(row: Int, col: Int) {
        // Cannot modify given cells
        guard !givenPositions.contains(GridPosition(row: row, col: col)) else {
            return
        }
        
        var newGrid = grid
        let currentState = newGrid[row][col]
        
        // Save current state for undo
        let move = TakuzuMove(row: row, col: col, previousState: currentState)
        moveHistory.append(move)
        
        switch currentState {
        case .empty:
            newGrid[row][col] = .filled(0)
        case .filled(0):
            newGrid[row][col] = .filled(1)
        case .filled(1):
            newGrid[row][col] = .empty
        case .filled(_):
            // Should not happen (only 0 and 1 are valid), but handle for exhaustiveness
            newGrid[row][col] = .empty
        case .given(_):
            // Should not happen due to guard, but handle all cases
            return
        }
        
        grid = newGrid
        objectWillChange.send()
        
        // Check for violations and completion
        checkViolations()
        checkCompletion()
    }
    
    // Set cell value directly
    func setCell(row: Int, col: Int, value: Int?) {
        guard !givenPositions.contains(GridPosition(row: row, col: col)) else {
            return
        }
        
        var newGrid = grid
        let currentState = newGrid[row][col]
        
        // Save current state for undo
        let move = TakuzuMove(row: row, col: col, previousState: currentState)
        moveHistory.append(move)
        
        if let val = value {
            newGrid[row][col] = .filled(val)
        } else {
            newGrid[row][col] = .empty
        }
        
        grid = newGrid
        objectWillChange.send()
        
        // Check for violations and completion
        checkViolations()
        checkCompletion()
    }
    
    // Undo last move
    func undo() {
        guard !moveHistory.isEmpty else { return }
        
        let lastMove = moveHistory.removeLast()
        
        var newGrid = grid
        newGrid[lastMove.row][lastMove.col] = lastMove.previousState
        
        grid = newGrid
        objectWillChange.send()
        
        // Check for violations and completion
        checkViolations()
        checkCompletion()
    }
    
    // Get cell value (0, 1, or nil for empty)
    func getCellValue(row: Int, col: Int) -> Int? {
        switch grid[row][col] {
        case .empty:
            return nil
        case .given(let value), .filled(let value):
            return value
        }
    }
    
    // Check if cell is given (cannot be changed)
    func isGiven(row: Int, col: Int) -> Bool {
        return givenPositions.contains(GridPosition(row: row, col: col))
    }
    
    // Reset game to initial puzzle state
    func reset(with puzzle: [[Int?]]) {
        var newGrid = Array(repeating: Array(repeating: TakuzuCellState.empty, count: size), count: size)
        
        for row in 0..<size {
            for col in 0..<size {
                if let value = puzzle[row][col] {
                    newGrid[row][col] = .given(value)
                }
            }
        }
        
        grid = newGrid
        isComplete = false
        violationCells = []
        moveHistory = []  // Clear move history
        objectWillChange.send()
    }
    
    // Check for rule violations and update violationCells
    private func checkViolations() {
        var violations: Set<GridPosition> = []
        
        // Check each row
        for row in 0..<size {
            // Get all values with their actual column indices
            var rowData: [(col: Int, value: Int)] = []
            for col in 0..<size {
                if let value = getCellValue(row: row, col: col) {
                    rowData.append((col: col, value: value))
                }
            }
            
            // Check for three consecutive (need at least 3 values)
            if rowData.count >= 3 {
                for i in 0..<(rowData.count - 2) {
                    if rowData[i].value == rowData[i+1].value && rowData[i+1].value == rowData[i+2].value {
                        // Check if they're actually consecutive in the grid (no gaps)
                        if rowData[i+1].col == rowData[i].col + 1 && rowData[i+2].col == rowData[i+1].col + 1 {
                            violations.insert(GridPosition(row: row, col: rowData[i].col))
                            violations.insert(GridPosition(row: row, col: rowData[i+1].col))
                            violations.insert(GridPosition(row: row, col: rowData[i+2].col))
                        }
                    }
                }
            }
            
            // Check count (if row is complete)
            if rowData.count == size {
                let zeros = rowData.filter { $0.value == 0 }.count
                let ones = rowData.filter { $0.value == 1 }.count
                if zeros != size / 2 || ones != size / 2 {
                    // Mark all cells in this row as violations
                    for col in 0..<size {
                        violations.insert(GridPosition(row: row, col: col))
                    }
                }
            }
        }
        
        // Check each column
        for col in 0..<size {
            // Get all values with their actual row indices
            var colData: [(row: Int, value: Int)] = []
            for row in 0..<size {
                if let value = getCellValue(row: row, col: col) {
                    colData.append((row: row, value: value))
                }
            }
            
            // Check for three consecutive (need at least 3 values)
            if colData.count >= 3 {
                for i in 0..<(colData.count - 2) {
                    if colData[i].value == colData[i+1].value && colData[i+1].value == colData[i+2].value {
                        // Check if they're actually consecutive in the grid (no gaps)
                        if colData[i+1].row == colData[i].row + 1 && colData[i+2].row == colData[i+1].row + 1 {
                            violations.insert(GridPosition(row: colData[i].row, col: col))
                            violations.insert(GridPosition(row: colData[i+1].row, col: col))
                            violations.insert(GridPosition(row: colData[i+2].row, col: col))
                        }
                    }
                }
            }
            
            // Check count (if column is complete)
            if colData.count == size {
                let zeros = colData.filter { $0.value == 0 }.count
                let ones = colData.filter { $0.value == 1 }.count
                if zeros != size / 2 || ones != size / 2 {
                    // Mark all cells in this column as violations
                    for row in 0..<size {
                        violations.insert(GridPosition(row: row, col: col))
                    }
                }
            }
        }
        
        // Check for duplicate rows (if complete)
        for row1 in 0..<size {
            let row1Values = (0..<size).compactMap { getCellValue(row: row1, col: $0) }
            if row1Values.count == size {
                for row2 in (row1 + 1)..<size {
                    let row2Values = (0..<size).compactMap { getCellValue(row: row2, col: $0) }
                    if row2Values.count == size && row1Values == row2Values {
                        // Mark all cells in both rows as violations
                        for col in 0..<size {
                            violations.insert(GridPosition(row: row1, col: col))
                            violations.insert(GridPosition(row: row2, col: col))
                        }
                    }
                }
            }
        }
        
        // Check for duplicate columns (if complete)
        for col1 in 0..<size {
            let col1Values = (0..<size).compactMap { getCellValue(row: $0, col: col1) }
            if col1Values.count == size {
                for col2 in (col1 + 1)..<size {
                    let col2Values = (0..<size).compactMap { getCellValue(row: $0, col: col2) }
                    if col2Values.count == size && col1Values == col2Values {
                        // Mark all cells in both columns as violations
                        for row in 0..<size {
                            violations.insert(GridPosition(row: row, col: col1))
                            violations.insert(GridPosition(row: row, col: col2))
                        }
                    }
                }
            }
        }
        
        violationCells = violations
    }
    
    // Check if puzzle is complete and correct
    private func checkCompletion() {
        // Check if all cells are filled
        var allFilled = true
        for row in 0..<size {
            for col in 0..<size {
                if case .empty = grid[row][col] {
                    allFilled = false
                    break
                }
            }
            if !allFilled { break }
        }
        
        if !allFilled {
            isComplete = false
            return
        }
        
        // Check if solution matches
        var matches = true
        for row in 0..<size {
            for col in 0..<size {
                let cellValue = getCellValue(row: row, col: col)
                if cellValue != solution[row][col] {
                    matches = false
                    break
                }
            }
            if !matches { break }
        }
        
        isComplete = matches
    }
    
    // Validate current state (check rules)
    func validate() -> (isValid: Bool, errors: [String]) {
        var errors: [String] = []
        
        // Check each row
        for row in 0..<size {
            let rowValues = (0..<size).compactMap { getCellValue(row: row, col: $0) }
            
            // Check for three consecutive
            for i in 0..<(rowValues.count - 2) {
                if rowValues[i] == rowValues[i+1] && rowValues[i+1] == rowValues[i+2] {
                    errors.append("Row \(row + 1): Three consecutive \(rowValues[i])s")
                }
            }
            
            // Check count (if row is complete)
            if rowValues.count == size {
                let zeros = rowValues.filter { $0 == 0 }.count
                let ones = rowValues.filter { $0 == 1 }.count
                if zeros != size / 2 || ones != size / 2 {
                    errors.append("Row \(row + 1): Must have \(size/2) zeros and \(size/2) ones")
                }
            }
        }
        
        // Check each column
        for col in 0..<size {
            let colValues = (0..<size).compactMap { getCellValue(row: $0, col: col) }
            
            // Check for three consecutive
            for i in 0..<(colValues.count - 2) {
                if colValues[i] == colValues[i+1] && colValues[i+1] == colValues[i+2] {
                    errors.append("Column \(col + 1): Three consecutive \(colValues[i])s")
                }
            }
            
            // Check count (if column is complete)
            if colValues.count == size {
                let zeros = colValues.filter { $0 == 0 }.count
                let ones = colValues.filter { $0 == 1 }.count
                if zeros != size / 2 || ones != size / 2 {
                    errors.append("Column \(col + 1): Must have \(size/2) zeros and \(size/2) ones")
                }
            }
        }
        
        // Check for duplicate rows (if complete)
        for row1 in 0..<size {
            let row1Values = (0..<size).compactMap { getCellValue(row: row1, col: $0) }
            if row1Values.count == size {
                for row2 in (row1 + 1)..<size {
                    let row2Values = (0..<size).compactMap { getCellValue(row: row2, col: $0) }
                    if row2Values.count == size && row1Values == row2Values {
                        errors.append("Rows \(row1 + 1) and \(row2 + 1) are identical")
                    }
                }
            }
        }
        
        // Check for duplicate columns (if complete)
        for col1 in 0..<size {
            let col1Values = (0..<size).compactMap { getCellValue(row: $0, col: col1) }
            if col1Values.count == size {
                for col2 in (col1 + 1)..<size {
                    let col2Values = (0..<size).compactMap { getCellValue(row: $0, col: col2) }
                    if col2Values.count == size && col1Values == col2Values {
                        errors.append("Columns \(col1 + 1) and \(col2 + 1) are identical")
                    }
                }
            }
        }
        
        return (errors.isEmpty, errors)
    }
}

