//
//  FloodFillIcon.swift
//  Mindfold
//
//  Created by Evan Haque on 1/17/26.
//

import SwiftUI

struct FloodFillIcon: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(white: 0.2))
            
            GeometryReader { geo in
                let cellSize = geo.size.width / 3
                
                VStack(spacing: 0) {
                    // Top row: Red, Red, Blue
                    HStack(spacing: 0) {
                        ZStack {
                            Rectangle()
                                .fill(Color(red: 0.85, green: 0.4, blue: 0.35))
                            Rectangle()
                                .stroke(Color.black, lineWidth: 2)
                        }
                        .frame(width: cellSize, height: cellSize)
                        
                        ZStack {
                            Rectangle()
                                .fill(Color(red: 0.85, green: 0.4, blue: 0.35))
                            Rectangle()
                                .stroke(Color.black, lineWidth: 2)
                        }
                        .frame(width: cellSize, height: cellSize)
                        
                        ZStack {
                            Rectangle()
                                .fill(Color(red: 0.4, green: 0.55, blue: 0.8))
                            Rectangle()
                                .stroke(Color.black, lineWidth: 2)
                        }
                        .frame(width: cellSize, height: cellSize)
                    }
                    
                    // Middle row: Red, Orange, Blue
                    HStack(spacing: 0) {
                        ZStack {
                            Rectangle()
                                .fill(Color(red: 0.85, green: 0.4, blue: 0.35))
                            Rectangle()
                                .stroke(Color.black, lineWidth: 2)
                        }
                        .frame(width: cellSize, height: cellSize)
                        
                        ZStack {
                            Rectangle()
                                .fill(Color(red: 0.9, green: 0.65, blue: 0.35))
                            Rectangle()
                                .stroke(Color.black, lineWidth: 2)
                        }
                        .frame(width: cellSize, height: cellSize)
                        
                        ZStack {
                            Rectangle()
                                .fill(Color(red: 0.4, green: 0.55, blue: 0.8))
                            Rectangle()
                                .stroke(Color.black, lineWidth: 2)
                        }
                        .frame(width: cellSize, height: cellSize)
                    }
                    
                    // Bottom row: Orange, Green, Red
                    HStack(spacing: 0) {
                        ZStack {
                            Rectangle()
                                .fill(Color(red: 0.9, green: 0.65, blue: 0.35))
                            Rectangle()
                                .stroke(Color.black, lineWidth: 2)
                        }
                        .frame(width: cellSize, height: cellSize)
                        
                        ZStack {
                            Rectangle()
                                .fill(Color(red: 0.5, green: 0.7, blue: 0.4))
                            Rectangle()
                                .stroke(Color.black, lineWidth: 2)
                        }
                        .frame(width: cellSize, height: cellSize)
                        
                        ZStack {
                            Rectangle()
                                .fill(Color(red: 0.85, green: 0.4, blue: 0.35))
                            Rectangle()
                                .stroke(Color.black, lineWidth: 2)
                        }
                        .frame(width: cellSize, height: cellSize)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
