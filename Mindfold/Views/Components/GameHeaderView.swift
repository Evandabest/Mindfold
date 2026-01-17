//
//  GameHeaderView.swift
//  Mindfold
//
//  Created by Evan Haque on 1/17/26.
//

import SwiftUI

struct GameHeaderView: View {
    let gameTitle: String
    var onDismiss: () -> Void
    var onHelp: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // Back button
            Button(action: onDismiss) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .medium))
                    .frame(width: 44, height: 44)
            }
            
            Spacer()
            
            // Game Title (centered)
            Text(gameTitle)
                .foregroundColor(.white)
                .font(.system(size: 24, weight: .bold))
            
            Spacer()
            
            // Help button (same width as back button for perfect centering)
            Button(action: onHelp) {
                Image(systemName: "questionmark.circle")
                    .foregroundColor(.white)
                    .font(.system(size: 20))
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 24)
    }
}
