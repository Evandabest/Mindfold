//
//  LITSGameView.swift
//  Mindfold
//
//  Created by Evan Haque on 1/9/26.
//

import SwiftUI

struct LITSGameView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showTutorial = false
    @State private var puzzle: LITSPuzzle?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var dragStart: GridPosition?
    @State private var dragCurrent: GridPosition?
    @State private var previewCells: Set<GridPosition> = []
    @StateObject private var gameState: LITSGameState = {
        let emptyRegions = Array(repeating: Array(repeating: 0, count: 7), count: 6)
        let emptyShape = Array(repeating: Array(repeating: nil as String?, count: 7), count: 6)
        let emptyFilled = Array(repeating: Array(repeating: false, count: 7), count: 6)
        return LITSGameState(rows: 6, cols: 7, regions: emptyRegions, solutionShape: emptyShape, solutionFilled: emptyFilled)
    }()
    
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
                    Text("LITS")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .bold))
                    
                    Spacer()
                    
                    // Help and Settings icons
                    HStack(spacing: 16) {
                        Button(action: { showTutorial = true }) {
                            Image(systemName: "questionmark.bubble")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                        }
                        
                        Button(action: {}) {
                            Image(systemName: "gearshape")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                        }
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
        .sheet(isPresented: $showTutorial) {
            LITSTutorialView()
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await loadPuzzle()
        }
        .alert("Level Complete!", isPresented: $gameState.isComplete) {
            Button("OK") {
                // Could add navigation or next level here
            }
        } message: {
            Text("Congratulations! You've solved the puzzle.")
        }
    }
    
    @ViewBuilder
    private func gameBoardView(puzzle: LITSPuzzle) -> some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width - 40
            let availableHeight = geometry.size.height - 120
            let cellSize = min(
                availableWidth / CGFloat(puzzle.cols),
                availableHeight / CGFloat(puzzle.rows)
            )
            
            let boardWidth = cellSize * CGFloat(puzzle.cols) + CGFloat(puzzle.cols - 1) * 2
            let boardHeight = cellSize * CGFloat(puzzle.rows) + CGFloat(puzzle.rows - 1) * 2
            let boardX = (geometry.size.width - boardWidth) / 2
            let boardY = (geometry.size.height - boardHeight - 80) / 2
            
            VStack(spacing: 0) {
                // Game Grid
                ZStack {
                    VStack(spacing: 2) {
                        ForEach(0..<puzzle.rows, id: \.self) { row in
                            HStack(spacing: 2) {
                                ForEach(0..<puzzle.cols, id: \.self) { column in
                                    LITSGameCell(
                                        cellState: gameState.grid[row][column],
                                        regionColor: gameState.getRegionColor(regionId: puzzle.regions[row][column]),
                                        size: cellSize,
                                        isPreview: previewCells.contains(GridPosition(row: row, col: column)),
                                        regionId: puzzle.regions[row][column],
                                        regions: puzzle.regions,
                                        row: row,
                                        col: column,
                                        isValid: gameState.isRegionValid(regionId: puzzle.regions[row][column]),
                                        isViolated: gameState.violationCells.contains(GridPosition(row: row, col: column))
                                    )
                                    .id("\(row)-\(column)-\(gameState.updateTrigger)")
                                }
                            }
                        }
                    }
                    .frame(width: boardWidth, height: boardHeight)
                    .position(x: boardX + boardWidth / 2, y: boardY + boardHeight / 2)
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            handleDragChanged(
                                location: value.location,
                                boardX: boardX,
                                boardY: boardY,
                                cellSize: cellSize,
                                puzzle: puzzle
                            )
                        }
                        .onEnded { value in
                            handleDragEnded(
                                location: value.location,
                                boardX: boardX,
                                boardY: boardY,
                                cellSize: cellSize,
                                puzzle: puzzle
                            )
                        }
                )
                
                Spacer()
                
                // Controls
                Button(action: {
                    gameState.reset()
                }) {
                    Text("Reset")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .medium))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.red.opacity(0.7))
                        .cornerRadius(8)
                }
                .padding(.top, 20)
                .padding(.bottom, 10)
            }
        }
        .padding(.horizontal, 20)
    }
    
    
    // Convert screen coordinates to grid coordinates
    private func screenToGrid(
        location: CGPoint,
        boardX: CGFloat,
        boardY: CGFloat,
        cellSize: CGFloat,
        cols: Int,
        rows: Int
    ) -> GridPosition? {
        let relativeX = location.x - boardX
        let relativeY = location.y - boardY
        
        guard relativeX >= 0 && relativeY >= 0 else { return nil }
        
        // Account for 2px spacing between cells
        let cellWithSpacing = cellSize + 2
        
        let col = Int(relativeX / cellWithSpacing)
        let row = Int(relativeY / cellWithSpacing)
        
        // Check if we're within bounds
        guard col >= 0 && col < cols && row >= 0 && row < rows else { return nil }
        
        return GridPosition(row: row, col: col)
    }
    
    // Handle drag changed
    private func handleDragChanged(
        location: CGPoint,
        boardX: CGFloat,
        boardY: CGFloat,
        cellSize: CGFloat,
        puzzle: LITSPuzzle
    ) {
        guard let gridPos = screenToGrid(
            location: location,
            boardX: boardX,
            boardY: boardY,
            cellSize: cellSize,
            cols: puzzle.cols,
            rows: puzzle.rows
        ) else { return }
        
        if dragStart == nil {
            // Start of drag
            dragStart = gridPos
            dragCurrent = gridPos
        } else {
            // Update current position
            dragCurrent = gridPos
        }
        
        // Calculate preview cells (all cells between start and current in the same region)
        if let start = dragStart, let current = dragCurrent {
            let startRegion = puzzle.regions[start.row][start.col]
            var newPreviewCells: Set<GridPosition> = []
            
            let minRow = min(start.row, current.row)
            let maxRow = max(start.row, current.row)
            let minCol = min(start.col, current.col)
            let maxCol = max(start.col, current.col)
            
            for r in minRow...maxRow {
                for c in minCol...maxCol {
                    if puzzle.regions[r][c] == startRegion {
                        newPreviewCells.insert(GridPosition(row: r, col: c))
                    }
                }
            }
            
            previewCells = newPreviewCells
        }
    }
    
    // Handle drag ended
    private func handleDragEnded(
        location: CGPoint,
        boardX: CGFloat,
        boardY: CGFloat,
        cellSize: CGFloat,
        puzzle: LITSPuzzle
    ) {
        guard let start = dragStart, let current = dragCurrent else {
            dragStart = nil
            dragCurrent = nil
            previewCells = []
            return
        }
        
        // Toggle all preview cells
        if !previewCells.isEmpty {
            // Determine if we should fill or clear based on first cell
            let firstCell = previewCells.first!
            let currentState = gameState.grid[firstCell.row][firstCell.col]
            
            for cell in previewCells {
                switch currentState {
                case .empty:
                    gameState.setCellFilled(row: cell.row, col: cell.col)
                case .filled:
                    gameState.setCellEmpty(row: cell.row, col: cell.col)
                case .marked:
                    gameState.setCellFilled(row: cell.row, col: cell.col)
                }
            }
        }
        
        // Reset drag state
        dragStart = nil
        dragCurrent = nil
        previewCells = []
    }
    
    
    private func loadPuzzle() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedPuzzle = try await APIService.generateLITS(
                rows: 6,
                cols: 7
            )
            await MainActor.run {
                self.puzzle = fetchedPuzzle
                // Update game state with the puzzle
                self.gameState.update(
                    rows: fetchedPuzzle.rows,
                    cols: fetchedPuzzle.cols,
                    regions: fetchedPuzzle.regions,
                    solutionShape: fetchedPuzzle.solutionShape,
                    solutionFilled: fetchedPuzzle.solutionFilled
                )
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}

