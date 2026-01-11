//
//  OtherPuzzleCard.swift
//  Almanac-clone
//
//  Created by Evan Haque on 1/9/26.
//

import SwiftUI

struct OtherPuzzleCard: View {
    let title: String
    let color: Color
    let icon: AnyView
    
    init(title: String, color: Color, icon: AnyView) {
        self.title = title
        self.color = color
        self.icon = icon
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon
            icon
                .frame(width: 60, height: 60)
            
            // Title
            Text(title)
                .foregroundColor(color)
                .font(.system(size: 16, weight: .semibold))
            
            // Crown count (placeholder for now)
            HStack(spacing: 4) {
                Image(systemName: "crown.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 12))
                Text("0")
                    .foregroundColor(.white)
                    .font(.system(size: 12))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(white: 0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

