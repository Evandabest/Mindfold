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
                        Text("Paint the board one color")
                            .foregroundColor(.gray)
                            .font(.system(size: 16))
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        // Rule 1: Select color first
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Rule 1: Select Color First")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                            Text("First, select a color from the palette. Then tap the board to apply it.")
                                .foregroundColor(.gray)
                                .font(.system(size: 15))
                            
                            colorPaletteExample()
                                .frame(maxWidth: .infinity)
                                .padding(.top, 8)
                        }
                        
                        // Rule 2: Flood fill mechanic
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Rule 2: Flood Fill")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                            Text("When you tap the board, all connected cells of the current color in the top-left region change to your selected color.")
                                .foregroundColor(.gray)
                                .font(.system(size: 15))
                            
                            floodExample()
                                .frame(maxWidth: .infinity)
                        }
                        
                        // Rule 3: Limited moves
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Rule 3: Limited Moves")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                            Text("You have a limited number of moves to paint the entire board one color. Plan your moves wisely!")
                                .foregroundColor(.gray)
                                .font(.system(size: 15))
                        }
                        
                        // Rule 4: Strategy
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Rule 4: Strategy")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                            Text("Start by capturing large adjacent areas. Work from the top-left corner outward.")
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
    
    private func floodExample() -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 30) {
                VStack(spacing: 8) {
                    floodGrid(colors: [[0, 1], [0, 2]], highlightRed: true)
                    Text("Before: Red region in top-left")
                        .foregroundColor(.gray)
                        .font(.system(size: 13))
                }
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.white)
                
                VStack(spacing: 8) {
                    floodGrid(colors: [[1, 1], [1, 2]])
                    Text("After: Red becomes blue")
                        .foregroundColor(.gray)
                        .font(.system(size: 13))
                }
            }
            
            Text("Select blue, then tap → all connected red cells become blue")
                .foregroundColor(.gray)
                .font(.system(size: 12))
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
    
    private func floodGrid(colors: [[Int]], highlightRed: Bool = false) -> some View {
        let colorMap: [Color] = [.red, .blue, .green, .yellow]
        
        return VStack(spacing: 1) {
            ForEach(0..<colors.count, id: \.self) { row in
                HStack(spacing: 1) {
                    ForEach(0..<colors[row].count, id: \.self) { col in
                        let isRed = colors[row][col] == 0
                        Rectangle()
                            .fill(colorMap[colors[row][col]])
                            .frame(width: 50, height: 50)
                            .overlay(
                                Rectangle()
                                    .stroke(highlightRed && isRed ? Color.yellow : Color.white.opacity(0.3), lineWidth: highlightRed && isRed ? 3 : 2)
                            )
                    }
                }
            }
        }
    }
    
    private func colorPaletteExample() -> some View {
        let colors: [Color] = [.red, .blue, .green, .yellow]
        
        return HStack(spacing: 16) {
            ForEach(0..<colors.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 12)
                    .fill(colors[index])
                    .frame(width: 50, height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(index == 1 ? Color.white : Color.clear, lineWidth: 3)
                    )
            }
        }
    }
}
