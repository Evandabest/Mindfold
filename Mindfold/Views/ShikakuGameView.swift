//
//  ShikakuGameView.swift
//  Mindfold
//
//  Created by Evan Haque on 1/9/26.
//

import SwiftUI

struct ShikakuGameView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showTutorial = false
    @State private var puzzle: ShikakuPuzzle?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @StateObject private var gameState = ShikakuGameState(rows: 8, cols: 7, board: Array(repeating: Array(repeating: 0, count: 7), count: 8))
    
    // Drag gesture state
    @State private var dragStart: (x: Int, y: Int)?
    @State private var dragCurrent: (x: Int, y: Int)?
    @State private var previewRect: GridRect?
    
    let columns = 7
    let rows = 8
    
    var body: some View {
        ZStack {
            // Dark background
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Header
                HStack {
                    // Back button
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .medium))
                    }
                    
                    Spacer()
                    
                    // Game Title
                    Text("Shikaku")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .bold))
                    
                    Spacer()
                    
                    // Help icon
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
                                .padding(.vertical, 12)
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
        .alert("Level Complete!", isPresented: $gameState.isComplete) {
            Button("OK") {
                // Could add navigation or next level here
            }
        } message: {
            Text("Congratulations! You've solved the puzzle.")
        }
        .sheet(isPresented: $showTutorial) {
            ShikakuTutorialView()
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await loadPuzzle()
        }
    }
    
    // Game board view - extracted to reduce complexity
    @ViewBuilder
    private func gameBoardView(puzzle: ShikakuPuzzle) -> some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                let availableWidth = geometry.size.width - 40
                let availableHeight = geometry.size.height
                let cellSize = min(
                    availableWidth / CGFloat(puzzle.cols),
                    availableHeight / CGFloat(puzzle.rows)
                )
                
                let boardWidth = cellSize * CGFloat(puzzle.cols) + CGFloat(puzzle.cols - 1) * 2
                let boardHeight = cellSize * CGFloat(puzzle.rows) + CGFloat(puzzle.rows - 1) * 2
                let boardX = (geometry.size.width - boardWidth) / 2
                let boardY = (geometry.size.height - boardHeight) / 2
                
                gameBoardContent(
                    puzzle: puzzle,
                    cellSize: cellSize,
                    boardWidth: boardWidth,
                    boardHeight: boardHeight,
                    boardX: boardX,
                    boardY: boardY
                )
            }
            .padding(.horizontal, 20)
            
            resetButton(puzzle: puzzle)
            
            Spacer()
        }
    }
    
    // Game board content with grid and preview
    @ViewBuilder
    private func gameBoardContent(
        puzzle: ShikakuPuzzle,
        cellSize: CGFloat,
        boardWidth: CGFloat,
        boardHeight: CGFloat,
        boardX: CGFloat,
        boardY: CGFloat
    ) -> some View {
        ZStack {
            gameGrid(
                puzzle: puzzle,
                cellSize: cellSize,
                boardWidth: boardWidth,
                boardHeight: boardHeight,
                boardX: boardX,
                boardY: boardY
            )
            
            if let preview = previewRect {
                previewOverlay(
                    preview: preview,
                    cellSize: cellSize,
                    boardX: boardX,
                    boardY: boardY
                )
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    handleDragChanged(
                        location: value.location,
                        boardX: boardX,
                        boardY: boardY,
                        cellSize: cellSize,
                        cols: puzzle.cols,
                        rows: puzzle.rows
                    )
                }
                .onEnded { value in
                    handleDragEnded(
                        location: value.location,
                        boardX: boardX,
                        boardY: boardY,
                        cellSize: cellSize,
                        cols: puzzle.cols,
                        rows: puzzle.rows
                    )
                }
        )
    }
    
    // Game grid view
    @ViewBuilder
    private func gameGrid(
        puzzle: ShikakuPuzzle,
        cellSize: CGFloat,
        boardWidth: CGFloat,
        boardHeight: CGFloat,
        boardX: CGFloat,
        boardY: CGFloat
    ) -> some View {
        VStack(spacing: 2) {
            ForEach(0..<puzzle.rows, id: \.self) { row in
                HStack(spacing: 2) {
                    ForEach(0..<puzzle.cols, id: \.self) { column in
                        ShikakuGameCell(
                            cellState: gameState.grid[row][column],
                            size: cellSize
                        )
                        .id("\(row)-\(column)-\(gameState.updateTrigger)")
                    }
                }
            }
        }
        .frame(width: boardWidth, height: boardHeight)
        .position(x: boardX + boardWidth / 2, y: boardY + boardHeight / 2)
        .allowsHitTesting(true)
    }
    
    // Preview overlay
    @ViewBuilder
    private func previewOverlay(
        preview: GridRect,
        cellSize: CGFloat,
        boardX: CGFloat,
        boardY: CGFloat
    ) -> some View {
        let previewWidth = cellSize * CGFloat(preview.width) + CGFloat(preview.width - 1) * 2
        let previewHeight = cellSize * CGFloat(preview.height) + CGFloat(preview.height - 1) * 2
        let startX = boardX + cellSize * CGFloat(preview.x) + CGFloat(preview.x) * 2
        let startY = boardY + cellSize * CGFloat(preview.y) + CGFloat(preview.y) * 2
        let previewX = startX + previewWidth / 2
        let previewY = startY + previewHeight / 2
        
        RoundedRectangle(cornerRadius: 4)
            .fill(Color.white.opacity(0.3))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.white, lineWidth: 2)
            )
            .frame(width: previewWidth, height: previewHeight)
            .position(x: previewX, y: previewY)
            .allowsHitTesting(false)
    }
    
    // Control buttons
    @ViewBuilder
    private func resetButton(puzzle: ShikakuPuzzle) -> some View {
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
                gameState.reset(with: puzzle.board)
            }) {
                Image(systemName: "eraser")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color(white: 0.2))
                    .cornerRadius(12)
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
    
    private func loadPuzzle() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedPuzzle = try await APIService.generateShikaku(
                rows: rows,
                cols: columns
            )
            await MainActor.run {
                self.puzzle = fetchedPuzzle
                // Reset game state with the new puzzle
                self.gameState.reset(with: fetchedPuzzle.board)
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    // Convert screen coordinates to grid coordinates
    private func screenToGrid(
        location: CGPoint,
        boardX: CGFloat,
        boardY: CGFloat,
        cellSize: CGFloat
    ) -> (x: Int, y: Int)? {
        let relativeX = location.x - boardX
        let relativeY = location.y - boardY
        
        guard relativeX >= 0 && relativeY >= 0 else { return nil }
        
        // Account for 2px spacing between cells
        // Each cell position: cellSize pixels + 2px spacing = cellSize + 2
        let cellWithSpacing = cellSize + 2
        
        // Calculate grid position
        // For each column/row, we have: cellSize pixels + 2px spacing
        let x = Int(relativeX / cellWithSpacing)
        let y = Int(relativeY / cellWithSpacing)
        
        // Check if we're within bounds
        guard x >= 0 && x < columns && y >= 0 && y < rows else { return nil }
        
        // Check if touch is within the actual cell (not in spacing)
        let cellStartX = CGFloat(x) * cellWithSpacing
        let cellStartY = CGFloat(y) * cellWithSpacing
        let cellEndX = cellStartX + cellSize
        let cellEndY = cellStartY + cellSize
        
        // If touch is in spacing area, return nil (or snap to nearest cell)
        if relativeX > cellEndX || relativeY > cellEndY {
            // Touch is in spacing, snap to the cell we're closest to
            return (x: x, y: y)
        }
        
        return (x: x, y: y)
    }
    
    // Handle drag changed
    private func handleDragChanged(
        location: CGPoint,
        boardX: CGFloat,
        boardY: CGFloat,
        cellSize: CGFloat,
        cols: Int,
        rows: Int
    ) {
        guard let gridPos = screenToGrid(
            location: location,
            boardX: boardX,
            boardY: boardY,
            cellSize: cellSize
        ) else { return }
        
        if dragStart == nil {
            // Start of drag - check if we're starting on an occupied cell
            if let rectId = gameState.findRectangleAt(x: gridPos.x, y: gridPos.y) {
                // Remove the rectangle at this position
                gameState.removeRectangle(id: rectId)
            }
            
            // Start of drag
            dragStart = gridPos
            dragCurrent = gridPos
        } else {
            // Update current position
            dragCurrent = gridPos
        }
        
        // Calculate preview rectangle
        if let start = dragStart, let current = dragCurrent {
            let minX = min(start.x, current.x)
            let maxX = max(start.x, current.x)
            let minY = min(start.y, current.y)
            let maxY = max(start.y, current.y)
            
            previewRect = GridRect(
                x: minX,
                y: minY,
                width: maxX - minX + 1,
                height: maxY - minY + 1
            )
        }
    }
    
    // Handle drag ended
    private func handleDragEnded(
        location: CGPoint,
        boardX: CGFloat,
        boardY: CGFloat,
        cellSize: CGFloat,
        cols: Int,
        rows: Int
    ) {
        guard let start = dragStart, let current = dragCurrent else {
            // If no drag occurred, check if it was a tap on an occupied cell
            if let gridPos = screenToGrid(
                location: location,
                boardX: boardX,
                boardY: boardY,
                cellSize: cellSize
            ) {
                if let rectId = gameState.findRectangleAt(x: gridPos.x, y: gridPos.y) {
                    gameState.removeRectangle(id: rectId)
                }
            }
            
            dragStart = nil
            dragCurrent = nil
            previewRect = nil
            return
        }
        
        // If start and end are the same, treat as a tap
        if start.x == current.x && start.y == current.y {
            // Single tap - check if it's on an occupied cell (already handled in dragChanged)
            dragStart = nil
            dragCurrent = nil
            previewRect = nil
            return
        }
        
        // Calculate final rectangle
        let minX = min(start.x, current.x)
        let maxX = max(start.x, current.x)
        let minY = min(start.y, current.y)
        let maxY = max(start.y, current.y)
        
        let rect = GridRect(
            x: minX,
            y: minY,
            width: maxX - minX + 1,
            height: maxY - minY + 1
        )
        
        // Try to place the rectangle
        let success = gameState.placeRectangle(rect)
        
        // Reset drag state
        dragStart = nil
        dragCurrent = nil
        previewRect = nil
        
        // Debug: Print if placement failed
        if !success {
            print("Failed to place rectangle: x=\(rect.x), y=\(rect.y), w=\(rect.width), h=\(rect.height), area=\(rect.area)")
            print("Available hints: \(gameState.hintPositions)")
        } else {
            print("✅ Successfully placed rectangle: x=\(rect.x), y=\(rect.y), w=\(rect.width), h=\(rect.height), area=\(rect.area)")
        }
    }
}

// Game cell component for Shikaku
struct ShikakuGameCell: View {
    let cellState: CellState
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Background color based on state
            RoundedRectangle(cornerRadius: 4)
                .fill(backgroundColor)
            
            // Hint number - show if it's a hint cell OR if it's occupied and has a hint
            if case .hint(let value) = cellState {
                Text("\(value)")
                    .foregroundColor(.white)
                    .font(.system(size: size * 0.3, weight: .bold))
            } else if case .occupied(_, _, let hintValue) = cellState, let value = hintValue {
                Text("\(value)")
                    .foregroundColor(.white)
                    .font(.system(size: size * 0.3, weight: .bold))
            }
        }
        .frame(width: size, height: size)
    }
    
    private var backgroundColor: Color {
        switch cellState {
        case .empty:
            return Color(white: 0.2)
        case .hint:
            return Color(white: 0.2)
        case .occupied(let color, _, _):
            // Use more opaque color like in the screenshot
            return color.opacity(0.85)
        }
    }
}

// Toolbar button component
struct ToolbarButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .foregroundColor(.white)
                .font(.system(size: 24))
                .frame(width: 50, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(white: 0.2))
                )
        }
    }
}

#Preview {
    ShikakuGameView()
}

