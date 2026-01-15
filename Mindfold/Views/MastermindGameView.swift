//
//  MastermindGameView.swift
//  Mindfold
//
//  Created by Evan Haque on 1/15/26.
//

import SwiftUI

struct MastermindGameView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var gameState: MastermindGameState
    @State private var puzzle: MastermindPuzzle?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showTutorial = false
    
    init() {
        // Create a placeholder game state - will be updated when puzzle loads
        _gameState = StateObject(wrappedValue: MastermindGameState(codeLen: 4, numColors: 4, secretCode: [0, 1, 2, 3]))
    }
    
    var body: some View {
        ZStack {
            // Dark background
            Color(red: 0.08, green: 0.1, blue: 0.12).ignoresSafeArea()
            
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
            MastermindTutorialView()
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
            Text("Mastermind")
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
            // Secret code row (with question marks)
            secretCodeRow
            
            // Guess rows (reversed order - bottom to top)
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 8) {
                        // Empty rows at the top
                        let emptyRows = max(0, gameState.maxGuesses - gameState.guesses.count - (gameState.isComplete ? 0 : 1))
                        ForEach(0..<emptyRows, id: \.self) { _ in
                            emptyGuessRow
                        }
                        
                        // Previous guesses (in reverse order, most recent at bottom)
                        ForEach(Array(gameState.guesses.enumerated().reversed()), id: \.element.id) { index, guess in
                            guessRow(guess: guess, rowIndex: index)
                        }
                        
                        // Current guess row at the bottom (if game not complete)
                        if !gameState.isComplete {
                            currentGuessRow
                                .id("current")
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .onChange(of: gameState.guesses.count) { _, _ in
                    withAnimation {
                        proxy.scrollTo("current", anchor: .bottom)
                    }
                }
            }
            
            Spacer()
            
            // Color picker
            if !gameState.isComplete {
                colorPicker
            } else {
                gameOverView
            }
        }
        .padding(.top, 16)
    }
    
    // MARK: - Secret Code Row
    private var secretCodeRow: some View {
        HStack(spacing: 12) {
            ForEach(0..<gameState.codeLen, id: \.self) { index in
                if gameState.isComplete {
                    // Show the secret code
                    Circle()
                        .fill(gameState.getColor(for: gameState.getSecretCode()[index]))
                        .frame(width: 44, height: 44)
                } else {
                    // Show question marks
                    ZStack {
                        Circle()
                            .fill(Color(white: 0.3))
                            .frame(width: 44, height: 44)
                        Text("?")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .bold))
                    }
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(white: 0.5), lineWidth: 2)
        )
        .padding(.horizontal, 40)
    }
    
    // MARK: - Guess Rows
    private func guessRow(guess: GuessRow, rowIndex: Int) -> some View {
        HStack(spacing: 0) {
            Spacer()
            
            // Color balls
            HStack(spacing: 12) {
                ForEach(0..<gameState.codeLen, id: \.self) { index in
                    Circle()
                        .fill(gameState.getColor(for: guess.colors[index]))
                        .frame(width: 44, height: 44)
                }
            }
            
            // Feedback dots (very close spacing)
            feedbackView(feedback: guess.feedback)
                .padding(.leading, 16)
            
            Spacer()
        }
        .padding(.vertical, 8)
        .background(
            Rectangle()
                .fill(Color.clear)
                .overlay(
                    Rectangle()
                        .fill(Color(white: 0.4))
                        .frame(height: 1),
                    alignment: .bottom
                )
        )
    }
    
    private var currentGuessRow: some View {
        HStack(spacing: 0) {
            Spacer()
            
            // Color balls (not tappable, filled automatically)
            HStack(spacing: 12) {
                ForEach(0..<gameState.codeLen, id: \.self) { index in
                    Circle()
                        .fill(colorForCurrentGuess(at: index))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        )
                }
            }
            
            // Submit button (only visible when guess is complete)
            if gameState.isCurrentGuessComplete {
                Button(action: {
                    print("=== Submitting Guess ===")
                    let guessColors = gameState.currentGuess.compactMap { $0 }
                    print("Guess: \(guessColors)")
                    let secret = gameState.getSecretCode()
                    print("Secret: \(secret)")
                    
                    gameState.submitGuess()
                    
                    if let lastGuess = gameState.guesses.last {
                        print("Feedback: \(lastGuess.feedback.exactMatches) exact, \(lastGuess.feedback.colorMatches) color-only")
                    }
                    print("=======================")
                }) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                        .frame(width: 44, height: 44)
                        .background(Color(white: 0.3))
                        .clipShape(Circle())
                }
                .padding(.leading, 16)
            } else {
                // Placeholder for alignment
                Spacer()
                    .frame(width: 60)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .background(
            Rectangle()
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            Rectangle()
                .fill(Color(white: 0.4))
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    private func colorForCurrentGuess(at index: Int) -> Color {
        if let colorIndex = gameState.currentGuess[index] {
            return gameState.getColor(for: colorIndex)
        } else {
            return Color(white: 0.3)
        }
    }
    
    private var emptyGuessRow: some View {
        HStack(spacing: 0) {
            Spacer()
            
            HStack(spacing: 12) {
                ForEach(0..<gameState.codeLen, id: \.self) { _ in
                    Circle()
                        .fill(Color(white: 0.25))
                        .frame(width: 44, height: 44)
                }
            }
            
            Spacer()
                .frame(width: 60)
            
            Spacer()
        }
        .padding(.vertical, 8)
        .background(
            Rectangle()
                .fill(Color.clear)
                .overlay(
                    Rectangle()
                        .fill(Color(white: 0.4))
                        .frame(height: 1),
                    alignment: .bottom
                )
        )
    }
    
    // MARK: - Feedback View
    private func feedbackView(feedback: GuessFeedback) -> some View {
        let totalFeedback = feedback.exactMatches + feedback.colorMatches
        let columns = 2
        
        return VStack(spacing: 4) {
            ForEach(0..<2, id: \.self) { row in
                HStack(spacing: 4) {
                    ForEach(0..<columns, id: \.self) { col in
                        let index = row * columns + col
                        if index < feedback.exactMatches {
                            // Filled circle - exact match
                            Circle()
                                .fill(Color.white)
                                .frame(width: 12, height: 12)
                        } else if index < totalFeedback {
                            // Empty circle - color match
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                                .frame(width: 12, height: 12)
                        } else if index < gameState.codeLen {
                            // No match
                            Circle()
                                .fill(Color.clear)
                                .frame(width: 12, height: 12)
                        }
                    }
                }
            }
        }
        .frame(width: 44, height: 44)
    }
    
    // MARK: - Color Picker
    private var colorPicker: some View {
        VStack(spacing: 12) {
            // Eraser and color buttons
            HStack(spacing: 16) {
                // Eraser button (removes last color)
                Button(action: {
                    gameState.removeLastColor()
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(white: 0.2))
                            .frame(width: 44, height: 44)
                        Image(systemName: "pencil.slash")
                            .foregroundColor(.white)
                            .font(.system(size: 18))
                    }
                }
                
                // Color buttons
                ForEach(0..<gameState.numColors, id: \.self) { index in
                    Button(action: {
                        gameState.addColor(index)
                    }) {
                        Circle()
                            .fill(gameState.getColor(for: index))
                            .frame(width: 44, height: 44)
                    }
                }
            }
            
            // Current selection preview
            HStack(spacing: 12) {
                ForEach(0..<gameState.codeLen, id: \.self) { index in
                    if let colorIndex = gameState.currentGuess[index] {
                        Circle()
                            .fill(gameState.getColor(for: colorIndex))
                            .frame(width: 36, height: 36)
                    } else {
                        Circle()
                            .stroke(Color(white: 0.4), lineWidth: 2)
                            .frame(width: 36, height: 36)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(white: 0.4), lineWidth: 2)
            )
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    // MARK: - Game Over View
    private var gameOverView: some View {
        VStack(spacing: 16) {
            if gameState.isWon {
                Text("🎉 You Won!")
                    .foregroundColor(.green)
                    .font(.system(size: 24, weight: .bold))
                Text("Solved in \(gameState.guesses.count) guesses")
                    .foregroundColor(.gray)
            } else {
                Text("Game Over")
                    .foregroundColor(.red)
                    .font(.system(size: 24, weight: .bold))
                Text("The secret code is shown above")
                    .foregroundColor(.gray)
            }
            
            Button(action: {
                Task { await loadPuzzle() }
            }) {
                Text("New Game")
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .semibold))
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding(.bottom, 30)
    }
    
    // MARK: - Load Puzzle
    private func loadPuzzle() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedPuzzle = try await APIService.generateMastermind(
                codeLen: 4,
                numColors: 4,
                allowRepeats: true
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
    MastermindGameView()
}

