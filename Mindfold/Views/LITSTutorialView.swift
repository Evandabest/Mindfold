//
//  LITSTutorialView.swift
//  Mindfold
//
//  Created by Evan Haque on 1/15/26.
//

import SwiftUI

struct LITSTutorialView: View {
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
                        Text("Place L-I-T-S tetrominoes in regions")
                            .foregroundColor(.gray)
                            .font(.system(size: 16))
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        // Rule 1: LITS shapes
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Rule 1: The Four Shapes")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                            Text("Each region must contain exactly one tetromino: L, I, T, or S shape.")
                                .foregroundColor(.gray)
                                .font(.system(size: 15))
                            
                            HStack(spacing: 16) {
                                tetrominoShape(.l, label: "L")
                                tetrominoShape(.i, label: "I")
                                tetrominoShape(.t, label: "T")
                                tetrominoShape(.s, label: "S")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        // Rule 2: No 2x2 blocks
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Rule 2: No 2×2 Blocks")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                            Text("Shaded cells cannot form a 2×2 square anywhere on the grid.")
                                .foregroundColor(.gray)
                                .font(.system(size: 15))
                            
                            HStack(spacing: 30) {
                                VStack(spacing: 8) {
                                    litsGrid(cells: [(0,0), (0,1), (1,0), (1,2)], isValid: true)
                                    Text("✓ No 2×2")
                                        .foregroundColor(.green)
                                        .font(.system(size: 13))
                                }
                                
                                VStack(spacing: 8) {
                                    litsGrid(cells: [(0,0), (0,1), (1,0), (1,1)], isValid: false)
                                    Text("✗ Forms 2×2")
                                        .foregroundColor(.red)
                                        .font(.system(size: 13))
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        // Rule 3: All connected
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Rule 3: All Connected")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                            Text("All shaded cells must form one connected group.")
                                .foregroundColor(.gray)
                                .font(.system(size: 15))
                            
                            HStack(spacing: 30) {
                                VStack(spacing: 8) {
                                    litsGrid(
                                        cells: [(0,0), (1,0), (2,0), (2,1), (2,2), (1,2)],
                                        isValid: true,
                                        gridSize: 4
                                    )
                                    Text("✓ All connected")
                                        .foregroundColor(.green)
                                        .font(.system(size: 13))
                                }
                                
                                VStack(spacing: 8) {
                                    litsGrid(
                                        cells: [(0,0), (1,0), (2,2), (3,2)],
                                        isValid: false,
                                        gridSize: 4
                                    )
                                    Text("✗ Disconnected")
                                        .foregroundColor(.red)
                                        .font(.system(size: 13))
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        // Rule 4: Same shape separation
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Rule 4: Shape Separation")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                            Text("Two tetrominoes of the same type cannot touch, even diagonally.")
                                .foregroundColor(.gray)
                                .font(.system(size: 15))
                            
                            HStack(spacing: 30) {
                                VStack(spacing: 8) {
                                    litsGridWithColors(
                                        groups: [
                                            [(0,0), (1,0), (2,0), (2,1)],  // L-shape (purple)
                                            [(0,2), (0,3), (1,3), (2,3)]   // Different shape (blue)
                                        ],
                                        colors: [Color.purple, Color.blue],
                                        isValid: true,
                                        gridSize: 4
                                    )
                                    Text("✓ Different shapes")
                                        .foregroundColor(.green)
                                        .font(.system(size: 13))
                                }
                                
                                VStack(spacing: 8) {
                                    litsGridWithColors(
                                        groups: [
                                            [(0,0), (1,0), (2,0), (2,1)],  // L-shape (purple)
                                            [(0,2), (1,2), (2,2), (2,3)]   // Another L-shape (purple)
                                        ],
                                        colors: [Color.purple, Color.purple],
                                        isValid: false,
                                        gridSize: 4
                                    )
                                    Text("✗ Same L-shapes touch")
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
    
    enum TetrominoType {
        case l, i, t, s
    }
    
    private func tetrominoShape(_ type: TetrominoType, label: String) -> some View {
        let cells: [(Int, Int)]
        switch type {
        case .l:
            cells = [(0, 0), (1, 0), (2, 0), (2, 1)]
        case .i:
            cells = [(0, 0), (1, 0), (2, 0), (3, 0)]
        case .t:
            cells = [(0, 0), (0, 1), (0, 2), (1, 1)]
        case .s:
            cells = [(0, 0), (0, 1), (1, 1), (1, 2)]
        }
        
        let maxRow = cells.map { $0.0 }.max() ?? 0
        let maxCol = cells.map { $0.1 }.max() ?? 0
        
        return VStack(spacing: 4) {
            VStack(spacing: 1) {
                ForEach(0...maxRow, id: \.self) { row in
                    HStack(spacing: 1) {
                        ForEach(0...maxCol, id: \.self) { col in
                            Rectangle()
                                .fill(cells.contains(where: { $0.0 == row && $0.1 == col }) ? Color.purple : Color(white: 0.2))
                                .frame(width: 15, height: 15)
                                .overlay(
                                    Rectangle()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                }
            }
            
            Text(label)
                .foregroundColor(.white)
                .font(.system(size: 12, weight: .bold))
        }
    }
    
    private func litsGrid(cells: [(Int, Int)], isValid: Bool, gridSize: Int = 3) -> some View {
        let cellSize: CGFloat = gridSize == 3 ? 35.0 : 28.0
        
        return VStack(spacing: 1) {
            ForEach(0..<gridSize, id: \.self) { row in
                HStack(spacing: 1) {
                    ForEach(0..<gridSize, id: \.self) { col in
                        Rectangle()
                            .fill(cells.contains(where: { $0.0 == row && $0.1 == col }) ? Color.purple : Color(white: 0.2))
                            .frame(width: cellSize, height: cellSize)
                            .overlay(
                                Rectangle()
                                    .stroke(isValid ? Color.white.opacity(0.5) : Color.red, lineWidth: 1.5)
                            )
                    }
                }
            }
        }
    }
    
    private func litsGridWithColors(groups: [[(Int, Int)]], colors: [Color], isValid: Bool, gridSize: Int = 3) -> some View {
        let cellSize: CGFloat = gridSize == 3 ? 35.0 : 28.0
        
        return VStack(spacing: 1) {
            ForEach(0..<gridSize, id: \.self) { row in
                HStack(spacing: 1) {
                    ForEach(0..<gridSize, id: \.self) { col in
                        let cellColor: Color = {
                            for (index, group) in groups.enumerated() {
                                if group.contains(where: { $0.0 == row && $0.1 == col }) {
                                    return colors[index]
                                }
                            }
                            return Color(white: 0.2)
                        }()
                        
                        Rectangle()
                            .fill(cellColor)
                            .frame(width: cellSize, height: cellSize)
                            .overlay(
                                Rectangle()
                                    .stroke(isValid ? Color.white.opacity(0.5) : Color.red, lineWidth: 1.5)
                            )
                    }
                }
            }
        }
    }
}
