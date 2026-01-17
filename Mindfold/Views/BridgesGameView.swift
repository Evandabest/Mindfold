//
//  BridgesGameView.swift
//  Mindfold
//
//  Created by Evan Haque on 1/15/26.
//

import SwiftUI

struct BridgesGameView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showTutorial = false
    @State private var puzzle: BridgesPuzzle?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @StateObject private var gameState = BridgesGameState(rows: 9, cols: 9, nodes: [])
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .medium))
                    }
                    
                    Spacer()
                    
                    Text("Bridges")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .bold))
                    
                    Spacer()
                    
                    Button(action: { showTutorial = true }) {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 24)
                
                // Game Board or Loading/Error State
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        Text("Loading puzzle...")
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.red)
                            .font(.system(size: 40))
                        Text("Error loading puzzle")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .semibold))
                        Text(errorMessage)
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        Button(action: {
                            Task {
                                await loadPuzzle()
                            }
                        }) {
                            Text("Retry")
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let puzzle = puzzle {
                    gameBoardView(puzzle: puzzle)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await loadPuzzle()
        }
        .sheet(isPresented: $showTutorial) {
            BridgesTutorialView()
        }
        .alert("Level Complete!", isPresented: $gameState.isComplete) {
            Button("OK") {
                // Could add navigation or next level here
            }
        } message: {
            Text("Congratulations! You've solved the puzzle.")
        }
    }
    
    // MARK: - Game Board View
    
    @ViewBuilder
    private func gameBoardView(puzzle: BridgesPuzzle) -> some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width - 40
            let availableHeight = geometry.size.height - 100
            let cellSize = min(availableWidth / CGFloat(puzzle.cols), availableHeight / CGFloat(puzzle.rows))
            let gridWidth = cellSize * CGFloat(puzzle.cols)
            let gridHeight = cellSize * CGFloat(puzzle.rows)
            
            VStack(spacing: 0) {
                Spacer()
                
                // Grid
                ZStack {
                    // Draw edges first (behind nodes)
                    ForEach(Array(gameState.edges.keys), id: \.self) { key in
                        if let count = gameState.edges[key], count > 0 {
                            EdgeView(
                                from: puzzle.nodes[key.u],
                                to: puzzle.nodes[key.v],
                                count: count,
                                cellSize: cellSize,
                                gridWidth: gridWidth,
                                gridHeight: gridHeight,
                                rows: puzzle.rows,
                                cols: puzzle.cols
                            )
                        }
                    }
                    
                    // Draw nodes on top
                    ForEach(Array(puzzle.nodes.enumerated()), id: \.offset) { index, node in
                        NodeView(
                            node: node,
                            index: index,
                            state: gameState.nodeStates[index] ?? .incomplete,
                            isSelected: false,
                            cellSize: cellSize,
                            gridWidth: gridWidth,
                            gridHeight: gridHeight,
                            rows: puzzle.rows,
                            cols: puzzle.cols
                        )
                    }
                }
                .frame(width: gridWidth, height: gridHeight)
                .contentShape(Rectangle())
                .onTapGesture { location in
                    handleGridTap(location: location, puzzle: puzzle, cellSize: cellSize)
                }
                
                Spacer()
                
                // Controls
                controlsView
            }
        }
    }
    
    // MARK: - Controls
    
    private var controlsView: some View {
        HStack(spacing: 30) {
            Button(action: {
                gameState.undo()
            }) {
                Image(systemName: "arrow.uturn.backward")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color(white: 0.2))
                    .cornerRadius(12)
            }
            
            Button(action: {
                gameState.reset()
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color(white: 0.2))
                    .cornerRadius(12)
            }
        }
        .padding(.bottom, 30)
    }
    
    // MARK: - Grid Tap Handler
    
    private func handleGridTap(location: CGPoint, puzzle: BridgesPuzzle, cellSize: CGFloat) {
        // Find the closest edge to the tap location
        var closestEdge: (u: Int, v: Int)? = nil
        var minDistance: CGFloat = cellSize * 0.4 // Maximum distance to consider a tap valid
        
        // Check all possible node pairs
        for i in 0..<puzzle.nodes.count {
            for j in (i+1)..<puzzle.nodes.count {
                let nodeI = puzzle.nodes[i]
                let nodeJ = puzzle.nodes[j]
                
                // Only consider nodes that can connect (same row or column, no nodes between)
                guard gameState.canConnect(i, j) else { continue }
                
                // Calculate node positions
                let posI = CGPoint(
                    x: CGFloat(nodeI.col) * cellSize + cellSize / 2,
                    y: CGFloat(nodeI.row) * cellSize + cellSize / 2
                )
                let posJ = CGPoint(
                    x: CGFloat(nodeJ.col) * cellSize + cellSize / 2,
                    y: CGFloat(nodeJ.row) * cellSize + cellSize / 2
                )
                
                // Calculate distance from tap to the line segment between nodes
                let distance = distanceFromPointToLineSegment(point: location, lineStart: posI, lineEnd: posJ)
                
                if distance < minDistance {
                    minDistance = distance
                    closestEdge = (i, j)
                }
            }
        }
        
        // If we found a valid edge, toggle it
        if let edge = closestEdge {
            gameState.toggleEdge(from: edge.u, to: edge.v)
        }
    }
    
    // MARK: - Helper: Distance from point to line segment
    
    private func distanceFromPointToLineSegment(point: CGPoint, lineStart: CGPoint, lineEnd: CGPoint) -> CGFloat {
        let dx = lineEnd.x - lineStart.x
        let dy = lineEnd.y - lineStart.y
        
        if dx == 0 && dy == 0 {
            // Line start and end are the same point
            return hypot(point.x - lineStart.x, point.y - lineStart.y)
        }
        
        // Calculate the parameter t that represents the projection of the point onto the line
        let t = max(0, min(1, ((point.x - lineStart.x) * dx + (point.y - lineStart.y) * dy) / (dx * dx + dy * dy)))
        
        // Calculate the closest point on the line segment
        let closestX = lineStart.x + t * dx
        let closestY = lineStart.y + t * dy
        
        // Return the distance from the point to the closest point on the line segment
        return hypot(point.x - closestX, point.y - closestY)
    }
    
    // MARK: - Load Puzzle
    
    private func loadPuzzle() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let newPuzzle = try await APIService.generateBridges(
                rows: 9,
                cols: 9,
                numNodes: 16,
                extraEdgeFactor: 0.40,
                doubleEdgeChance: 0.35
            )
            
            await MainActor.run {
                puzzle = newPuzzle
                gameState.update(puzzle: newPuzzle)
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}

