//
//  BridgesGameState.swift
//  Mindfold
//
//  Created by Evan Haque on 1/15/26.
//

import SwiftUI

// Edge key for storing connections between nodes
struct EdgeKey: Hashable {
    let u: Int
    let v: Int
    
    init(_ a: Int, _ b: Int) {
        // Always store smaller index first for consistency
        if a < b {
            self.u = a
            self.v = b
        } else {
            self.u = b
            self.v = a
        }
    }
}

class BridgesGameState: ObservableObject {
    // Game configuration
    var rows: Int
    var cols: Int
    var nodes: [BridgesNode]
    let solutionEdges: [BridgesEdge]
    
    // Game state
    @Published var edges: [EdgeKey: Int] = [:]  // Edge multiplicity (0, 1, or 2)
    @Published var isComplete: Bool = false
    @Published var nodeStates: [Int: NodeState] = [:]  // Track if each node has correct degree
    
    // For undo functionality
    @Published var edgeHistory: [[EdgeKey: Int]] = []
    
    enum NodeState {
        case incomplete  // Not enough connections
        case complete    // Correct number of connections
        case overloaded  // Too many connections
    }
    
    init(puzzle: BridgesPuzzle) {
        self.rows = puzzle.rows
        self.cols = puzzle.cols
        self.nodes = puzzle.nodes
        self.solutionEdges = puzzle.solutionEdges
        
        // Initialize all possible edges to 0
        updateNodeStates()
    }
    
    // For preview/testing
    init(rows: Int = 9, cols: Int = 9, nodes: [BridgesNode] = []) {
        self.rows = rows
        self.cols = cols
        self.nodes = nodes
        self.solutionEdges = []
        updateNodeStates()
    }
    
    func update(puzzle: BridgesPuzzle) {
        self.rows = puzzle.rows
        self.cols = puzzle.cols
        self.nodes = puzzle.nodes
        self.edges = [:]
        self.isComplete = false
        self.edgeHistory = []
        updateNodeStates()
    }
    
    // MARK: - Edge Management
    
    func toggleEdge(from u: Int, to v: Int) {
        guard u != v else { return }
        guard canConnect(u, v) else { return }
        
        // Save history for undo
        edgeHistory.append(edges)
        
        let key = EdgeKey(u, v)
        let current = edges[key] ?? 0
        
        // Cycle: 0 -> 1 -> 2 -> 0
        let next = (current + 1) % 3
        
        // Check if adding this edge would cause a crossing
        if next > current && wouldCross(u, v, newCount: next) {
            return
        }
        
        if next == 0 {
            edges.removeValue(forKey: key)
        } else {
            edges[key] = next
        }
        
        updateNodeStates()
        checkCompletion()
    }
    
    func canConnect(_ u: Int, _ v: Int) -> Bool {
        guard u >= 0 && u < nodes.count && v >= 0 && v < nodes.count else { return false }
        
        let nodeU = nodes[u]
        let nodeV = nodes[v]
        
        // Must share row or column
        if nodeU.row != nodeV.row && nodeU.col != nodeV.col {
            return false
        }
        
        // Check if any other node is between them
        if nodeU.row == nodeV.row {
            let row = nodeU.row
            let minCol = min(nodeU.col, nodeV.col)
            let maxCol = max(nodeU.col, nodeV.col)
            
            for i in 0..<nodes.count {
                if i == u || i == v { continue }
                let node = nodes[i]
                if node.row == row && node.col > minCol && node.col < maxCol {
                    return false
                }
            }
        } else {
            let col = nodeU.col
            let minRow = min(nodeU.row, nodeV.row)
            let maxRow = max(nodeU.row, nodeV.row)
            
            for i in 0..<nodes.count {
                if i == u || i == v { continue }
                let node = nodes[i]
                if node.col == col && node.row > minRow && node.row < maxRow {
                    return false
                }
            }
        }
        
        return true
    }
    
    // MARK: - Crossing Detection
    
    func wouldCross(_ u: Int, _ v: Int, newCount: Int) -> Bool {
        let nodeU = nodes[u]
        let nodeV = nodes[v]
        
        let key = EdgeKey(u, v)
        let currentCount = edges[key] ?? 0
        
        // If edge already exists, it won't cross (we're just increasing multiplicity)
        if currentCount > 0 {
            return false
        }
        
        // Check against all existing edges
        for (edgeKey, count) in edges {
            if count == 0 { continue }
            if edgeKey.u == u && edgeKey.v == v { continue }
            
            let nodeA = nodes[edgeKey.u]
            let nodeB = nodes[edgeKey.v]
            
            if edgesCross(nodeU, nodeV, nodeA, nodeB) {
                return true
            }
        }
        
        return false
    }
    
