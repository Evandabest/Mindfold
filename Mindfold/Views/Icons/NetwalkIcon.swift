//
//  NetwalkIcon.swift
//  Mindfold
//
//  Created by Evan Haque on 1/9/26.
//

import SwiftUI

struct NetwalkIcon: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(white: 0.25))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black, lineWidth: 2)
                )
            
            GeometryReader { geo in
                let cellSize = geo.size.width / 3
                let pipeWidth = cellSize * 0.25
                
                // Draw grid lines
                Path { path in
                    // Vertical lines
                    for i in 1...2 {
                        let x = CGFloat(i) * cellSize
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: geo.size.height))
                    }
                    // Horizontal lines
                    for i in 1...2 {
                        let y = CGFloat(i) * cellSize
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geo.size.width, y: y))
                    }
                }
                .stroke(Color.black, lineWidth: 1.5)
                
                // White pipe paths with dashed lines
                // Vertical pipe in left column (rows 0-1)
                ZStack {
                    RoundedRectangle(cornerRadius: pipeWidth / 2)
                        .fill(Color.white)
                        .frame(width: pipeWidth, height: cellSize * 2)
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: -cellSize))
                        path.addLine(to: CGPoint(x: 0, y: cellSize))
                    }
                    .stroke(Color.black, style: StrokeStyle(lineWidth: 2, dash: [4, 3]))
                }
                .position(x: cellSize * 0.5, y: cellSize)
                
                // Vertical pipe in middle column (rows 1-2)
                ZStack {
                    RoundedRectangle(cornerRadius: pipeWidth / 2)
                        .fill(Color.white)
                        .frame(width: pipeWidth, height: cellSize * 2)
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: -cellSize))
                        path.addLine(to: CGPoint(x: 0, y: cellSize))
                    }
                    .stroke(Color.black, style: StrokeStyle(lineWidth: 2, dash: [4, 3]))
                }
                .position(x: cellSize * 1.5, y: cellSize * 2)
                
                // Horizontal pipe at bottom (cols 1-2)
                ZStack {
                    RoundedRectangle(cornerRadius: pipeWidth / 2)
                        .fill(Color.white)
                        .frame(width: cellSize * 2, height: pipeWidth)
                    Path { path in
                        path.move(to: CGPoint(x: -cellSize, y: 0))
                        path.addLine(to: CGPoint(x: cellSize, y: 0))
                    }
                    .stroke(Color.black, style: StrokeStyle(lineWidth: 2, dash: [4, 3]))
                }
                .position(x: cellSize * 2, y: cellSize * 2.5)
            }
        }
    }
}

