//
//  ShikakuIcon.swift
//  Almanac-clone
//
//  Created by Evan Haque on 1/9/26.
//

import SwiftUI

struct ShikakuIcon: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(white: 0.2))
            
            GeometryReader { geo in
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        // Top left - red with 2
                        ZStack {
                            Rectangle()
                                .fill(Color.red)
                            Text("2")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .bold))
                        }
                        .frame(width: geo.size.width * 0.5, height: geo.size.height * 0.5)
                        
                        // Top right - orange with 4
                        ZStack {
                            Rectangle()
                                .fill(Color.orange)
                            Text("4")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .bold))
                        }
                        .frame(width: geo.size.width * 0.5, height: geo.size.height * 0.5)
                    }
                    
                    // Bottom - blue with 3
                    ZStack {
                        Rectangle()
                            .fill(Color.blue)
                        Text("3")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .bold))
                    }
                    .frame(width: geo.size.width, height: geo.size.height * 0.5)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

