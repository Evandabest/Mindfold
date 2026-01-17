//
//  StarBattleTutorialView.swift
//  Mindfold
//
//  Created by Evan Haque on 1/9/26.
//

import SwiftUI

struct StarBattleTutorialView: View {
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
                        Text("Place stars in each region and row")
                            .foregroundColor(.gray)
                            .font(.system(size: 16))
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        // Rule 1: One star per region
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Rule 1: One Star Per Region")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                            Text("Each colored region must contain exactly one star.")
                                .foregroundColor(.gray)
                                .font(.system(size: 15))
                            
                            HStack(spacing: 30) {
                                VStack(spacing: 8) {
                                    starGrid(
                                        regions: [[0, 0], [1, 1]],
                                        stars: [(0, 0)],
                                        size: 2,
                                        isValid: true
                                    )
                                    Text("✓ One per region")
                                        .foregroundColor(.green)
                                        .font(.system(size: 13))
                                }
                                
                                VStack(spacing: 8) {
                                    starGrid(
                                        regions: [[0, 0], [1, 1]],
                                        stars: [(0, 0), (0, 1)],
                                        size: 2,
                                        isValid: false
                                    )
                                    Text("✗ Two in region")
                                        .foregroundColor(.red)
                                        .font(.system(size: 13))
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        // Rule 2: One star per row
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Rule 2: One Star Per Row")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                            Text("Each horizontal row must contain exactly one star.")
                                .foregroundColor(.gray)
                                .font(.system(size: 15))
                            
                            HStack(spacing: 30) {
                                VStack(spacing: 8) {
                                    starGrid(
                                        regions: [[0, 0, 1, 1], [0, 2, 2, 1], [3, 3, 3, 3], [3, 3, 3, 3]],
                                        stars: [(0, 1), (1, 3), (2, 0), (3, 2)],
                                        size: 4,
                                        isValid: true
                                    )
                                    Text("✓ One per row")
                                        .foregroundColor(.green)
                                        .font(.system(size: 13))
                                }
                                
                                VStack(spacing: 8) {
                                    starGrid(
                                        regions: [[0, 0, 1, 1], [0, 2, 2, 1], [3, 3, 3, 3], [3, 3, 3, 3]],
                                        stars: [(0, 0), (0, 3), (1, 2), (2, 1)],
                                        size: 4,
                                        isValid: false,
                                        highlightRow: 0
                                    )
                                    Text("✗ Two in row 1")
                                        .foregroundColor(.red)
                                        .font(.system(size: 13))
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        // Rule 3: One star per column
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Rule 3: One Star Per Column")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                            Text("Each vertical column must contain exactly one star.")
                                .foregroundColor(.gray)
                                .font(.system(size: 15))
                            
                            HStack(spacing: 30) {
                                VStack(spacing: 8) {
                                    starGrid(
                                        regions: [[0, 0, 1, 1], [0, 2, 2, 1], [3, 3, 3, 3], [3, 3, 3, 3]],
                                        stars: [(0, 1), (1, 3), (2, 0), (3, 2)],
                                        size: 4,
                                        isValid: true
                                    )
                                    Text("✓ One per column")
                                        .foregroundColor(.green)
                                        .font(.system(size: 13))
                                }
                                
                                VStack(spacing: 8) {
                                    starGrid(
                                        regions: [[0, 0, 1, 1], [0, 2, 2, 1], [3, 3, 3, 3], [3, 3, 3, 3]],
                                        stars: [(0, 1), (1, 0), (3, 1), (2, 3)],
                                        size: 4,
                                        isValid: false,
                                        highlightCol: 1
                                    )
                                    Text("✗ Two in column 2")
                                        .foregroundColor(.red)
                                        .font(.system(size: 13))
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        // Rule 4: No touching stars
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Rule 4: Stars Cannot Touch")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                            Text("Stars cannot be adjacent to each other, even diagonally.")
                                .foregroundColor(.gray)
                                .font(.system(size: 15))
                            
                            HStack(spacing: 30) {
                                VStack(spacing: 8) {
                                    starGrid(
                                        regions: [[0, 1], [2, 3]],
                                        stars: [(0, 0), (1, 1)],
                                        size: 2,
                                        isValid: false
                                    )
                                    Text("✗ Touching diagonal")
                                        .foregroundColor(.red)
                                        .font(.system(size: 13))
                                }
                                
                                VStack(spacing: 8) {
                                    starGrid(
                                        regions: [[0, 1], [2, 3]],
                                        stars: [(0, 0), (1, 0)],
                                        size: 2,
                                        isValid: false
                                    )
                                    Text("✗ Touching adjacent")
                                        .foregroundColor(.red)
                                        .font(.system(size: 13))
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        // Example
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Complete Example")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                            
                            starGrid(
                                regions: [[0, 0, 1, 1], [0, 2, 1, 3], [2, 2, 3, 3], [2, 2, 3, 3]],
                                stars: [(0, 1), (1, 3), (2, 0), (3, 2)],
                                size: 4,
                                isValid: true,
                                showRegionBorders: true
                            )
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
    
    private func starGrid(regions: [[Int]], stars: [(Int, Int)], size: Int, isValid: Bool, highlightRow: Int? = nil, highlightCol: Int? = nil, showRegionBorders: Bool = false) -> some View {
        let cellSize: CGFloat = size == 2 ? 50.0 : (size == 3 ? 38.0 : 30.0)
        let colors: [Color] = [
            Color(red: 0.2, green: 0.8, blue: 0.4),  // Bright green
            Color(red: 0.3, green: 0.6, blue: 1.0),  // Bright blue
            Color(red: 1.0, green: 0.6, blue: 0.2),  // Bright orange
            Color(red: 0.8, green: 0.4, blue: 1.0)   // Bright purple
        ]
        
        return VStack(spacing: 1) {
            ForEach(0..<size, id: \.self) { row in
                HStack(spacing: 1) {
                    ForEach(0..<size, id: \.self) { col in
                        let regionId = regions[row][col]
                        let hasStar = stars.contains(where: { $0.0 == row && $0.1 == col })
                        let isHighlighted = (highlightRow == row) || (highlightCol == col)
                        
                        ZStack {
                            Rectangle()
                                .fill(isHighlighted ? Color.red.opacity(0.5) : colors[regionId].opacity(0.6))
                                .frame(width: cellSize, height: cellSize)
                            
                            if showRegionBorders {
                                // Draw thicker borders between different regions
                                Rectangle()
                                    .stroke(Color.white, lineWidth: shouldDrawThickBorder(row: row, col: col, size: size, regions: regions) ? 3 : 1)
                                    .frame(width: cellSize, height: cellSize)
                            } else {
                                Rectangle()
                                    .stroke(isValid ? Color.white.opacity(0.5) : Color.red, lineWidth: 1.5)
                                    .frame(width: cellSize, height: cellSize)
                            }
                            
                            if hasStar {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .font(.system(size: cellSize * 0.4))
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func shouldDrawThickBorder(row: Int, col: Int, size: Int, regions: [[Int]]) -> Bool {
        let currentRegion = regions[row][col]
        var hasThickBorder = false
        
        // Check if different from top neighbor
        if row > 0 && regions[row - 1][col] != currentRegion {
            hasThickBorder = true
        }
        // Check if different from left neighbor
        if col > 0 && regions[row][col - 1] != currentRegion {
            hasThickBorder = true
        }
        
        return hasThickBorder
    }
}
