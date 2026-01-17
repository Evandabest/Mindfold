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
                    
                    Text("How to play Mastermind")
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
                        // Rules
                        VStack(alignment: .leading, spacing: 16) {
                            bulletPoint("Find a secret 4-color sequence.")
                            bulletPoint("Secret colors can repeat.")
                            bulletPoint("Each guess - place 4 balls and receive feedback:")
                            
                            // Feedback explanation
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 20, height: 20)
                                    Text("correct color and position.")
                                        .foregroundColor(.white)
                                }
                                
                                HStack(spacing: 12) {
                                    Circle()
                                        .stroke(Color.white, lineWidth: 2)
                                        .frame(width: 20, height: 20)
                                    Text("correct color, wrong position.")
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.leading, 24)
                            
                            bulletPoint("Feedback dots don't show which specific balls they refer to.")
                            
                            // Example
                            exampleView
                            
                            bulletPoint("Use deduction and logic to find the correct sequence!")
                        }
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
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                // Example balls
                HStack(spacing: 8) {
                    ForEach(0..<4, id: \.self) { index in
                        Circle()
                            .fill(Color(white: 0.4))
                            .frame(width: 36, height: 36)
                    }
                }
                
                // Feedback example (2 exact, 2 color)
                VStack(spacing: 3) {
                    HStack(spacing: 3) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 10, height: 10)
                        Circle()
                            .fill(Color.white)
                            .frame(width: 10, height: 10)
                    }
                    HStack(spacing: 3) {
                        Circle()
                            .stroke(Color.white, lineWidth: 1.5)
                            .frame(width: 10, height: 10)
                        Circle()
                            .stroke(Color.white, lineWidth: 1.5)
                            .frame(width: 10, height: 10)
                    }
                }
            }
            
            Text("Two balls are in the correct positions, and two have the correct color but wrong positions.")
                .foregroundColor(.white)
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
        .padding(.leading, 24)
    }
}

#Preview {
    MastermindTutorialView()
}

