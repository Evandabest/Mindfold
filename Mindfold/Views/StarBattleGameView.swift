//
//  StarBattleGameView.swift
//  Mindfold
//
//  Created by Evan Haque on 1/9/26.
//

import SwiftUI

struct StarBattleGameView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showTutorial = false
    @State private var puzzle: StarBattlePuzzle?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var autofillEnabled = false
    @StateObject private var gameState: StarBattleGameState = {
        // Initialize with empty state, will be updated when puzzle loads
        let emptyRegions = Array(repeating: Array(repeating: 0, count: 8), count: 8)
        let emptySolution = Array(repeating: Array(repeating: false, count: 8), count: 8)
        return StarBattleGameState(size: 8, regions: emptyRegions, solutionStars: emptySolution)
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
                    Text("Star Battle")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .bold))
                    
                    Spacer()
                    
                    // Help and Settings icons
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
        .sheet(isPresented: $showTutorial) {
            StarBattleTutorialView()
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
    private func gameBoardView(puzzle: StarBattlePuzzle) -> some View {
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
                Spacer()
                
                VStack(spacing: 20) {
                    // Game Grid (centered)
                    VStack(spacing: 2) {
                        ForEach(0..<puzzle.size, id: \.self) { row in
                            HStack(spacing: 2) {
                                ForEach(0..<puzzle.size, id: \.self) { column in
                                    StarBattleGameCell(
                                        cellState: gameState.grid[row][column],
                                        regionColor: gameState.getRegionColor(row: row, col: column),
                                        size: cellSize,
                                        hasViolation: gameState.violationCells.contains(GridPosition(row: row, col: column)),
                                        onTap: {
                                            gameState.toggleCell(row: row, col: column, autofill: autofillEnabled)
                                        }
                                    )
                                }
                            }
                        }
                    }
                    .frame(width: boardWidth, height: boardHeight)
                    
                    // Autofill toggle
                    HStack {
                        Text("Autofill")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium))
                        
                        Toggle("", isOn: Binding(
                            get: { autofillEnabled },
                            set: { newValue in
                                autofillEnabled = newValue
                                // When toggling off, clear all black dots
                                if !newValue {
                                    gameState.clearAllDots()
                                }
                            }
                        ))
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                    }
                    
                    // Control buttons
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
                        Image(systemName: "eraser")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color(white: 0.2))
                            .cornerRadius(12)
                    }
                }
                }
                .frame(maxWidth: .infinity)
                
                Spacer()
            }
        }
    }
    
    private func loadPuzzle() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedPuzzle = try await APIService.generateStarBattle(
                size: 8,
                ensureUnique: true
            )
            await MainActor.run {
                self.puzzle = fetchedPuzzle
                // Update game state with the new puzzle
                if fetchedPuzzle.size == gameState.size {
                    // Same size - update in place
                    gameState.regions = fetchedPuzzle.regions
                    gameState.solutionStars = fetchedPuzzle.solutionStars
                    gameState.reset()
                } else {
                    // Different size - need to recreate
                    // For now, we'll just update and reset
                    gameState.regions = fetchedPuzzle.regions
                    gameState.solutionStars = fetchedPuzzle.solutionStars
                    gameState.reset()
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

// Game cell component for Star Battle
struct StarBattleGameCell: View {
    let cellState: StarBattleCellState
    let regionColor: Color
    let size: CGFloat
    let hasViolation: Bool
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            // Region background color
            RoundedRectangle(cornerRadius: 4)
                .fill(regionColor)
            
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
            if cellState == .dot {
                // Black dot (occupied but not a star)
                Circle()
                    .fill(Color.black)
                    .frame(width: size * 0.3, height: size * 0.3)
            } else if cellState == .star {
                // Star icon with black outline
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: size * 0.5))
                    .overlay(
                        Image(systemName: "star")
                            .foregroundColor(.black)
                            .font(.system(size: size * 0.5))
                    )
            }
        }
        .frame(width: size, height: size)
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    StarBattleGameView()
}
