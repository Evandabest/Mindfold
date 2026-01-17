//
//  NumberSnakeGameView.swift
//  Mindfold
//
//  Created by Evan Haque on 1/15/26.
//

import SwiftUI

struct NumberSnakeGameView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showTutorial = false
    @State private var puzzle: NumberSnakePuzzle?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @StateObject private var gameState = NumberSnakeGameState(rows: 5, cols: 5, clues: [])
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Header
                GameHeaderView(
                    gameTitle: "Number Snake",
                    onDismiss: { dismiss() },
                    onHelp: { showTutorial = true }
                )
                
                // Error message (if any)
                if let error = gameState.errorMessage {
                    Text(error)
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.red.opacity(0.3))
                        .cornerRadius(8)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)
                }
                
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
            NumberSnakeTutorialView()
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
    private func gameBoardView(puzzle: NumberSnakePuzzle) -> some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width - 40
            let availableHeight = geometry.size.height - 100
            let cellSize = min(availableWidth / CGFloat(puzzle.cols), availableHeight / CGFloat(puzzle.rows))
            let gridWidth = cellSize * CGFloat(puzzle.cols)
            let gridHeight = cellSize * CGFloat(puzzle.rows)
            
            VStack(spacing: 0) {
                Spacer()
                
                // Grid
                HStack {
                    Spacer()
                    ZStack(alignment: .topLeading) {
                        // Background grid
                        ForEach(0..<puzzle.rows, id: \.self) { row in
                            ForEach(0..<puzzle.cols, id: \.self) { col in
                                let pos = GridPos(row: row, col: col)
                                CellView(
                                    pos: pos,
                                    cellSize: cellSize,
                                    isInPath: gameState.isInPath(pos),
                                    clueValue: getClueValue(row: row, col: col),
                                    pathColor: gameState.getPathSegmentColor(for: pos)
                                )
                                .position(
                                    x: CGFloat(col) * cellSize + cellSize / 2,
                                    y: CGFloat(row) * cellSize + cellSize / 2
                                )
                            }
                        }
                    }
                    .frame(width: gridWidth, height: gridHeight)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                handleDrag(location: value.location, cellSize: cellSize, isStart: value.translation == .zero)
                            }
                            .onEnded { _ in
                                // Drag ended
                            }
                    )
                    Spacer()
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
                gameState.clearPath()
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
                Image(systemName: "eraser")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color(white: 0.2))
                    .cornerRadius(12)
            }
        }
        .padding(.bottom, 30)
    }
    
    // MARK: - Drag Handler
    
    private func handleDrag(location: CGPoint, cellSize: CGFloat, isStart: Bool) {
        let col = Int(location.x / cellSize)
        let row = Int(location.y / cellSize)
        
        let pos = GridPos(row: row, col: col)
        
        if isStart {
            gameState.startPath(at: pos)
        } else {
            gameState.extendPath(to: pos)
        }
    }
    
    // MARK: - Helper
    
    private func getClueValue(row: Int, col: Int) -> Int? {
        return puzzle?.clues.first(where: { $0.row == row && $0.col == col })?.value
    }
    
    // MARK: - Load Puzzle
    
    private func loadPuzzle() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let newPuzzle = try await APIService.generateNumberSnake(
                rows: 5,
                cols: 5,
                numClues: 6
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

// MARK: - Cell View

struct CellView: View {
    let pos: GridPos
    let cellSize: CGFloat
    let isInPath: Bool
    let clueValue: Int?
    let pathColor: Color?
    
    var body: some View {
        ZStack {
            // Cell background
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color(white: 0.3), lineWidth: 1)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(backgroundColor)
                )
            
            // Clue number (if present)
            if let value = clueValue {
                Circle()
                    .fill(Color.white)
                    .frame(width: cellSize * 0.5, height: cellSize * 0.5)
                
                Text("\(value)")
                    .foregroundColor(.black)
                    .font(.system(size: cellSize * 0.25, weight: .bold))
            }
        }
        .frame(width: cellSize - 2, height: cellSize - 2)
    }
    
    var backgroundColor: Color {
        if isInPath, let pathColor = pathColor {
            return pathColor
        }
        return Color(white: 0.15)
    }
}

