//
//  NetwalkGameView.swift
//  Mindfold
//
//  Created by Evan Haque on 1/9/26.
//

import SwiftUI

struct NetwalkGameView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showTutorial = false
    @State private var puzzle: NetwalkPuzzle?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @StateObject private var gameState = NetwalkGameState(
        rows: 6,
        cols: 6,
        source: SourcePosition(row: 0, col: 0),
        puzzleMasks: Array(repeating: Array(repeating: 0, count: 6), count: 6),
        solutionMasks: Array(repeating: Array(repeating: 0, count: 6), count: 6),
        initialRotations: Array(repeating: Array(repeating: 0, count: 6), count: 6)
    )
    
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
                    Text("Netwalk")
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
            NetwalkTutorialView()
        }
        .alert("Level Complete!", isPresented: $gameState.isComplete) {
            Button("OK", role: .cancel) {}
        }
        .task {
            await loadPuzzle()
        }
        .toolbar(.hidden, for: .navigationBar)
    }
    
    @ViewBuilder
    private func gameBoardView(puzzle: NetwalkPuzzle) -> some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width - 40  // Account for padding
            let availableHeight = geometry.size.height - 100  // Account for header and buttons
            let cellSize = min(availableWidth / CGFloat(puzzle.cols), availableHeight / CGFloat(puzzle.rows))
            let boardWidth = cellSize * CGFloat(puzzle.cols) + 2 * CGFloat(puzzle.cols - 1)
            let boardHeight = cellSize * CGFloat(puzzle.rows) + 2 * CGFloat(puzzle.rows - 1)
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 20) {
                    // Game Grid (centered)
                    VStack(spacing: 2) {
                        ForEach(0..<puzzle.rows, id: \.self) { row in
                            HStack(spacing: 2) {
                                ForEach(0..<puzzle.cols, id: \.self) { column in
                                    NetwalkGameCell(
                                        mask: gameState.masks[row][column],
                                        isSource: gameState.isSource(row: row, col: column),
                                        isPowered: gameState.isPowered(row: row, col: column),
                                        size: cellSize,
                                        onTap: {
                                            gameState.rotateTile(row: row, col: column)
                                        }
                                    )
                                }
                            }
                        }
                    }
                    .frame(width: boardWidth, height: boardHeight)
                    
                    // Reset button
                    Button(action: {
                        gameState.reset(puzzleMasks: puzzle.puzzleMasks, initialRotations: puzzle.rotations)
                    }) {
                        Text("Reset")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .semibold))
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.red.opacity(0.7))
                            .cornerRadius(8)
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
            let fetchedPuzzle = try await APIService.generateNetwalk(
                rows: 6,
                cols: 6,
                allowCross: true,
                preferSourceDegree: 2
            )
            await MainActor.run {
                self.puzzle = fetchedPuzzle
                // Update game state with the new puzzle
                gameState.update(
                    rows: fetchedPuzzle.rows,
                    cols: fetchedPuzzle.cols,
                    source: fetchedPuzzle.source,
                    puzzleMasks: fetchedPuzzle.puzzleMasks,
                    solutionMasks: fetchedPuzzle.solutionMasks,
                    initialRotations: fetchedPuzzle.rotations
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

// Game cell component for Netwalk
struct NetwalkGameCell: View {
    let mask: Int
    let isSource: Bool
    let isPowered: Bool
    let size: CGFloat
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 4)
                .fill(isPowered ? Color.green.opacity(0.3) : Color(white: 0.2))
            
            // Source indicator
            if isSource {
                Circle()
                    .fill(Color.yellow)
                    .frame(width: size * 0.3, height: size * 0.3)
            }
            
            // Pipe connections
            PipeShape(mask: mask, size: size)
                .stroke(Color.white, lineWidth: size * 0.15)
                .fill(Color.white.opacity(0.1))
        }
        .frame(width: size, height: size)
        .onTapGesture {
            onTap()
        }
    }
}

// Shape that draws pipes based on mask
struct PipeShape: Shape {
    let mask: Int
    let size: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let pipeWidth = size * 0.2
        let halfWidth = pipeWidth / 2
        
        // Center connector (always draw if there are any pipes)
        let pipeCount = ((mask & N_BIT != 0 ? 1 : 0) + (mask & E_BIT != 0 ? 1 : 0) + (mask & S_BIT != 0 ? 1 : 0) + (mask & W_BIT != 0 ? 1 : 0))
        if pipeCount > 0 {
            let connectorSize = pipeWidth * 1.1
            path.addEllipse(in: CGRect(
                x: center.x - connectorSize / 2,
                y: center.y - connectorSize / 2,
                width: connectorSize,
                height: connectorSize
            ))
        }
        
        // Draw pipes based on mask
        if mask & N_BIT != 0 {
            // North pipe
            path.move(to: CGPoint(x: center.x - halfWidth, y: 0))
            path.addLine(to: CGPoint(x: center.x - halfWidth, y: center.y - halfWidth))
            path.addLine(to: CGPoint(x: center.x + halfWidth, y: center.y - halfWidth))
            path.addLine(to: CGPoint(x: center.x + halfWidth, y: 0))
            path.closeSubpath()
        }
        
        if mask & E_BIT != 0 {
            // East pipe
            path.move(to: CGPoint(x: center.x + halfWidth, y: center.y - halfWidth))
            path.addLine(to: CGPoint(x: rect.width, y: center.y - halfWidth))
            path.addLine(to: CGPoint(x: rect.width, y: center.y + halfWidth))
            path.addLine(to: CGPoint(x: center.x + halfWidth, y: center.y + halfWidth))
            path.closeSubpath()
        }
        
        if mask & S_BIT != 0 {
            // South pipe
            path.move(to: CGPoint(x: center.x - halfWidth, y: center.y + halfWidth))
            path.addLine(to: CGPoint(x: center.x - halfWidth, y: rect.height))
            path.addLine(to: CGPoint(x: center.x + halfWidth, y: rect.height))
            path.addLine(to: CGPoint(x: center.x + halfWidth, y: center.y + halfWidth))
            path.closeSubpath()
        }
        
        if mask & W_BIT != 0 {
            // West pipe
            path.move(to: CGPoint(x: 0, y: center.y - halfWidth))
            path.addLine(to: CGPoint(x: center.x - halfWidth, y: center.y - halfWidth))
            path.addLine(to: CGPoint(x: center.x - halfWidth, y: center.y + halfWidth))
            path.addLine(to: CGPoint(x: 0, y: center.y + halfWidth))
            path.closeSubpath()
        }
        
        return path
    }
}

#Preview {
    NetwalkGameView()
}

