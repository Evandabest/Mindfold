//
//  ShikakuTutorialView.swift
//  Mindfold
//
//  Created by Evan Haque on 1/9/26.
//

import SwiftUI

struct ShikakuTutorialView: View {
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
                        Text("Fill the grid with rectangles")
                            .foregroundColor(.gray)
                            .font(.system(size: 16))
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        // Rule 1: Basic rectangle
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Rule 1: Rectangle Size")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                            Text("A number tells you how many cells the rectangle must cover.")
                                .foregroundColor(.gray)
                                .font(.system(size: 15))
                            
                            HStack(spacing: 40) {
                                // Example: 4-cell rectangle
                                VStack(spacing: 8) {
                                    gridExample(rows: 2, cols: 2, number: "4", color: .green)
                                    Text("✓ Correct")
                                        .foregroundColor(.green)
                                        .font(.system(size: 14, weight: .medium))
                                    Text("2×2 = 4 cells")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 12))
                                }
                                
                                // Example: Wrong size
                                VStack(spacing: 8) {
                                    gridExample(rows: 2, cols: 3, number: "4", color: .red)
                                    Text("✗ Wrong")
                                        .foregroundColor(.red)
                                        .font(.system(size: 14, weight: .medium))
                                    Text("2×3 = 6 cells")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 12))
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        // Rule 2: Any dimensions
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Rule 2: Any Dimensions")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                            Text("Rectangles can be any shape as long as they have the right area.")
                                .foregroundColor(.gray)
                                .font(.system(size: 15))
                            
                            HStack(spacing: 20) {
                                VStack(spacing: 8) {
                                    gridExample(rows: 2, cols: 3, number: "6", color: .green)
                                    Text("2×3")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 12))
                                }
                                VStack(spacing: 8) {
                                    gridExample(rows: 1, cols: 6, number: "6", color: .green)
                                    Text("1×6")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 12))
                                }
                                VStack(spacing: 8) {
                                    gridExample(rows: 3, cols: 2, number: "6", color: .green)
                                    Text("3×2")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 12))
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        // Rule 3: No overlap or gaps
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Rule 3: Fill Completely")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                            Text("Rectangles cannot overlap, and there can be no empty cells.")
                                .foregroundColor(.gray)
                                .font(.system(size: 15))
                        }
                        
                        // Complete example
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Complete Example")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                            
                            completeExample()
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
                
                // Close button at bottom
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
    
    // Helper to create a grid example
    private func gridExample(rows: Int, cols: Int, number: String, color: Color) -> some View {
        VStack(spacing: 1) {
            ForEach(0..<rows, id: \.self) { r in
                HStack(spacing: 1) {
                    ForEach(0..<cols, id: \.self) { c in
                        ZStack {
                            Rectangle()
                                .fill(color.opacity(0.3))
                                .frame(width: 30, height: 30)
                            Rectangle()
                                .stroke(Color.black, lineWidth: 2)
                                .frame(width: 30, height: 30)
                            if r == rows/2 && c == cols/2 {
                                Text(number)
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .bold))
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Complete solved example
    private func completeExample() -> some View {
        VStack(spacing: 1) {
            // Row 1
            HStack(spacing: 1) {
                rect(color: .red, text: "5", width: 60, height: 30)
                rect(color: .blue, text: "6", width: 90, height: 30)
            }
            // Row 2
            HStack(spacing: 1) {
                rect(color: .red, text: nil, width: 60, height: 30)
                rect(color: .blue, text: nil, width: 90, height: 30)
            }
            // Row 3
            HStack(spacing: 1) {
                rect(color: .orange, text: "7", width: 150, height: 30)
            }
        }
    }
    
    private func rect(color: Color, text: String?, width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            Rectangle()
                .fill(color.opacity(0.4))
                .frame(width: width, height: height)
            Rectangle()
                .stroke(Color.black, lineWidth: 2)
                .frame(width: width, height: height)
            if let text = text {
                Text(text)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .bold))
            }
        }
    }
}