    func edgesCross(_ p1: BridgesNode, _ p2: BridgesNode, _ q1: BridgesNode, _ q2: BridgesNode) -> Bool {
        // Check if edge p1-p2 crosses edge q1-q2
        
        // If edges share an endpoint, they don't cross
        if (p1.row == q1.row && p1.col == q1.col) ||
           (p1.row == q2.row && p1.col == q2.col) ||
           (p2.row == q1.row && p2.col == q1.col) ||
           (p2.row == q2.row && p2.col == q2.col) {
            return false
        }
        
        // One is horizontal, one is vertical?
        let p1p2Horizontal = p1.row == p2.row
        let q1q2Horizontal = q1.row == q2.row
        
        if p1p2Horizontal == q1q2Horizontal {
            // Both horizontal or both vertical - parallel, can't cross
            return false
        }
        
        // One horizontal, one vertical - check if they intersect
        if p1p2Horizontal {
            // p1-p2 horizontal, q1-q2 vertical
            let hRow = p1.row
            let hMinCol = min(p1.col, p2.col)
            let hMaxCol = max(p1.col, p2.col)
            
            let vCol = q1.col
            let vMinRow = min(q1.row, q2.row)
            let vMaxRow = max(q1.row, q2.row)
            
            return vCol > hMinCol && vCol < hMaxCol && hRow > vMinRow && hRow < vMaxRow
        } else {
            // p1-p2 vertical, q1-q2 horizontal
            let vCol = p1.col
            let vMinRow = min(p1.row, p2.row)
            let vMaxRow = max(p1.row, p2.row)
            
            let hRow = q1.row
            let hMinCol = min(q1.col, q2.col)
            let hMaxCol = max(q1.col, q2.col)
            
            return vCol > hMinCol && vCol < hMaxCol && hRow > vMinRow && hRow < vMaxRow
        }
    }
    
    // MARK: - Node State Management
    
    func updateNodeStates() {
        for i in 0..<nodes.count {
            let required = nodes[i].degree
            let current = getCurrentDegree(i)
            
            if current < required {
                nodeStates[i] = .incomplete
            } else if current == required {
                nodeStates[i] = .complete
            } else {
                nodeStates[i] = .overloaded
            }
        }
    }
    
    func getCurrentDegree(_ nodeIndex: Int) -> Int {
        var degree = 0
        for (key, count) in edges {
            if key.u == nodeIndex || key.v == nodeIndex {
                degree += count
            }
        }
        return degree
    }
    
    // MARK: - Connectivity Check (BFS)
    
    func isConnected() -> Bool {
        guard !nodes.isEmpty else { return true }
        
        // Build adjacency list from edges with count > 0
        var adj: [Int: Set<Int>] = [:]
        for i in 0..<nodes.count {
            adj[i] = []
        }
        
        for (key, count) in edges {
            if count > 0 {
                adj[key.u]?.insert(key.v)
                adj[key.v]?.insert(key.u)
            }
        }
        
        // BFS from node 0
        var visited = Set<Int>()
        var queue = [0]
        visited.insert(0)
        
        while !queue.isEmpty {
            let current = queue.removeFirst()
            if let neighbors = adj[current] {
                for neighbor in neighbors {
                    if !visited.contains(neighbor) {
                        visited.insert(neighbor)
                        queue.append(neighbor)
                    }
                }
            }
        }
        
        return visited.count == nodes.count
    }
    
    // MARK: - Completion Check
    
    func checkCompletion() {
        // All nodes must have correct degree
        for (_, state) in nodeStates {
            if state != .complete {
                isComplete = false
                return
            }
        }
        
        // Graph must be connected
        if !isConnected() {
            isComplete = false
            return
        }
        
        isComplete = true
    }
    
    // MARK: - Undo
    
    func undo() {
        guard !edgeHistory.isEmpty else { return }
        edges = edgeHistory.removeLast()
        updateNodeStates()
        checkCompletion()
    }
    
    // MARK: - Reset
    
    func reset() {
        edges = [:]
        isComplete = false
        edgeHistory = []
        updateNodeStates()
    }
}

