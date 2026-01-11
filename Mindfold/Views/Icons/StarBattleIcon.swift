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
                        // Top left - orange with black dot
                        ZStack {
                            Rectangle()
                                .fill(Color.orange)
                            Circle()
                                .fill(Color.black)
                                .frame(width: geo.size.width * 0.25, height: geo.size.width * 0.25)
                        }
                        .frame(width: geo.size.width * 0.5, height: geo.size.height * 0.5)
                        
                        // Top right - light purple with white star
                        ZStack {
                            Rectangle()
                                .fill(Color(red: 0.7, green: 0.5, blue: 1.0))
                            Image(systemName: "star.fill")
                                .foregroundColor(.white)
                                .font(.system(size: min(geo.size.width, geo.size.height) * 0.25))
                        }
                        .frame(width: geo.size.width * 0.5, height: geo.size.height * 0.5)
                    }
                    
                    HStack(spacing: 0) {
                        // Bottom left - orange and empty
                        Rectangle()
                            .fill(Color.orange)
                            .frame(width: geo.size.width * 0.5, height: geo.size.height * 0.5)
                        
                        // Bottom right - orange with black dot
                        ZStack {
                            Rectangle()
                                .fill(Color.orange)
                            Circle()
                                .fill(Color.black)
                                .frame(width: geo.size.width * 0.25, height: geo.size.width * 0.25)
                        }
                        .frame(width: geo.size.width * 0.5, height: geo.size.height * 0.5)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

