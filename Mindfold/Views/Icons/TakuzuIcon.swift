//
//  TakuzuIcon.swift
//  Mindfold
//
//  Created by Evan Haque on 1/9/26.
//

import SwiftUI

struct TakuzuIcon: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(white: 0.2))
            
            GeometryReader { geo in
                VStack(spacing: 2) {
                    HStack(spacing: 2) {
                        // Dark gray with black circle
                        ZStack {
                            Rectangle()
                                .fill(Color(white: 0.3))
                            Circle()
                                .fill(Color.black)
                                .frame(width: geo.size.width * 0.25, height: geo.size.width * 0.25)
                        }
                        
                        // White
                        Rectangle()
                            .fill(Color.white)
                    }
                    
                    HStack(spacing: 2) {
                        // White
                        Rectangle()
                            .fill(Color.white)
                        
                        // Light green with dark green square outline
                        ZStack {
                            Rectangle()
                                .fill(Color.green.opacity(0.5))
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.green, lineWidth: 2)
                                .frame(width: geo.size.width * 0.3, height: geo.size.width * 0.3)
                        }
                    }
                }
            }
            .padding(4)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

