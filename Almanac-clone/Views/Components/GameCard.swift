//
//  GameCard.swift
//  Almanac-clone
//
//  Created by Evan Haque on 1/9/26.
//

import SwiftUI

struct GameCard: View {
    let title: String
    let description: String
    let color: Color
    let icon: AnyView
    
    init(title: String, description: String, color: Color, icon: AnyView) {
        self.title = title
        self.description = description
        self.color = color
        self.icon = icon
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Game icon
            icon
                .frame(width: 80, height: 80)
            
            // Game info
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .foregroundColor(color)
                    .font(.system(size: 20, weight: .semibold))
                
                Text(description)
                    .foregroundColor(.white)
                    .font(.system(size: 14))
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(white: 0.15))
        )
    }
}

