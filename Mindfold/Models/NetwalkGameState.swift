//
//  NetwalkGameState.swift
//  Mindfold
//
//  Created by Evan Haque on 1/9/26.
//

import SwiftUI

// Direction bitmask constants (NESW)
let N_BIT: Int = 1
let E_BIT: Int = 2
let S_BIT: Int = 4
let W_BIT: Int = 8

// Game state
class NetwalkGameState: ObservableObject {
    @Published var masks: [[Int]]  // Current masks (what player sees)
    @Published var rotations: [[Int]]  // Current rotations (0-3)
    @Published var poweredCells: Set<GridPosition> = []  // Cells connected to source
    @Published var isComplete: Bool = false
    
    var rows: Int
    var cols: Int
    var source: SourcePosition
    var solutionMasks: [[Int]]  // Correct masks for validation
    
    init(rows: Int, cols: Int, source: SourcePosition, puzzleMasks: [[Int]], solutionMasks: [[Int]], initialRotations: [[Int]]) {
        self.rows = rows
        self.cols = cols
        self.source = source
        self.solutionMasks = solutionMasks
        self.masks = puzzleMasks
        self.rotations = initialRotations
        
        // Initial power propagation
        propagatePower()
    }
    
    // Update game state with new puzzle (handles size changes)
    func update(rows: Int, cols: Int, source: SourcePosition, puzzleMasks: [[Int]], solutionMasks: [[Int]], initialRotations: [[Int]]) {
        self.rows = rows
        self.cols = cols
        self.source = source
        self.solutionMasks = solutionMasks
        self.masks = puzzleMasks
        self.rotations = initialRotations
        propagatePower()
        checkCompletion()
    }
    
    // Rotate a tile clockwise (one turn)
    func rotateTile(row: Int, col: Int) {
        guard row >= 0 && row < rows && col >= 0 && col < cols else { return }
        
        rotations[row][col] = (rotations[row][col] + 1) % 4
        masks[row][col] = rotateMask(masks[row][col], turns: 1)
        
        objectWillChange.send()
        
        // Recalculate power propagation
        propagatePower()
        checkCompletion()
    }
    
    // Rotate mask clockwise
    private func rotateMask(_ mask: Int, turns: Int) -> Int {
        var result = mask
        for _ in 0..<(turns % 4) {
            let n = (result & N_BIT) != 0
            let e = (result & E_BIT) != 0
            let s = (result & S_BIT) != 0
            let w = (result & W_BIT) != 0
            result = 0
            if w { result |= N_BIT }
            if n { result |= E_BIT }
            if e { result |= S_BIT }
            if s { result |= W_BIT }
        }
        return result
    }
    
    // Get openings from mask
    func getOpenings(mask: Int) -> Set<String> {
        var openings: Set<String> = []
        if mask & N_BIT != 0 { openings.insert("N") }
        if mask & E_BIT != 0 { openings.insert("E") }
        if mask & S_BIT != 0 { openings.insert("S") }
        if mask & W_BIT != 0 { openings.insert("W") }
        return openings
    }
    
    // Propagate power from source to connected tiles
    private func propagatePower() {
        poweredCells.removeAll()
        
        // BFS from source
        var queue: [GridPosition] = []
        var visited: Set<GridPosition> = []
        
        let sourcePos = GridPosition(row: source.row, col: source.col)
        queue.append(sourcePos)
        visited.insert(sourcePos)
        poweredCells.insert(sourcePos)
        
        let oppositeDir: [String: String] = ["N": "S", "E": "W", "S": "N", "W": "E"]
        
        while !queue.isEmpty {
            let current = queue.removeFirst()
            let mask = masks[current.row][current.col]
            let openings = getOpenings(mask: mask)
            
            // Check each opening direction
            for dir in openings {
                var nr = current.row
                var nc = current.col
                
                switch dir {
                case "N": nr -= 1
                case "E": nc += 1
                case "S": nr += 1
                case "W": nc -= 1
                default: continue
                }
                
                // Check bounds
                guard nr >= 0 && nr < rows && nc >= 0 && nc < cols else { continue }
                
                let neighborPos = GridPosition(row: nr, col: nc)
                if visited.contains(neighborPos) { continue }
                
                // Check if neighbor has matching opening
                let neighborMask = masks[nr][nc]
                let neighborOpenings = getOpenings(mask: neighborMask)
                
                if neighborOpenings.contains(oppositeDir[dir] ?? "") {
                    visited.insert(neighborPos)
                    poweredCells.insert(neighborPos)
                    queue.append(neighborPos)
                }
            }
        }
        
        objectWillChange.send()
    }
    
    // Check if puzzle is complete (all tiles powered)
    private func checkCompletion() {
        let totalCells = rows * cols
        isComplete = poweredCells.count == totalCells
    }
    
    // Reset to initial state
    func reset(puzzleMasks: [[Int]], initialRotations: [[Int]]) {
        self.masks = puzzleMasks
        self.rotations = initialRotations
        propagatePower()
        checkCompletion()
    }
    
    // Check if a cell is the source
    func isSource(row: Int, col: Int) -> Bool {
        return row == source.row && col == source.col
    }
    
    // Check if a cell is powered
    func isPowered(row: Int, col: Int) -> Bool {
        return poweredCells.contains(GridPosition(row: row, col: col))
    }
}

