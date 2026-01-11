//
//  TakuzuGameView.swift
//  Mindfold
//
//  Created by Evan Haque on 1/9/26.
//

import SwiftUI

struct TakuzuGameView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showTutorial = false
    @State private var puzzle: TakuzuPuzzle?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @StateObject private var gameState: TakuzuGameState = {
        // Initialize with empty state, will be updated when puzzle loads
        let emptyPuzzle = Array(repeating: Array(repeating: nil as Int?, count: 8), count: 8)
        let emptySolution = Array(repeating: Array(repeating: 0, count: 8), count: 8)
        return TakuzuGameState(size: 8, puzzle: emptyPuzzle, solution: emptySolution)
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
                    Text("Takuzu")
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
            TakuzuTutorialView()
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
    private func gameBoardView(puzzle: TakuzuPuzzle) -> some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width - 40 // Account for padding
            let availableHeight = geometry.size.height - 100 // Account for reset button
            let cellSize = min(
                availableWidth / CGFloat(puzzle.size),
                availableHeight / CGFloat(puzzle.size)
            )
            
            let boardWidth = cellSize * CGFloat(puzzle.size) + CGFloat(puzzle.size - 1) * 2
            let boardHeight = cellSize * CGFloat(puzzle.size) + CGFloat(puzzle.size - 1) * 2
            
            VStack(spacing: 0) {
                // Game Grid
                VStack(spacing: 2) {
                    ForEach(0..<puzzle.size, id: \.self) { row in
                        HStack(spacing: 2) {
                            ForEach(0..<puzzle.size, id: \.self) { column in
                                TakuzuGameCell(
                                    cellState: gameState.grid[row][column],
                                    size: cellSize,
                                    hasViolation: gameState.violationCells.contains(GridPosition(row: row, col: column)),
                                    onTap: {
                                        gameState.toggleCell(row: row, col: column)
                                    }
                                )
                            }
                        }
                    }
                }
                .frame(width: boardWidth, height: boardHeight)
                .padding(.horizontal, 20)
                
                // Reset button
                Button(action: {
                    gameState.reset(with: puzzle.puzzle)
                }) {
                    Text("Reset")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .semibold))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.red.opacity(0.7))
                        .cornerRadius(8)
                }
                .padding(.top, 20)
                .padding(.bottom, 10)
            }
        }
    }
    
    private func loadPuzzle() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedPuzzle = try await APIService.generateTakuzu(
                size: 8,
                givensRatio: 0.45,
                ensureUnique: true
            )
            await MainActor.run {
                self.puzzle = fetchedPuzzle
                // Update game state with the new puzzle
                // If size matches, reset; otherwise we need to recreate
                if fetchedPuzzle.size == gameState.size {
                    gameState.solution = fetchedPuzzle.solution
                    gameState.reset(with: fetchedPuzzle.puzzle)
                } else {
                    // Size changed - need to recreate state
                    // This is a limitation - we can't change @StateObject
                    // For now, we'll just reset and update solution
                    // In a real app, you might want to handle this differently
                    gameState.solution = fetchedPuzzle.solution
                    gameState.reset(with: fetchedPuzzle.puzzle)
                }
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

// Game cell component for Takuzu
struct TakuzuGameCell: View {
    let cellState: TakuzuCellState
    let size: CGFloat
    let hasViolation: Bool
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            // Background color
            RoundedRectangle(cornerRadius: 4)
                .fill(backgroundColor)
            
            // Violation overlay (red highlight)
            if hasViolation {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.red.opacity(0.4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.red, lineWidth: 2)
                    )
            }
            
            // Cell content
            if case .given(let value) = cellState {
                // Given value - show as circle
                Circle()
                    .fill(value == 0 ? Color.white : Color.black)
                    .frame(width: size * 0.5, height: size * 0.5)
            } else if case .filled(let value) = cellState {
                // User-filled value - show as circle
                Circle()
                    .fill(value == 0 ? Color.white : Color.black)
                    .frame(width: size * 0.5, height: size * 0.5)
            }
        }
        .frame(width: size, height: size)
        .onTapGesture {
            onTap()
        }
    }
    
    private var backgroundColor: Color {
        switch cellState {
        case .empty:
            return Color(white: 0.2)
        case .given:
            return Color(white: 0.15)  // Slightly darker for given cells
        case .filled:
            return Color(white: 0.2)
        }
    }
}

#Preview {
    TakuzuGameView()
}
