//
//  DefaultIcon.swift
//  Mindfold
//
//  Created by Evan Haque on 1/9/26.
//

import SwiftUI

struct DefaultIcon: View {
    let iconName: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(white: 0.2))
            
            Image(systemName: iconName)
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

