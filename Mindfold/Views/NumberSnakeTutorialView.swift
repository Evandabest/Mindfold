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
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Title
                    Text("How to play")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 8)
                    
                    // Rule 1: Connect all numbers
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 4) {
                            Text("•")
                                .foregroundColor(.white)
                            Text("Draw a line to connect all the numbers.")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                        }
                    }
                    .padding(.horizontal)
                    
                    // Rule 2: Connect in sequence
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 4) {
                            Text("•")
                                .foregroundColor(.white)
                            Text("Connect the numbers in the correct sequence (1 → 2 → 3 → ...).")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                        }
                        
                        // Example diagrams
                        HStack(spacing: 40) {
                            VStack(spacing: 8) {
                                exampleGrid(correct: false)
                                Text("Incorrect")
                                    .foregroundColor(.red)
                                    .font(.system(size: 14))
                            }
                            
                            VStack(spacing: 8) {
                                exampleGrid(correct: true)
                                Text("Correct")
                                    .foregroundColor(.green)
                                    .font(.system(size: 14))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                    }
                    .padding(.horizontal)
                    
                    // Rule 3: Must pass through every cell
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 4) {
                            Text("•")
                                .foregroundColor(.white)
                            Text("Your line must pass through every cell on the board.")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                        }
                        
                        // Example diagrams
                        HStack(spacing: 40) {
                            VStack(spacing: 8) {
                                incompletePath()
                                Text("Incorrect")
                                    .foregroundColor(.red)
                                    .font(.system(size: 14))
                            }
                            
                            VStack(spacing: 8) {
                                completePath()
                                Text("Correct")
                                    .foregroundColor(.green)
                                    .font(.system(size: 14))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 30)
                }
            }
        }
    }
    
    // MARK: - Example Views
    
    @ViewBuilder
    private func exampleGrid(correct: Bool) -> some View {
        let gridSize: CGFloat = 120
        let cellSize = gridSize / 3
        
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(white: 0.1))
                .frame(width: gridSize + 20, height: gridSize + 20)
            
            // Grid cells
            ForEach(0..<3, id: \.self) { row in
                ForEach(0..<3, id: \.self) { col in
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color(white: 0.3), lineWidth: 1)
                        .frame(width: cellSize - 2, height: cellSize - 2)
                        .position(
                            x: CGFloat(col) * cellSize + cellSize / 2,
                            y: CGFloat(row) * cellSize + cellSize / 2
                        )
                }
            }
            
            // Numbers
            if correct {
                // Correct order: 1 top-left, 2 bottom-left, 3 top-right
                numberCircle(1, x: 0, y: 0, cellSize: cellSize)
                numberCircle(2, x: 0, y: 2, cellSize: cellSize)
                numberCircle(3, x: 2, y: 0, cellSize: cellSize)
                
                // Path
                Path { path in
                    path.move(to: CGPoint(x: cellSize / 2, y: cellSize / 2))
                    path.addLine(to: CGPoint(x: cellSize / 2, y: 2.5 * cellSize))
                    path.addLine(to: CGPoint(x: 2.5 * cellSize, y: 2.5 * cellSize))
                    path.addLine(to: CGPoint(x: 2.5 * cellSize, y: cellSize / 2))
                }
                .stroke(Color.green, lineWidth: 4)
            } else {
                // Incorrect order: 1 top-left, 3 center, 2 bottom-right
                numberCircle(3, x: 1, y: 0, cellSize: cellSize)
                numberCircle(1, x: 0, y: 1, cellSize: cellSize)
                numberCircle(2, x: 2, y: 2, cellSize: cellSize)
                
                // Wrong path
                Path { path in
                    path.move(to: CGPoint(x: cellSize / 2, y: 1.5 * cellSize))
                    path.addLine(to: CGPoint(x: 1.5 * cellSize, y: cellSize / 2))
                    path.addLine(to: CGPoint(x: 2.5 * cellSize, y: 2.5 * cellSize))
                }
                .stroke(Color.red, lineWidth: 4)
            }
        }
        .frame(width: gridSize + 20, height: gridSize + 20)
    }
    
    @ViewBuilder
    private func numberCircle(_ value: Int, x: Int, y: Int, cellSize: CGFloat) -> some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: cellSize * 0.5, height: cellSize * 0.5)
            
            Text("\(value)")
                .foregroundColor(.black)
                .font(.system(size: cellSize * 0.25, weight: .bold))
        }
        .position(
            x: CGFloat(x) * cellSize + cellSize / 2,
            y: CGFloat(y) * cellSize + cellSize / 2
        )
    }
    
    @ViewBuilder
    private func incompletePath() -> some View {
        let gridSize: CGFloat = 120
        let cellSize = gridSize / 3
        
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(white: 0.1))
                .frame(width: gridSize + 20, height: gridSize + 20)
            
            // Grid cells - some filled, some empty
            ForEach(0..<3, id: \.self) { row in
                ForEach(0..<3, id: \.self) { col in
                    let isFilled = (row == 0 && col == 0) || (row == 1 && col == 0) || (row == 2 && col == 0)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(isFilled ? Color.purple.opacity(0.5) : Color(white: 0.15))
                        .stroke(Color(white: 0.3), lineWidth: 1)
                        .frame(width: cellSize - 2, height: cellSize - 2)
                        .position(
                            x: CGFloat(col) * cellSize + cellSize / 2,
                            y: CGFloat(row) * cellSize + cellSize / 2
                        )
                }
            }
            
            // Numbers
            numberCircle(3, x: 0, y: 0, cellSize: cellSize)
            numberCircle(1, x: 0, y: 1, cellSize: cellSize)
            numberCircle(2, x: 0, y: 2, cellSize: cellSize)
        }
        .frame(width: gridSize + 20, height: gridSize + 20)
    }
    
    @ViewBuilder
    private func completePath() -> some View {
        let gridSize: CGFloat = 120
        let cellSize = gridSize / 3
        
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(white: 0.1))
                .frame(width: gridSize + 20, height: gridSize + 20)
            
            // Grid cells - all filled
            ForEach(0..<3, id: \.self) { row in
                ForEach(0..<3, id: \.self) { col in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.green.opacity(0.5))
                        .stroke(Color(white: 0.3), lineWidth: 1)
                        .frame(width: cellSize - 2, height: cellSize - 2)
                        .position(
                            x: CGFloat(col) * cellSize + cellSize / 2,
                            y: CGFloat(row) * cellSize + cellSize / 2
                        )
                }
            }
            
            // Numbers
            numberCircle(3, x: 2, y: 0, cellSize: cellSize)
            numberCircle(1, x: 0, y: 2, cellSize: cellSize)
            numberCircle(2, x: 1, y: 1, cellSize: cellSize)
        }
        .frame(width: gridSize + 20, height: gridSize + 20)
    }
}

