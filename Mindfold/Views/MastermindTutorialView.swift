//
//  MastermindTutorialView.swift
//  Mindfold
//
//  Created by Evan Haque on 1/15/26.
//

import SwiftUI

struct MastermindTutorialView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .medium))
                    }
                    Spacer()
                    Text("How to play")
                        .foregroundColor(.white)
                        .font(.system(size: 22, weight: .bold))
                    Spacer()
                    Image(systemName: "xmark")
                        .foregroundColor(.clear)
                        .font(.system(size: 20, weight: .medium))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        // Game description
                        Text("Crack the secret color code")
                            .foregroundColor(.gray)
                            .font(.system(size: 16))
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        // Rule 1: Making guesses
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Rule 1: Making Guesses")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                            Text("Select colors to make a guess about the secret code.")
                                .foregroundColor(.gray)
                                .font(.system(size: 15))
                            
                            guessExample()
                                .frame(maxWidth: .infinity)
                        }
                        
                        // Rule 2: White feedback
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Rule 2: White Dot - Correct Color & Position")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                            Text("A white dot means one color is correct and in the right spot.")
                                .foregroundColor(.gray)
                                .font(.system(size: 15))
                            
                            VStack(spacing: 12) {
                                feedbackExample(
                                    guess: [.red, .blue, .green, .yellow],
                                    secret: [.red, .yellow, .orange, .purple],
                                    whiteDots: 1,
                                    blackDots: 1
                                )
                                Text("Secret has Red in position 1, Yellow somewhere else")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 13))
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                        
                        // Rule 3: Black feedback
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Rule 3: Black Dot - Correct Color, Wrong Position")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                            Text("A black dot means one color is correct but in the wrong spot.")
                                .foregroundColor(.gray)
                                .font(.system(size: 15))
                        }
                        
                        // Rule 4: Deduce the code
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Rule 4: Strategy")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                            Text("Use the feedback from each guess to narrow down the possibilities. You have limited attempts!")
                                .foregroundColor(.gray)
                                .font(.system(size: 15))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
                
                Button(action: { dismiss() }) {
                    Text("Got it!")
                        .foregroundColor(.black)
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private func guessExample() -> some View {
        HStack(spacing: 8) {
            ForEach([Color.red, .blue, .green, .yellow], id: \.self) { color in
                RoundedRectangle(cornerRadius: 6)
                    .fill(color)
                    .frame(width: 40, height: 40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    )
            }
        }
    }
    
    private func feedbackExample(guess: [Color], secret: [Color], whiteDots: Int, blackDots: Int) -> some View {
        HStack(spacing: 12) {
            // Guess
            HStack(spacing: 8) {
                ForEach(0..<guess.count, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 6)
                        .fill(guess[i])
                        .frame(width: 35, height: 35)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        )
                }
            }
            
            // Feedback (white dots first for correct position, then black dots for correct color wrong position)
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    ForEach(0..<2, id: \.self) { i in
                        Circle()
                            .fill(i < whiteDots ? Color.white : (i < whiteDots + blackDots ? Color.black : Color.gray.opacity(0.3)))
                            .frame(width: 12, height: 12)
                            .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))
                    }
                }
                HStack(spacing: 4) {
                    ForEach(2..<4, id: \.self) { i in
                        Circle()
                            .fill(i < whiteDots ? Color.white : (i < whiteDots + blackDots ? Color.black : Color.gray.opacity(0.3)))
                            .frame(width: 12, height: 12)
                            .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))
                    }
                }
            }
        }
    }
}
