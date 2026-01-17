//
//  NetwalkTutorialView.swift
//  Mindfold
//
//  Created by Evan Haque on 1/15/26.
//

import SwiftUI

struct NetwalkTutorialView: View {
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
                        Text("Rotate tiles to power the network")
                            .foregroundColor(.gray)
                            .font(.system(size: 16))
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        // Rule 1: Tile types and rotation
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Rule 1: Tile Types")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                            Text("There are different types of tiles with varying connections:")
                                .foregroundColor(.gray)
                                .font(.system(size: 15))
                            
                            VStack(spacing: 16) {
                                // Row 1: Straight and Corner
                                HStack(spacing: 20) {
                                    tileTypeExample(type: .straight, label: "Straight")
                                    tileTypeExample(type: .corner, label: "Corner")
                                    tileTypeExample(type: .tJunction, label: "T-Junction")
                                }
                                .frame(maxWidth: .infinity)
                                
                                // Row 2: Cross and Terminal
                                HStack(spacing: 20) {
                                    tileTypeExample(type: .cross, label: "Cross")
                                    tileTypeExample(type: .terminal, label: "Terminal")
                                    tileTypeExample(type: .source, label: "Source")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            
                            Text("Tap any tile to rotate it 90° clockwise.")
                                .foregroundColor(.gray)
                                .font(.system(size: 15))
                                .padding(.top, 8)
                            
                            HStack(spacing: 30) {
                                tileExample(rotation: 0, label: "Before")
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.white)
                                tileExample(rotation: 1, label: "After tap")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        // Rule 2: Power source
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Rule 2: Power Source")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                            Text("The yellow tile is the power source. All tiles must connect to it.")
                                .foregroundColor(.gray)
                                .font(.system(size: 15))
                        }
                        
                        // Rule 3: Connect all
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Rule 3: Complete Network")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                            Text("Rotate all tiles so they form one connected network with no loose ends.")
                                .foregroundColor(.gray)
                                .font(.system(size: 15))
                        }
                        
                        // Example
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Example")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                            
                            netwalkExample()
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
    
    private func tileExample(rotation: Int, label: String) -> some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(white: 0.2))
                    .frame(width: 60, height: 60)
                
                tilePath(type: .corner, size: 60)
                    .stroke(Color.orange, lineWidth: 6)
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(Double(rotation) * 90))
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Text(label)
                .foregroundColor(.gray)
                .font(.system(size: 13))
        }
    }
    
    private func netwalkExample() -> some View {
        VStack(spacing: 2) {
            HStack(spacing: 2) {
                networkTile(type: .corner, rotation: 1, isPowered: true)
                networkTile(type: .straight, rotation: 0, isPowered: true)
            }
            HStack(spacing: 2) {
                networkTile(type: .source, rotation: 0, isPowered: true)
                networkTile(type: .corner, rotation: 2, isPowered: true)
            }
        }
    }
    
    enum TileType {
        case straight, corner, source, tJunction, cross, terminal
    }
    
    private func tilePath(type: TileType, size: CGFloat = 55) -> Path {
        var path = Path()
        let center = size / 2
        
        switch type {
        case .straight:
            // Horizontal line
            path.move(to: CGPoint(x: 0, y: center))
            path.addLine(to: CGPoint(x: size, y: center))
        case .corner, .source:
            // L-shape
            path.move(to: CGPoint(x: center, y: 0))
            path.addLine(to: CGPoint(x: center, y: center))
            path.addLine(to: CGPoint(x: size, y: center))
        case .tJunction:
            // T-shape (3 connections)
            path.move(to: CGPoint(x: center, y: 0))
            path.addLine(to: CGPoint(x: center, y: center))
            path.move(to: CGPoint(x: 0, y: center))
            path.addLine(to: CGPoint(x: size, y: center))
        case .cross:
            // Cross (4 connections)
            path.move(to: CGPoint(x: center, y: 0))
            path.addLine(to: CGPoint(x: center, y: size))
            path.move(to: CGPoint(x: 0, y: center))
            path.addLine(to: CGPoint(x: size, y: center))
        case .terminal:
            // Single end (1 connection)
            path.move(to: CGPoint(x: center, y: center))
            path.addLine(to: CGPoint(x: size, y: center))
        }
        return path
    }
    
    private func networkTile(type: TileType, rotation: Int, isPowered: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(white: 0.2))
                .frame(width: 55, height: 55)
            
            tilePath(type: type, size: 55)
                .stroke(isPowered ? Color.yellow : Color.orange, lineWidth: 5)
                .frame(width: 55, height: 55)
                .rotationEffect(.degrees(Double(rotation) * 90))
        }
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
    
    private func tileTypeExample(type: TileType, label: String) -> some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(white: 0.2))
                    .frame(width: 50, height: 50)
                
                tilePath(type: type, size: 50)
                    .stroke(type == .source ? Color.yellow : Color.orange, lineWidth: 4)
                    .frame(width: 50, height: 50)
            }
            .clipShape(RoundedRectangle(cornerRadius: 6))
            
            Text(label)
                .foregroundColor(.gray)
                .font(.system(size: 11))
        }
    }
}
