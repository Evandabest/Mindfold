//
//  ShikakuIcon.swift
//  Mindfold
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
                        // Top left - red with 5
                        ZStack {
                            Rectangle()
                                .fill(Color(red: 0.85, green: 0.35, blue: 0.35))
                            Rectangle()
                                .stroke(Color.black, lineWidth: 2)
                            Text("5")
                                .foregroundColor(.black)
                                .font(.system(size: 20, weight: .bold))
                        }
                        .frame(width: geo.size.width * 0.5, height: geo.size.height * 0.5)
                        
                        // Top right - blue with 6
                        ZStack {
                            Rectangle()
                                .fill(Color(red: 0.35, green: 0.55, blue: 0.75))
                            Rectangle()
                                .stroke(Color.black, lineWidth: 2)
                            Text("6")
                                .foregroundColor(.black)
                                .font(.system(size: 20, weight: .bold))
                        }
                        .frame(width: geo.size.width * 0.5, height: geo.size.height * 0.5)
                    }
                    
                    // Bottom - yellow with 7
                    ZStack {
                        Rectangle()
                            .fill(Color(red: 0.95, green: 0.85, blue: 0.4))
                        Rectangle()
                            .stroke(Color.black, lineWidth: 2)
                        Text("7")
                            .foregroundColor(.black)
                            .font(.system(size: 20, weight: .bold))
                    }
                    .frame(width: geo.size.width, height: geo.size.height * 0.5)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