// MARK: - Node View

struct NodeView: View {
    let node: BridgesNode
    let index: Int
    let state: BridgesGameState.NodeState
    let isSelected: Bool
    let cellSize: CGFloat
    let gridWidth: CGFloat
    let gridHeight: CGFloat
    let rows: Int
    let cols: Int
    
    var body: some View {
        let x = CGFloat(node.col) * cellSize
        let y = CGFloat(node.row) * cellSize
        
        ZStack {
            Circle()
                .fill(circleColor)
                .frame(width: cellSize * 0.6, height: cellSize * 0.6)
            
            if isSelected {
                Circle()
                    .stroke(Color.yellow, lineWidth: 3)
                    .frame(width: cellSize * 0.7, height: cellSize * 0.7)
            }
            
            Text("\(node.degree)")
                .foregroundColor(textColor)
                .font(.system(size: cellSize * 0.3, weight: .bold))
        }
        .position(x: x + cellSize / 2, y: y + cellSize / 2)
    }
    
    var circleColor: Color {
        switch state {
        case .incomplete:
            return Color(white: 0.3)
        case .complete:
            return Color.white
        case .overloaded:
            return Color.red.opacity(0.7)
        }
    }
    
    var textColor: Color {
        switch state {
        case .incomplete:
            return Color.white
        case .complete:
            return Color.black
        case .overloaded:
            return Color.white
        }
    }
}

// MARK: - Edge View

struct EdgeView: View {
    let from: BridgesNode
    let to: BridgesNode
    let count: Int
    let cellSize: CGFloat
    let gridWidth: CGFloat
    let gridHeight: CGFloat
    let rows: Int
    let cols: Int
    
    var body: some View {
        let fromX = CGFloat(from.col) * cellSize + cellSize / 2
        let fromY = CGFloat(from.row) * cellSize + cellSize / 2
        let toX = CGFloat(to.col) * cellSize + cellSize / 2
        let toY = CGFloat(to.row) * cellSize + cellSize / 2
        
        ZStack {
            if count == 1 {
                // Single line
                Path { path in
                    path.move(to: CGPoint(x: fromX, y: fromY))
                    path.addLine(to: CGPoint(x: toX, y: toY))
                }
                .stroke(Color.white, lineWidth: 3)
            } else if count == 2 {
                // Double line
                let isHorizontal = from.row == to.row
                let offset: CGFloat = cellSize * 0.12
                
                if isHorizontal {
                    // Two horizontal lines
                    Path { path in
                        path.move(to: CGPoint(x: fromX, y: fromY - offset))
                        path.addLine(to: CGPoint(x: toX, y: toY - offset))
                    }
                    .stroke(Color.white, lineWidth: 3)
                    
                    Path { path in
                        path.move(to: CGPoint(x: fromX, y: fromY + offset))
                        path.addLine(to: CGPoint(x: toX, y: toY + offset))
                    }
                    .stroke(Color.white, lineWidth: 3)
                } else {
                    // Two vertical lines
                    Path { path in
                        path.move(to: CGPoint(x: fromX - offset, y: fromY))
                        path.addLine(to: CGPoint(x: toX - offset, y: toY))
                    }
                    .stroke(Color.white, lineWidth: 3)
                    
                    Path { path in
                        path.move(to: CGPoint(x: fromX + offset, y: fromY))
                        path.addLine(to: CGPoint(x: toX + offset, y: toY))
                    }
                    .stroke(Color.white, lineWidth: 3)
                }
            }
        }
    }
}

