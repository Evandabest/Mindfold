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
                .fill(Color.white)
            
            GeometryReader { geo in
                let pipeWidth: CGFloat = 7
                let padding: CGFloat = 12
                let w = geo.size.width - (padding * 2)
                let h = geo.size.height - (padding * 2)
                
                // Draw pipe segments as rounded rectangles
                // Top horizontal segment
                RoundedRectangle(cornerRadius: pipeWidth / 2)
                    .fill(Color.cyan)
                    .frame(width: w * 0.5, height: pipeWidth)
                    .position(x: padding + w * 0.25, y: padding + h * 0.25)
                
                // Left vertical segment
                RoundedRectangle(cornerRadius: pipeWidth / 2)
                    .fill(Color.cyan)
                    .frame(width: pipeWidth, height: h * 0.4)
                    .position(x: padding + w * 0.2, y: padding + h * 0.5)
                
                // Bottom horizontal segment
                RoundedRectangle(cornerRadius: pipeWidth / 2)
                    .fill(Color.cyan)
                    .frame(width: w * 0.45, height: pipeWidth)
                    .position(x: padding + w * 0.6, y: padding + h * 0.7)
                
                // Right vertical segment
                RoundedRectangle(cornerRadius: pipeWidth / 2)
                    .fill(Color.cyan)
                    .frame(width: pipeWidth, height: h * 0.35)
                    .position(x: padding + w * 0.75, y: padding + h * 0.4)
                
                // Curved connections using circles
                // Top-left corner connector
                Circle()
                    .fill(Color.cyan)
                    .frame(width: pipeWidth * 1.5, height: pipeWidth * 1.5)
                    .position(x: padding + w * 0.2, y: padding + h * 0.25)
                
                // Bottom-left corner connector
                Circle()
                    .fill(Color.cyan)
                    .frame(width: pipeWidth * 1.5, height: pipeWidth * 1.5)
                    .position(x: padding + w * 0.2, y: padding + h * 0.7)
                
                // Bottom-right corner connector
                Circle()
                    .fill(Color.cyan)
                    .frame(width: pipeWidth * 1.5, height: pipeWidth * 1.5)
                    .position(x: padding + w * 0.75, y: padding + h * 0.7)
                
                // Top-right corner connector
                Circle()
                    .fill(Color.cyan)
                    .frame(width: pipeWidth * 1.5, height: pipeWidth * 1.5)
                    .position(x: padding + w * 0.75, y: padding + h * 0.25)
            }
        }
    }
}

