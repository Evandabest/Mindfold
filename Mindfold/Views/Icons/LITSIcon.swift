//
//  LITSIcon.swift
//  Mindfold
//
//  Created by Evan Haque on 1/17/26.
//

import SwiftUI

struct LITSIcon: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(white: 0.2))
            
            GeometryReader { geo in
                let cellSize = geo.size.width / 3
                
                // 3x3 grid
                VStack(spacing: 0) {
                    // Top row - all white
                    HStack(spacing: 0) {
                        ForEach(0..<3) { _ in
                            ZStack {
                                Rectangle()
                                    .fill(Color.white)
                                Rectangle()
                                    .stroke(Color.black, lineWidth: 1.5)
                            }
                            .frame(width: cellSize, height: cellSize)
                        }
                    }
                    
                    // Middle row - left white, middle purple, right white
                    HStack(spacing: 0) {
                        ZStack {
                            Rectangle()
                                .fill(Color.white)
                            Rectangle()
                                .stroke(Color.black, lineWidth: 1.5)
                        }
                        .frame(width: cellSize, height: cellSize)
                        
                        ZStack {
                            Rectangle()
                                .fill(Color(red: 0.55, green: 0.45, blue: 0.85))
                            Rectangle()
                                .stroke(Color.black, lineWidth: 1.5)
                        }
                        .frame(width: cellSize, height: cellSize)
                        
                        ZStack {
                            Rectangle()
                                .fill(Color.white)
                            Rectangle()
                                .stroke(Color.black, lineWidth: 1.5)
                        }
                        .frame(width: cellSize, height: cellSize)
                    }
                    
                    // Bottom row - all purple
                    HStack(spacing: 0) {
                        ForEach(0..<3) { _ in
                            ZStack {
                                Rectangle()
                                    .fill(Color(red: 0.55, green: 0.45, blue: 0.85))
                                Rectangle()
                                    .stroke(Color.black, lineWidth: 1.5)
                            }
                            .frame(width: cellSize, height: cellSize)
                        }
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
