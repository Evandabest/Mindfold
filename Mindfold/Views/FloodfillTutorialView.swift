//
//  FloodfillTutorialView.swift
//  Mindfold
//
//  Created by Evan Haque on 1/15/26.
//

import SwiftUI

struct FloodfillTutorialView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Dark background
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
                        .font(.system(size: 24, weight: .bold))
                    
                    Spacer()
                    
                    // Invisible spacer for balance
                    Image(systemName: "xmark")
                        .foregroundColor(.clear)
                        .font(.system(size: 20, weight: .medium))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Goal
                        VStack(alignment: .leading, spacing: 12) {
                            bulletPoint("Your goal is to paint whole area into one color.")
                            
                            // Visual example
                            exampleView
                        }
                        
                        // Moves
                        bulletPoint("You have limited amount of moves.")
                        
                        // Move counter example
                        Text("4 moves")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium))
                            .padding(.vertical, 6)
                            .padding(.horizontal, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .padding(.leading, 24)
                        
                        // Instructions
                        bulletPoint("To select paint color use paint bar on bottom of the screen. To apply paint just click on area you would like to change color")
                        
                        // Color picker example
                        HStack(spacing: 12) {
                            ForEach([Color.blue, Color.green, Color.purple, Color.gray], id: \.self) { color in
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(color)
                                    .frame(width: 50, height: 50)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .padding(.leading, 24)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
                
                Spacer()
                
                // Play tutorial button
                Button(action: { dismiss() }) {
                    HStack {
                        Text("Play tutorial")
                            .foregroundColor(.black)
                            .font(.system(size: 18, weight: .semibold))
                        Image(systemName: "play.fill")
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
    }
    
    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundColor(.white)
                .font(.system(size: 16))
            Text(text)
                .foregroundColor(.white)
                .font(.system(size: 16))
        }
    }
    
    private var exampleView: some View {
        HStack(spacing: 16) {
            // Initial state (2x2 grid with mixed colors)
            VStack(spacing: 2) {
                HStack(spacing: 2) {
                    Rectangle().fill(Color.green).frame(width: 30, height: 30)
                    Rectangle().fill(Color.red).frame(width: 30, height: 30)
                }
                HStack(spacing: 2) {
                    Rectangle().fill(Color.blue).frame(width: 30, height: 30)
                    Rectangle().fill(Color.blue).frame(width: 30, height: 30)
                }
            }
            
            // Arrow
            Image(systemName: "arrow.right")
                .foregroundColor(.white)
                .font(.system(size: 24))
            
            // Intermediate state (3 blues, 1 red)
            VStack(spacing: 2) {
                HStack(spacing: 2) {
                    Rectangle().fill(Color.blue).frame(width: 30, height: 30)
                    Rectangle().fill(Color.red).frame(width: 30, height: 30)
                }
                HStack(spacing: 2) {
                    Rectangle().fill(Color.blue).frame(width: 30, height: 30)
                    Rectangle().fill(Color.blue).frame(width: 30, height: 30)
                }
            }
            
            // Arrow
            Image(systemName: "arrow.right")
                .foregroundColor(.white)
                .font(.system(size: 24))
            
            // Final state (all blue)
            VStack(spacing: 2) {
                HStack(spacing: 2) {
                    Rectangle().fill(Color.blue).frame(width: 30, height: 30)
                    Rectangle().fill(Color.blue).frame(width: 30, height: 30)
                }
                HStack(spacing: 2) {
                    Rectangle().fill(Color.blue).frame(width: 30, height: 30)
                    Rectangle().fill(Color.blue).frame(width: 30, height: 30)
                }
            }
        }
        .padding(.leading, 24)
    }
}

#Preview {
    FloodfillTutorialView()
}

