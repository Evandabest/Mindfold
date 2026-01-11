//
//  OtherPuzzleIcon.swift
//  Almanac-clone
//
//  Created by Evan Haque on 1/9/26.
//

import SwiftUI

struct OtherPuzzleIcon: View {
    let iconName: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
            
            // Placeholder icon - will be replaced with custom icons later
            Image(systemName: iconName)
                .font(.system(size: 30))
                .foregroundColor(.gray)
        }
    }
}

