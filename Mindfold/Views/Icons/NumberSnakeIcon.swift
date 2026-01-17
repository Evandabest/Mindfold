//
//  NumberSnakeIcon.swift
//  Mindfold
//
//  Created by Evan Haque on 1/17/26.
//

import SwiftUI

struct NumberSnakeIcon: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(white: 0.2))
            
            GeometryReader { geo in
                let cellSize = geo.size.width / 3
                
                VStack(spacing: 0) {
                    // Top row: Pink (1), Red, Red (2)
                    HStack(spacing: 0) {
                        ZStack {
                            Rectangle()
                                .fill(Color(red: 1.0, green: 0.7, blue: 0.7))
                            Rectangle()
                                .stroke(Color.black, lineWidth: 2)
                            Text("1")
                                .foregroundColor(.white)
                                .font(.system(size: cellSize * 0.5, weight: .bold))
                        }
                        .frame(width: cellSize, height: cellSize)
                        
                        ZStack {
                            Rectangle()
                                .fill(Color(red: 0.9, green: 0.5, blue: 0.5))
                            Rectangle()
                                .stroke(Color.black, lineWidth: 2)
                        }
                        .frame(width: cellSize, height: cellSize)
                        
                        ZStack {
                            Rectangle()
                                .fill(Color(red: 0.85, green: 0.4, blue: 0.4))
                            Rectangle()
                                .stroke(Color.black, lineWidth: 2)
                            Text("2")
                                .foregroundColor(.white)
                                .font(.system(size: cellSize * 0.5, weight: .bold))
                        }
                        .frame(width: cellSize, height: cellSize)
                    }
                    
                    // Middle row: Orange, Orange (3), Brown
                    HStack(spacing: 0) {
                        ZStack {
                            Rectangle()
                                .fill(Color(red: 0.9, green: 0.65, blue: 0.4))
                            Rectangle()
                                .stroke(Color.black, lineWidth: 2)
                        }
                        .frame(width: cellSize, height: cellSize)
                        
                        ZStack {
                            Rectangle()
                                .fill(Color(red: 0.95, green: 0.6, blue: 0.35))
                            Rectangle()
                                .stroke(Color.black, lineWidth: 2)
                            Text("3")
                                .foregroundColor(.white)
                                .font(.system(size: cellSize * 0.5, weight: .bold))
                        }
                        .frame(width: cellSize, height: cellSize)
                        
                        ZStack {
                            Rectangle()
                                .fill(Color(red: 0.7, green: 0.45, blue: 0.3))
                            Rectangle()
                                .stroke(Color.black, lineWidth: 2)
                        }
                        .frame(width: cellSize, height: cellSize)
                    }
                    
                    // Bottom row: Orange, Yellow, Teal (4)
                    HStack(spacing: 0) {
                        ZStack {
                            Rectangle()
                                .fill(Color(red: 0.9, green: 0.65, blue: 0.4))
                            Rectangle()
                                .stroke(Color.black, lineWidth: 2)
                        }
                        .frame(width: cellSize, height: cellSize)
                        
                        ZStack {
                            Rectangle()
                                .fill(Color(red: 0.95, green: 0.8, blue: 0.45))
                            Rectangle()
                                .stroke(Color.black, lineWidth: 2)
                        }
                        .frame(width: cellSize, height: cellSize)
                        
                        ZStack {
                            Rectangle()
                                .fill(Color(red: 0.4, green: 0.65, blue: 0.6))
                            Rectangle()
                                .stroke(Color.black, lineWidth: 2)
                            Text("4")
                                .foregroundColor(.white)
                                .font(.system(size: cellSize * 0.5, weight: .bold))
                        }
                        .frame(width: cellSize, height: cellSize)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
