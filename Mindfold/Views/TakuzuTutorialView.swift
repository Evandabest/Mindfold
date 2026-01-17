//
//  TakuzuTutorialView.swift
//  Mindfold
//
//  Created by Evan Haque on 1/9/26.
//

import SwiftUI

struct TakuzuTutorialView: View {
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
                        Text("Fill grid with equal black and white cells")
                            .foregroundColor(.gray)
                            .font(.system(size: 16))
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        // Rule 1: Equal numbers
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Rule 1: Equal Numbers")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                            Text("Each row and column must have equal black and white circles.")
                                .foregroundColor(.gray)
                                .font(.system(size: 15))
                            
                            HStack(spacing: 30) {
                                VStack(spacing: 8) {
                                    takuzuRow(pattern: [true, false, true, false], isValid: true)
                                    Text("✓ 2 black, 2 white")
                                        .foregroundColor(.green)
                                        .font(.system(size: 13))
                                }
                                
                                VStack(spacing: 8) {
                                    takuzuRow(pattern: [true, true, true, false], isValid: false)
                                    Text("✗ 3 black, 1 white")
                                        .foregroundColor(.red)
                                        .font(.system(size: 13))
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        // Rule 2: No three in a row
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Rule 2: No Three in a Row")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                            Text("No more than two of the same color can be adjacent.")
                                .foregroundColor(.gray)
                                .font(.system(size: 15))
                            
                            HStack(spacing: 30) {
                                VStack(spacing: 8) {
                                    takuzuRow(pattern: [true, true, false, false], isValid: true)
                                    Text("✓ Max two adjacent")
                                        .foregroundColor(.green)
                                        .font(.system(size: 13))
                                }
                                
                                VStack(spacing: 8) {
                                    takuzuRow(pattern: [true, true, true, false], isValid: false)
                                    Text("✗ Three in a row")
                                        .foregroundColor(.red)
                                        .font(.system(size: 13))
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        // Rule 3: Unique rows
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Rule 3: All Rows & Columns Unique")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                            Text("No two rows can be identical, and no two columns can be identical.")
                                .foregroundColor(.gray)
                                .font(.system(size: 15))
                            
                            HStack(spacing: 30) {
                                VStack(spacing: 8) {
                                    VStack(spacing: 1) {
                                        takuzuRow(pattern: [true, false, true, false], isValid: true, compact: true)
                                        takuzuRow(pattern: [false, true, false, true], isValid: true, compact: true)
                                    }
                                    Text("✓ Different")
                                        .foregroundColor(.green)
                                        .font(.system(size: 13))
                                }
                                
                                VStack(spacing: 8) {
                                    VStack(spacing: 1) {
                                        takuzuRow(pattern: [true, false, true, false], isValid: false, compact: true)
                                        takuzuRow(pattern: [true, false, true, false], isValid: false, compact: true)
                                    }
                                    Text("✗ Identical")
                                        .foregroundColor(.red)
                                        .font(.system(size: 13))
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        // Example puzzle
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Example")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                            Text("Gray circles can be filled with either color.")
                                .foregroundColor(.gray)
                                .font(.system(size: 15))
                            
                            takuzuExample()
                                .frame(maxWidth: .infinity)
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
    
    private func takuzuRow(pattern: [Bool], isValid: Bool, compact: Bool = false) -> some View {
        HStack(spacing: compact ? 1 : 2) {
            ForEach(0..<pattern.count, id: \.self) { i in
                Circle()
                    .fill(pattern[i] ? Color.black : Color.white)
                    .frame(width: compact ? 25 : 35, height: compact ? 25 : 35)
                    .overlay(
                        Circle()
                            .stroke(isValid ? Color.gray : Color.red, lineWidth: 2)
                    )
            }
        }
    }
    
    private func takuzuExample() -> some View {
        VStack(spacing: 2) {
            ForEach(0..<4, id: \.self) { row in
                HStack(spacing: 2) {
                    ForEach(0..<4, id: \.self) { col in
                        let value = exampleValue(row: row, col: col)
                        Circle()
                            .fill(value == 0 ? Color.white : value == 1 ? Color.black : Color.gray.opacity(0.3))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Circle()
                                    .stroke(Color.gray, lineWidth: 2)
                            )
                    }
                }
            }
        }
    }
    
    private func exampleValue(row: Int, col: Int) -> Int {
        // 0 = white, 1 = black, -1 = empty
        let grid = [
            [1, -1, 0, -1],
            [-1, 0, -1, 1],
            [0, -1, 1, -1],
            [-1, 1, -1, 0]
        ]
        return grid[row][col]
    }
}
