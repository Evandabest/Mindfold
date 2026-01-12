//
//  LITSTutorialView.swift
//  Mindfold
//
//  Created by Evan Haque on 1/9/26.
//

import SwiftUI

struct LITSTutorialView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Dark background
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Header
                HStack {
                    // Close button (X)
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .medium))
                    }
                    
                    Spacer()
                    
                    // Title
                    Text("How to play")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .bold, design: .serif))
                    
                    Spacer()
                    
                    // Balance the header
                    Image(systemName: "xmark")
                        .foregroundColor(.clear)
                        .font(.system(size: 20, weight: .medium))
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 30)
                
                // Tutorial content
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        // Rule 1: Filling the grid
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Fill the grid completely with shapes. Each empty region must contain exactly one shape.")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                            
                            // Visual example would go here
                            // Left: empty region, Right: filled with shapes
                            HStack(spacing: 20) {
                                // Empty region example
                                VStack(spacing: 4) {
                                    Text("Empty")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 12))
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                        .frame(width: 80, height: 80)
                                }
                                
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.white)
                                
                                // Filled example
                                VStack(spacing: 4) {
                                    Text("Filled")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 12))
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.green.opacity(0.5))
                                            .frame(width: 80, height: 80)
                                        Text("L")
                                            .foregroundColor(.white)
                                            .font(.system(size: 24, weight: .bold))
                                    }
                                }
                            }
                            .padding(.leading, 20)
                        }
                        
                        // Rule 2: Possible shapes
                        VStack(alignment: .leading, spacing: 12) {
                            Text("4 possible shapes: L, I, T, S.")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                            
                            // Shape examples
                            HStack(spacing: 16) {
                                ForEach(["L", "I", "T", "S"], id: \.self) { shape in
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(getShapeColor(shape).opacity(0.7))
                                            .frame(width: 50, height: 50)
                                        Text(shape)
                                            .foregroundColor(.white)
                                            .font(.system(size: 24, weight: .bold))
                                    }
                                }
                            }
                            .padding(.leading, 20)
                        }
                        
                        // Rule 3: No 2x2 filled squares
                        VStack(alignment: .leading, spacing: 12) {
                            Text("No 2x2 filled squares are allowed.")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                            
                            // Visual example
                            HStack(spacing: 20) {
                                // Invalid: 2x2 square
                                VStack(spacing: 4) {
                                    Text("Invalid")
                                        .foregroundColor(.red)
                                        .font(.system(size: 12))
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.red.opacity(0.3))
                                            .frame(width: 60, height: 60)
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.red, lineWidth: 2)
                                            .frame(width: 60, height: 60)
                                    }
                                }
                                
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.white)
                                
                                // Valid: no 2x2
                                VStack(spacing: 4) {
                                    Text("Valid")
                                        .foregroundColor(.green)
                                        .font(.system(size: 12))
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.green.opacity(0.3))
                                        .frame(width: 60, height: 60)
                                }
                            }
                            .padding(.leading, 20)
                        }
                        
                        // Rule 4: Same shapes cannot touch
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Same shapes cannot touch by edges.")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                            
                            // Visual example
                            HStack(spacing: 20) {
                                // Invalid: same shapes touching
                                VStack(spacing: 4) {
                                    Text("Invalid")
                                        .foregroundColor(.red)
                                        .font(.system(size: 12))
                                    HStack(spacing: 2) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(Color.green.opacity(0.7))
                                                .frame(width: 30, height: 30)
                                            Text("L")
                                                .foregroundColor(.white)
                                                .font(.system(size: 12, weight: .bold))
                                        }
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(Color.green.opacity(0.7))
                                                .frame(width: 30, height: 30)
                                            Text("L")
                                                .foregroundColor(.white)
                                                .font(.system(size: 12, weight: .bold))
                                        }
                                    }
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 2)
                                            .stroke(Color.red, lineWidth: 2)
                                            .frame(width: 62, height: 30)
                                    )
                                }
                                
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.white)
                                
                                // Valid: different shapes or separated
                                VStack(spacing: 4) {
                                    Text("Valid")
                                        .foregroundColor(.green)
                                        .font(.system(size: 12))
                                    HStack(spacing: 2) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(Color.green.opacity(0.7))
                                                .frame(width: 30, height: 30)
                                            Text("L")
                                                .foregroundColor(.white)
                                                .font(.system(size: 12, weight: .bold))
                                        }
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(Color.blue.opacity(0.7))
                                                .frame(width: 30, height: 30)
                                            Text("I")
                                                .foregroundColor(.white)
                                                .font(.system(size: 12, weight: .bold))
                                        }
                                    }
                                }
                            }
                            .padding(.leading, 20)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                
                Spacer()
                
                // Play tutorial button
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Text("Play tutorial")
                            .foregroundColor(.black)
                            .font(.system(size: 18, weight: .semibold))
                        Image(systemName: "play.fill")
                            .foregroundColor(.black)
                            .font(.system(size: 14))
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
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private func getShapeColor(_ shape: String) -> Color {
        switch shape {
        case "L":
            return Color.orange
        case "I":
            return Color.blue
        case "T":
            return Color.green
        case "S":
            return Color.purple
        default:
            return Color.gray
        }
    }
}

#Preview {
    LITSTutorialView()
}

