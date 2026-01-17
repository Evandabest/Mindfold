//
//  StarBattleIcon.swift
//  Mindfold
//
//  Created by Evan Haque on 1/9/26.
//

import SwiftUI

struct StarBattleIcon: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(white: 0.2))
            
            GeometryReader { geo in
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        // Top left - Green (empty)
                        ZStack {
                            Rectangle()
                                .fill(Color(red: 0.5, green: 0.85, blue: 0.5))
                            Rectangle()
                                .stroke(Color.black, lineWidth: 2)
                        }
                        .frame(width: geo.size.width * 0.5, height: geo.size.height * 0.5)
                        
                        // Top right - Blue with yellow star
                        ZStack {
                            Rectangle()
                                .fill(Color(red: 0.35, green: 0.5, blue: 0.75))
                            Rectangle()
                                .stroke(Color.black, lineWidth: 2)
                            Image(systemName: "star.fill")
                                .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.3))
                                .font(.system(size: min(geo.size.width, geo.size.height) * 0.3))
                        }
                        .frame(width: geo.size.width * 0.5, height: geo.size.height * 0.5)
                    }
                    
                    HStack(spacing: 0) {
                        // Bottom left - Red (empty)
                        ZStack {
                            Rectangle()
                                .fill(Color(red: 0.85, green: 0.4, blue: 0.4))
                            Rectangle()
                                .stroke(Color.black, lineWidth: 2)
                        }
                        .frame(width: geo.size.width * 0.5, height: geo.size.height * 0.5)
                        
                        // Bottom right - Purple (empty)
                        ZStack {
                            Rectangle()
                                .fill(Color(red: 0.6, green: 0.5, blue: 0.85))
                            Rectangle()
                                .stroke(Color.black, lineWidth: 2)
                        }
                        .frame(width: geo.size.width * 0.5, height: geo.size.height * 0.5)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