// Game cell component for LITS
struct LITSGameCell: View {
    let cellState: LITSCellState
    let regionColor: Color
    let size: CGFloat
    let isPreview: Bool
    let regionId: Int
    let regions: [[Int]]
    let row: Int
    let col: Int
    let isValid: Bool
    let isViolated: Bool
    
    var body: some View {
        ZStack {
            // Background color based on state
            RoundedRectangle(cornerRadius: 4)
                .fill(backgroundColor)
            
            // Preview overlay
            if isPreview && cellState == .empty {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(white: 0.4).opacity(0.5))
            }
            
            // Marked cell (X)
            if case .marked = cellState {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .font(.system(size: size * 0.4, weight: .bold))
            }
        }
        .frame(width: size, height: size)
        .overlay(
            // Region outline (white border only on boundaries)
            regionBorder
        )
        .overlay(
            // Red border for violations
            Group {
                if isViolated {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.red, lineWidth: 3)
                }
            }
        )
    }
    
    private var backgroundColor: Color {
        switch cellState {
        case .empty, .marked:
            // Grey background
            return Color(white: 0.2)
        case .filled:
            // Light gray if invalid shape, vibrant color if valid
            if isValid {
                return regionColor
            } else {
                return Color(white: 0.5)  // Light gray for invalid shapes
            }
        }
    }
    
    // White border for region boundaries only
    private var regionBorder: some View {
        let rows = regions.count
        let cols = regions[0].count
        let borderWidth: CGFloat = 2
        
        return ZStack {
            // Top edge - white if different region above or grid edge
            if row == 0 || (row > 0 && regions[row - 1][col] != regionId) {
                Rectangle()
                    .fill(Color.white)
                    .frame(width: size, height: borderWidth)
                    .offset(y: -size/2)
            }
            
            // Bottom edge - white if different region below or grid edge
            if row == rows - 1 || (row < rows - 1 && regions[row + 1][col] != regionId) {
                Rectangle()
                    .fill(Color.white)
                    .frame(width: size, height: borderWidth)
                    .offset(y: size/2)
            }
            
            // Left edge - white if different region to left or grid edge
            if col == 0 || (col > 0 && regions[row][col - 1] != regionId) {
                Rectangle()
                    .fill(Color.white)
                    .frame(width: borderWidth, height: size)
                    .offset(x: -size/2)
            }
            
            // Right edge - white if different region to right or grid edge
            if col == cols - 1 || (col < cols - 1 && regions[row][col + 1] != regionId) {
                Rectangle()
                    .fill(Color.white)
                    .frame(width: borderWidth, height: size)
                    .offset(x: size/2)
            }
        }
    }
}

#Preview {
    LITSGameView()
}

