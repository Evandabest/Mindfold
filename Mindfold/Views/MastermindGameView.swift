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
                        // Empty/current guess rows at the top
                        let emptyRows = max(0, gameState.maxGuesses - gameState.guesses.count)
                        ForEach(0..<emptyRows, id: \.self) { index in
                            if index == emptyRows - 1 && !gameState.isComplete {
                                // Last empty row (lowest) gets the current guess row with arrow
                                currentGuessRow
                                    .id("current")
                            } else {
                                emptyGuessRow(showArrow: false)
                            }
                        }
                        
                        // Previous guesses (in reverse order, most recent at bottom)
                        ForEach(Array(gameState.guesses.enumerated().reversed()), id: \.element.id) { index, guess in
                            guessRow(guess: guess, rowIndex: index)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .onAppear {
                    // Scroll to bottom on initial load
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        proxy.scrollTo("current", anchor: .bottom)
                    }
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
        HStack(spacing: 0) {
            Spacer()
            
            HStack(spacing: 0) {
                HStack(spacing: 8) {
                    ForEach(0..<gameState.codeLen, id: \.self) { index in
                        if gameState.isComplete {
                            // Show the secret code
                            RoundedRectangle(cornerRadius: 6)
                                .fill(gameState.getColor(for: gameState.getSecretCode()[index]))
                                .frame(width: 36, height: 36)
                        } else {
                            // Show question marks
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(white: 0.3))
                                    .frame(width: 36, height: 36)
                                Text("?")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .bold))
                            }
                        }
                    }
                }
                
                Spacer()
                    .frame(width: 56)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(white: 0.5), lineWidth: 2)
            )
            
            Spacer()
        }
    }
    
    // MARK: - Guess Rows
    private func guessRow(guess: GuessRow, rowIndex: Int) -> some View {
        HStack(spacing: 0) {
            Spacer()
            
            // Row content
            HStack(spacing: 0) {
                // Color squares
                HStack(spacing: 8) {
                    ForEach(0..<gameState.codeLen, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 6)
                            .fill(gameState.getColor(for: guess.colors[index]))
                            .frame(width: 36, height: 36)
                    }
                }
                
                // Feedback squares
                feedbackView(feedback: guess.feedback)
                    .padding(.leading, 12)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
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
            
            Spacer()
        }
    }
    
    private var currentGuessRow: some View {
        HStack(spacing: 0) {
            Spacer()
            
            // Arrow indicator for current active row
            Image(systemName: "arrowtriangle.right.fill")
                .foregroundColor(.yellow)
                .font(.system(size: 12))
                .frame(width: 20)
            
            // Row content
            HStack(spacing: 0) {
                // Color squares (not tappable, filled automatically)
                HStack(spacing: 8) {
                    ForEach(0..<gameState.codeLen, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 6)
                            .fill(colorForCurrentGuess(at: index))
                            .frame(width: 36, height: 36)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
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
                            .font(.system(size: 18))
                            .frame(width: 36, height: 36)
                            .background(Color(white: 0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .padding(.leading, 12)
                } else {
                    // Placeholder for alignment
                    Spacer()
                        .frame(width: 56)
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .overlay(
                Rectangle()
                    .fill(Color(white: 0.4))
                    .frame(height: 1),
                alignment: .bottom
            )
            
            Spacer()
        }
    }
    
    private func colorForCurrentGuess(at index: Int) -> Color {
        if let colorIndex = gameState.currentGuess[index] {
            return gameState.getColor(for: colorIndex)
        } else {
            return Color(white: 0.3)
        }
    }
    
    private func emptyGuessRow(showArrow: Bool) -> some View {
        HStack(spacing: 0) {
            Spacer()
            
            HStack(spacing: 0) {
                HStack(spacing: 8) {
                    ForEach(0..<gameState.codeLen, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(white: 0.25))
                            .frame(width: 36, height: 36)
                    }
                }
                
                Spacer()
                    .frame(width: 56)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .overlay(
                Rectangle()
                    .fill(Color(white: 0.4))
                    .frame(height: 1),
                alignment: .bottom
            )
            
            Spacer()
        }
    }
    
    // MARK: - Feedback View
    private func feedbackView(feedback: GuessFeedback) -> some View {
        let totalFeedback = feedback.exactMatches + feedback.colorMatches
        let columns = 2
        
        return VStack(spacing: 3) {
            ForEach(0..<2, id: \.self) { row in
                HStack(spacing: 3) {
                    ForEach(0..<columns, id: \.self) { col in
                        let index = row * columns + col
                        if index < feedback.exactMatches {
                            // Filled square - exact match
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white)
                                .frame(width: 10, height: 10)
                        } else if index < totalFeedback {
                            // Empty square - color match
                            RoundedRectangle(cornerRadius: 2)
                                .stroke(Color.white, lineWidth: 1.5)
                                .frame(width: 10, height: 10)
                        } else if index < gameState.codeLen {
                            // No match
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.clear)
                                .frame(width: 10, height: 10)
                        }
                    }
                }
            }
        }
        .frame(width: 32, height: 32)
    }
    
    // MARK: - Color Picker
    private var colorPicker: some View {
        VStack(spacing: 10) {
            // Eraser and color buttons
            HStack(spacing: 12) {
                // Eraser button (removes last color)
                Button(action: {
                    gameState.removeLastColor()
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(white: 0.2))
                            .frame(width: 40, height: 40)
                        Image(systemName: "arrow.uturn.backward")
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                    }
                }
                
                // Color buttons
                ForEach(0..<gameState.numColors, id: \.self) { index in
                    Button(action: {
                        gameState.addColor(index)
                    }) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(gameState.getColor(for: index))
                            .frame(width: 40, height: 40)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
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
                allowRepeats: true,
                avoidTrivial: true,
                maxAttempts: 10,
                enforceSolvableWithinAttempts: true
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

