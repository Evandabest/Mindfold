//
//  BridgesIcon.swift
//  Mindfold
//
//  Created by Evan Haque on 1/17/26.
//

import SwiftUI

struct BridgesIcon: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black, lineWidth: 2)
                )
            
            GeometryReader { geo in
                let centerX = geo.size.width / 2
                let centerY = geo.size.height / 2
                let nodeRadius = geo.size.width * 0.12
                let outerRadius = geo.size.width * 0.32
                
                // Lines connecting center to all nodes
                Path { path in
                    // To top
                    path.move(to: CGPoint(x: centerX, y: centerY))
                    path.addLine(to: CGPoint(x: centerX, y: centerY - outerRadius))
                    
                    // To right
                    path.move(to: CGPoint(x: centerX, y: centerY))
                    path.addLine(to: CGPoint(x: centerX + outerRadius, y: centerY))
                    
                    // To bottom
                    path.move(to: CGPoint(x: centerX, y: centerY))
                    path.addLine(to: CGPoint(x: centerX, y: centerY + outerRadius))
                    
                    // To left
                    path.move(to: CGPoint(x: centerX, y: centerY))
                    path.addLine(to: CGPoint(x: centerX - outerRadius, y: centerY))
                }
                .stroke(Color.black, lineWidth: 2)
                
                // Top node (2 - filled)
                ZStack {
                    Circle()
                        .fill(Color.black)
                        .frame(width: nodeRadius * 2, height: nodeRadius * 2)
                    Text("2")
                        .foregroundColor(.white)
                        .font(.system(size: nodeRadius * 1.2, weight: .bold))
                }
                .position(x: centerX, y: centerY - outerRadius)
                
                // Right node (2 - filled)
                ZStack {
                    Circle()
                        .fill(Color.black)
                        .frame(width: nodeRadius * 2, height: nodeRadius * 2)
                    Text("2")
                        .foregroundColor(.white)
                        .font(.system(size: nodeRadius * 1.2, weight: .bold))
                }
                .position(x: centerX + outerRadius, y: centerY)
                
                // Bottom node (3 - filled)
                ZStack {
                    Circle()
                        .fill(Color.black)
                        .frame(width: nodeRadius * 2, height: nodeRadius * 2)
                    Text("3")
                        .foregroundColor(.white)
                        .font(.system(size: nodeRadius * 1.2, weight: .bold))
                }
                .position(x: centerX, y: centerY + outerRadius)
                
                // Left node (1 - white with outline)
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: nodeRadius * 2, height: nodeRadius * 2)
                    Circle()
                        .stroke(Color.black, lineWidth: 2)
                        .frame(width: nodeRadius * 2, height: nodeRadius * 2)
                    Text("1")
                        .foregroundColor(.black)
                        .font(.system(size: nodeRadius * 1.2, weight: .bold))
                }
                .position(x: centerX - outerRadius, y: centerY)
                
                // Center node (4 - white with outline)
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: nodeRadius * 2, height: nodeRadius * 2)
                    Circle()
                        .stroke(Color.black, lineWidth: 2)
                        .frame(width: nodeRadius * 2, height: nodeRadius * 2)
                    Text("4")
                        .foregroundColor(.black)
                        .font(.system(size: nodeRadius * 1.2, weight: .bold))
                }
                .position(x: centerX, y: centerY)
            }
        }
    }
}
