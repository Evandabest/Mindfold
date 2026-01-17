//
//  MastermindGameState.swift
//  Mindfold
//
//  Created by Evan Haque on 1/15/26.
//

import SwiftUI

// Feedback for a single guess
struct GuessFeedback: Equatable {
    let exactMatches: Int     // Correct color AND position (filled dot)
    let colorMatches: Int     // Correct color, wrong position (empty dot)
}

// A single guess row
struct GuessRow: Identifiable, Equatable {
    let id = UUID()
    let colors: [Int]         // Color indices for this guess
    let feedback: GuessFeedback
}

class MastermindGameState: ObservableObject {
    // Game configuration (mutable for updates)
    var codeLen: Int
    var numColors: Int
    var allowRepeats: Bool
    var maxGuesses: Int
    
    // Secret code to guess
    private var secretCode: [Int]
    
    // Game state
    @Published var guesses: [GuessRow] = []
    @Published var currentGuess: [Int?]  // Current row being built (nil = empty slot)
    @Published var selectedColorIndex: Int = 0  // Currently selected color to place
    @Published var isComplete: Bool = false
    @Published var isWon: Bool = false
    
    // Available colors (mapped to SwiftUI colors in view)
    static let colorPalette: [Color] = [
        Color(red: 0.4, green: 0.8, blue: 0.4),   // Green
        Color(red: 0.9, green: 0.4, blue: 0.4),   // Red
        Color(red: 0.4, green: 0.6, blue: 0.95),  // Blue
        Color(white: 0.6),                         // Gray
        Color(red: 1.0, green: 0.8, blue: 0.2),   // Yellow
        Color(red: 0.9, green: 0.5, blue: 0.2),   // Orange
        Color(red: 0.7, green: 0.4, blue: 0.9),   // Purple
        Color(red: 0.3, green: 0.8, blue: 0.8),   // Cyan
    ]
    
    init(puzzle: MastermindPuzzle) {
        self.codeLen = puzzle.codeLen
        self.numColors = puzzle.numColors
        self.allowRepeats = puzzle.allowRepeats
        self.maxGuesses = puzzle.maxAttempts
        self.secretCode = puzzle.code
        self.currentGuess = Array(repeating: nil, count: puzzle.codeLen)
    }
    
    // For preview/testing
    init(codeLen: Int = 4, numColors: Int = 4, maxGuesses: Int = 10, secretCode: [Int]? = nil) {
        self.codeLen = codeLen
        self.numColors = numColors
        self.allowRepeats = true
        self.maxGuesses = maxGuesses
        self.secretCode = secretCode ?? Array(0..<codeLen)
        self.currentGuess = Array(repeating: nil, count: codeLen)
    }
    
    // Update the game with a new puzzle (for reloading)
    func update(with puzzle: MastermindPuzzle) {
        self.codeLen = puzzle.codeLen
        self.numColors = puzzle.numColors
        self.allowRepeats = puzzle.allowRepeats
        self.maxGuesses = puzzle.maxAttempts
        self.secretCode = puzzle.code
        self.guesses = []
        self.currentGuess = Array(repeating: nil, count: puzzle.codeLen)
        self.selectedColorIndex = 0
        self.isComplete = false
        self.isWon = false
        objectWillChange.send()
    }
    
    // Get color for a color index
    func getColor(for index: Int) -> Color {
        guard index >= 0 && index < Self.colorPalette.count else {
            return .gray
        }
        return Self.colorPalette[index]
    }
    
    // Add a color to the next available slot
    func addColor(_ colorIndex: Int) {
        guard !isComplete else { return }
        
        // Find the first empty slot
        for i in 0..<codeLen {
            if currentGuess[i] == nil {
                currentGuess[i] = colorIndex
                objectWillChange.send()
                return
            }
        }
    }
    
    // Remove the last color (from the rightmost filled slot)
    func removeLastColor() {
        guard !isComplete else { return }
        
        // Find the last filled slot
        for i in (0..<codeLen).reversed() {
            if currentGuess[i] != nil {
                currentGuess[i] = nil
                objectWillChange.send()
                return
            }
        }
    }
    
    // Check if current guess is complete (all slots filled)
    var isCurrentGuessComplete: Bool {
        return currentGuess.allSatisfy { $0 != nil }
    }
    
    // Submit the current guess
    func submitGuess() {
        guard isCurrentGuessComplete else { return }
        guard !isComplete else { return }
        guard guesses.count < maxGuesses else { return }
        
        let guessColors = currentGuess.compactMap { $0 }
        let feedback = calculateFeedback(for: guessColors)
        
        let newGuess = GuessRow(colors: guessColors, feedback: feedback)
        guesses.append(newGuess)
        
        // Check for win
        if feedback.exactMatches == codeLen {
            isComplete = true
            isWon = true
        } else if guesses.count >= maxGuesses {
            // Out of guesses
            isComplete = true
            isWon = false
        }
        
        // Reset current guess for next row
        currentGuess = Array(repeating: nil, count: codeLen)
        objectWillChange.send()
    }
    
    // Calculate feedback for a guess (matches the Python implementation)
    private func calculateFeedback(for guess: [Int]) -> GuessFeedback {
        // Exact matches (black pegs) - correct color and position
        var exactMatches = 0
        var secretRemaining: [Int] = []
        var guessRemaining: [Int] = []
        
        // First pass: find exact matches
        for i in 0..<codeLen {
            if guess[i] == secretCode[i] {
                exactMatches += 1
            } else {
                secretRemaining.append(secretCode[i])
                guessRemaining.append(guess[i])
            }
        }
        
        // Color-only matches (white pegs) - multiset intersection of remaining colors
        // Count occurrences of each color in remaining colors
        var secretCount = Array(repeating: 0, count: numColors)
        var guessCount = Array(repeating: 0, count: numColors)
        
        for color in secretRemaining {
            secretCount[color] += 1
        }
        
        for color in guessRemaining {
            guessCount[color] += 1
        }
        
        // Color matches = sum of minimum counts for each color
        var colorMatches = 0
        for i in 0..<numColors {
            colorMatches += min(secretCount[i], guessCount[i])
        }
        
        print("Evaluation: guess=\(guess), secret=\(secretCode)")
        print("  Exact matches (black): \(exactMatches)")
        print("  Color matches (white): \(colorMatches)")
        
        return GuessFeedback(exactMatches: exactMatches, colorMatches: colorMatches)
    }
    
    // Reset the game with the same secret
    func reset() {
        guesses = []
        currentGuess = Array(repeating: nil, count: codeLen)
        selectedColorIndex = 0
        isComplete = false
        isWon = false
        objectWillChange.send()
    }
    
    // Get remaining guesses
    var remainingGuesses: Int {
        return maxGuesses - guesses.count
    }
    
    // Get the secret code (for showing after game ends)
    func getSecretCode() -> [Int] {
        return secretCode
    }
}
