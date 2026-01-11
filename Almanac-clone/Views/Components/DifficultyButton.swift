//
//  DifficultyButton.swift
//  Almanac-clone
//
//  Created by Evan Haque on 1/9/26.
//

import SwiftUI

struct DifficultyButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color(white: 0.25) : Color(white: 0.15))
                )
        }
    }
}

