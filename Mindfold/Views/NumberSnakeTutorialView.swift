//
//  NumberSnakeTutorialView.swift
//  Mindfold
//
//  Created by Evan Haque on 1/15/26.
//

import SwiftUI

struct NumberSnakeTutorialView: View {
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
                        Text("Draw a snake through numbered cells")
                            .foregroundColor(.gray)
                            .font(.system(size: 16))
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        // Rule 1: Start at 1
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Rule 1: Start at 1")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                            Text("Begin your path at the cell marked '1'.")
                                .foregroundColor(.gray)
                                .font(.system(size: 15))
                            
                            snakeGrid(
                                numbers: [(0, 0, "1")],
                                path: [(0, 0)],
                                size: 3
                            )
                            .frame(maxWidth: .infinity)
                        }
                        
                        // Rule 2: Hit all numbers
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Rule 2: Hit All Numbers in Order")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                            Text("Your path must visit numbers in sequential order (1 → 2 → 3 → ...).")
                                .foregroundColor(.gray)
                                .font(.system(size: 15))
                            
                            HStack(spacing: 30) {
                                VStack(spacing: 8) {
                                    snakeGrid(
                                        numbers: [(0, 0, "1"), (1, 1, "2"), (2, 2, "3")],
                                        path: [(0, 0), (0, 1), (1, 1), (1, 2), (2, 2)],
                                        size: 3
                                    )
                                    Text("✓ Visits 1→2→3")
                                        .foregroundColor(.green)
                                        .font(.system(size: 13))
                                }
                                
                                VStack(spacing: 8) {
                                    snakeGrid(
                                        numbers: [(0, 0, "1"), (1, 1, "2"), (2, 2, "3")],
                                        path: [(0, 0), (1, 0), (2, 0), (2, 1), (2, 2)],
                                        size: 3,
                                        highlightError: true
                                    )
                                    Text("✗ Skipped 2, went 1→3")
                                        .foregroundColor(.red)
                                        .font(.system(size: 13))
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        // Rule 3: Fill all cells
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Rule 3: Fill All Cells")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                            Text("The path must visit every cell exactly once, ending at the highest number.")
                                .foregroundColor(.gray)
                                .font(.system(size: 15))
                            
                            HStack(spacing: 30) {
                                VStack(spacing: 8) {
                                    snakeGrid(
                                        numbers: [(0, 0, "1"), (2, 2, "4")],
                                        path: [(0, 0), (0, 1), (0, 2), (1, 2), (2, 2)],
                                        size: 3,
                                        showIncomplete: true
                                    )
                                    Text("✗ Not filled")
                                        .foregroundColor(.red)
                                        .font(.system(size: 13))
                                }
                                
                                VStack(spacing: 8) {
                                    snakeGrid(
                                        numbers: [(0, 0, "1"), (2, 2, "9")],
                                        path: [(0, 0), (0, 1), (0, 2), (1, 2), (1, 1), (1, 0), (2, 0), (2, 1), (2, 2)],
                                        size: 3
                                    )
                                    Text("✓ Complete")
                                        .foregroundColor(.green)
                                        .font(.system(size: 13))
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        // Rule 4: Adjacent only
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Rule 4: Adjacent Cells Only")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                            Text("Move up, down, left, or right. Diagonal moves are not allowed.")
                                .foregroundColor(.gray)
                                .font(.system(size: 15))
                            
                            HStack(spacing: 30) {
                                VStack(spacing: 8) {
                                    diagonalExample(valid: true)
                                    Text("✓ Adjacent moves")
                                        .foregroundColor(.green)
                                        .font(.system(size: 13))
                                }
                                
                                VStack(spacing: 8) {
                                    diagonalExample(valid: false)
                                    Text("✗ Diagonal not allowed")
                                        .foregroundColor(.red)
                                        .font(.system(size: 13))
                                }
                            }
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
    
    private func snakeGrid(numbers: [(Int, Int, String)], path: [(Int, Int)], size: Int, showIncomplete: Bool = false, highlightError: Bool = false) -> some View {
        let cellSize: CGFloat = 35
        return VStack(spacing: 1) {
            ForEach(0..<size, id: \.self) { row in
                HStack(spacing: 1) {
                    ForEach(0..<size, id: \.self) { col in
                        let pathIndex = path.firstIndex(where: { $0.0 == row && $0.1 == col })
                        let number = numbers.first(where: { $0.0 == row && $0.1 == col })?.2
                        let isEmpty = showIncomplete && pathIndex == nil
                        let isErrorCell = highlightError && number == "2"
                        
                        ZStack {
                            Rectangle()
                                .fill(cellColor(for: pathIndex, totalSteps: path.count, isEmpty: isEmpty))
                                .frame(width: cellSize, height: cellSize)
                            Rectangle()
                                .stroke(isErrorCell ? Color.red : Color.white.opacity(0.5), lineWidth: isErrorCell ? 3 : 1)
                                .frame(width: cellSize, height: cellSize)
                            if let num = number {
                                Text(num)
                                    .foregroundColor(.white)
                                    .font(.system(size: 14, weight: .bold))
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func cellColor(for pathIndex: Int?, totalSteps: Int, isEmpty: Bool) -> Color {
        if isEmpty {
            return Color.gray.opacity(0.2)
        }
        
        guard let index = pathIndex, totalSteps > 1 else {
            if pathIndex != nil {
                return Color(red: 1.0, green: 0.3, blue: 0.5) // Vibrant pink for single cell
            }
            return Color.gray.opacity(0.3)
        }
        
        // Create gradient from vibrant pink → red → orange → yellow → green
        let progress = Double(index) / Double(totalSteps - 1)
        
        if progress < 0.25 {
            // Pink to Red
            let localProgress = progress / 0.25
            return Color(
                red: 1.0,
                green: 0.3 - (0.1 * localProgress),
                blue: 0.5 - (0.5 * localProgress)
            )
        } else if progress < 0.5 {
            // Red to Orange
            let localProgress = (progress - 0.25) / 0.25
            return Color(
                red: 1.0,
                green: 0.2 + (0.4 * localProgress),
                blue: 0.0
            )
        } else if progress < 0.75 {
            // Orange to Yellow
            let localProgress = (progress - 0.5) / 0.25
            return Color(
                red: 1.0,
                green: 0.6 + (0.3 * localProgress),
                blue: 0.0 + (0.2 * localProgress)
            )
        } else {
            // Yellow to Green
            let localProgress = (progress - 0.75) / 0.25
            return Color(
                red: 1.0 - (0.4 * localProgress),
                green: 0.9,
                blue: 0.2 + (0.3 * localProgress)
            )
        }
    }
    
    private func diagonalExample(valid: Bool) -> some View {
        let cellSize: CGFloat = 35
        return VStack(spacing: 1) {
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: 1) {
                    ForEach(0..<3, id: \.self) { col in
                        let isPath = valid ? 
                            (row == 0 && col == 0) || (row == 0 && col == 1) || (row == 1 && col == 1) : // Valid: right then down
                            (row == 0 && col == 0) || (row == 1 && col == 1) // Invalid: diagonal
                        let isStart = row == 0 && col == 0
                        let isEnd = valid ? (row == 1 && col == 1) : (row == 1 && col == 1)
                        let isDiagonal = !valid && row == 1 && col == 1
                        
                        ZStack {
                            Rectangle()
                                .fill(isPath ? Color.blue.opacity(0.6) : Color.gray.opacity(0.3))
                                .frame(width: cellSize, height: cellSize)
                            Rectangle()
                                .stroke(isDiagonal ? Color.red : Color.white.opacity(0.5), lineWidth: isDiagonal ? 3 : 1)
                                .frame(width: cellSize, height: cellSize)
                            if isStart {
                                Text("1")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14, weight: .bold))
                            } else if isEnd {
                                Text("2")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14, weight: .bold))
                            }
                            if isDiagonal {
                                Text("✗")
                                    .foregroundColor(.red)
                                    .font(.system(size: 16, weight: .bold))
                                    .offset(x: 15, y: -15)
                            }
                        }
                    }
                }
            }
        }
    }
}
