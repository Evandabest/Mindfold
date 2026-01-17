//
//  FloodfillGameView.swift
//  Mindfold
//
//  Created by Evan Haque on 1/15/26.
//

import SwiftUI

struct FloodfillGameView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var gameState: FloodfillGameState
    @State private var puzzle: FloodfillPuzzle?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showTutorial = false
    
    init() {
        // Create a placeholder game state - will be updated when puzzle loads
        _gameState = StateObject(wrappedValue: FloodfillGameState(rows: 12, cols: 12, numColors: 4, moveLimit: 4))
    }
    
    var body: some View {
        ZStack {
            // Dark background
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                gameHeader
                
                if isLoading {
                    Spacer()
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                    Text("Loading puzzle...")
                        .foregroundColor(.gray)
                        .padding(.top, 16)
                    Spacer()
                } else if let error = errorMessage {
                    Spacer()
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .padding()
                    Button("Retry") {
                        Task { await loadPuzzle() }
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                    Spacer()
                } else {
                    // Game content
                    gameContent
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await loadPuzzle()
        }
        .sheet(isPresented: $showTutorial) {
            FloodfillTutorialView()
        }
        .alert("Level Complete!", isPresented: $gameState.isComplete) {
            Button("OK") {
                // Could add navigation or next level here
            }
        } message: {
            Text("Congratulations! You've solved the puzzle.")
        }
    }
    
    // MARK: - Header
    private var gameHeader: some View {
        HStack {
            // Back button
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .medium))
            }
            
            Spacer()
            
            // Title
            Text("Flood Fill")
                .foregroundColor(.white)
                .font(.system(size: 20, weight: .semibold))
            
            Spacer()
            
            // Help button
            Button(action: { showTutorial = true }) {
                Image(systemName: "questionmark.circle")
                    .foregroundColor(.white)
                    .font(.system(size: 20))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    
    // MARK: - Game Content
    private var gameContent: some View {
        VStack(spacing: 16) {
            // Moves remaining
            Text("\(gameState.movesRemaining) moves")
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .medium))
                .padding(.vertical, 8)
                .padding(.horizontal, 24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white, lineWidth: 2)
                )
            
            Spacer()
            
            // Game grid
            gameGrid
            
            Spacer()
            
            // Controls
            controlsView
        }
        .padding(.top, 16)
    }
    
    // MARK: - Game Grid
    private var gameGrid: some View {
        GeometryReader { geometry in
            let availableSize = min(geometry.size.width, geometry.size.height) - 40
            let cellSize = availableSize / CGFloat(max(gameState.rows, gameState.cols))
            let gridWidth = cellSize * CGFloat(gameState.cols)
            let gridHeight = cellSize * CGFloat(gameState.rows)
            
            VStack(spacing: 1) {
                ForEach(0..<gameState.rows, id: \.self) { row in
                    HStack(spacing: 1) {
                        ForEach(0..<gameState.cols, id: \.self) { col in
                            Button(action: {
                                gameState.applyMove(row: row, col: col)
                            }) {
                                Rectangle()
                                    .fill(gameState.getColor(for: gameState.grid[row][col]))
                                    .frame(width: cellSize, height: cellSize)
                            }
                            .disabled(gameState.isComplete)
                        }
                    }
                }
            }
            .frame(width: gridWidth, height: gridHeight)
            .background(Color.black)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
    
    // MARK: - Controls
    private var controlsView: some View {
        VStack(spacing: 16) {
            // Color picker
            HStack(spacing: 16) {
                ForEach(0..<gameState.numColors, id: \.self) { index in
                    Button(action: {
                        gameState.selectedColorIndex = index
                    }) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(gameState.getColor(for: index))
                            .frame(width: 60, height: 60)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(gameState.selectedColorIndex == index ? Color.white : Color.clear, lineWidth: 3)
                            )
                    }
                }
            }
            
            // Action buttons
            HStack(spacing: 24) {
                // Undo button
                Button(action: {
                    gameState.undo()
                }) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 28))
                        .foregroundColor(gameState.canUndo ? .white : .gray)
                        .frame(width: 60, height: 60)
                        .background(Color(white: 0.2))
                        .cornerRadius(12)
                }
                .disabled(!gameState.canUndo)
                
                // Reset button
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
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    // MARK: - Load Puzzle
    private func loadPuzzle() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedPuzzle = try await APIService.generateFloodfill(
                rows: 12,
                cols: 12,
                numColors: 4,
                moveLimit: 8
            )
            
            await MainActor.run {
                self.puzzle = fetchedPuzzle
                
                // Update the game state with new puzzle
                self.gameState.update(with: fetchedPuzzle)
                
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

// MARK: - Preview
#Preview {
    FloodfillGameView()
}

