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
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        // Top left: Gray with filled black circle
                        ZStack {
                            Rectangle()
                                .fill(Color(white: 0.6))
                            Rectangle()
                                .stroke(Color.black, lineWidth: 2)
                            Circle()
                                .fill(Color.black)
                                .frame(width: geo.size.width * 0.3, height: geo.size.width * 0.3)
                        }
                        .frame(width: geo.size.width * 0.5, height: geo.size.height * 0.5)
                        
                        // Top right: White/empty
                        ZStack {
                            Rectangle()
                                .fill(Color.white)
                            Rectangle()
                                .stroke(Color.black, lineWidth: 2)
                        }
                        .frame(width: geo.size.width * 0.5, height: geo.size.height * 0.5)
                    }
                    
                    HStack(spacing: 0) {
                        // Bottom left: White/empty
                        ZStack {
                            Rectangle()
                                .fill(Color.white)
                            Rectangle()
                                .stroke(Color.black, lineWidth: 2)
                        }
                        .frame(width: geo.size.width * 0.5, height: geo.size.height * 0.5)
                        
                        // Bottom right: Gray with white circle outline
                        ZStack {
                            Rectangle()
                                .fill(Color(white: 0.6))
                            Rectangle()
                                .stroke(Color.black, lineWidth: 2)
                            Circle()
                                .stroke(Color.black, lineWidth: 2)
                                .background(Circle().fill(Color.white))
                                .frame(width: geo.size.width * 0.3, height: geo.size.width * 0.3)
                        }
                        .frame(width: geo.size.width * 0.5, height: geo.size.height * 0.5)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

