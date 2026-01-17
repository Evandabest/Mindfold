//
//  MastermindIcon.swift
//  Mindfold
//
//  Created by Evan Haque on 1/17/26.
//

import SwiftUI

struct MastermindIcon: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black, lineWidth: 2)
                )
            
            GeometryReader { geo in
                let cellSize = geo.size.width / 2.3
                let spacing = geo.size.width * 0.15
                
                VStack(spacing: spacing) {
                    HStack(spacing: spacing) {
                        // Top left - white square with black outline
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.black, lineWidth: 2)
                            .background(RoundedRectangle(cornerRadius: 4).fill(Color.white))
                            .frame(width: cellSize, height: cellSize)
                        
                        // Top right - filled black square
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.black)
                            .frame(width: cellSize, height: cellSize)
                    }
                    
                    HStack(spacing: spacing) {
                        // Bottom left - filled black square
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.black)
                            .frame(width: cellSize, height: cellSize)
                        
                        // Bottom right - white square with black outline
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.black, lineWidth: 2)
                            .background(RoundedRectangle(cornerRadius: 4).fill(Color.white))
                            .frame(width: cellSize, height: cellSize)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
            }
        }
    }
}
