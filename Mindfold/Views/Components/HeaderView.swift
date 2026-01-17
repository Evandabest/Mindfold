//
//  HeaderView.swift
//  Mindfold
//
//  Created by Evan Haque on 1/9/26.
//

import SwiftUI

struct HeaderView: View {
    var onSettingsTap: () -> Void = {}
    
    var body: some View {
        HStack {
            // Settings icon
            Button(action: onSettingsTap) {
                Image(systemName: "gearshape.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 22))
            }
            
            Spacer()
            
            // Title
            Text("Mindfold")
                .foregroundColor(.white)
                .font(.system(size: 24, weight: .medium, design: .serif))
                .italic()
            
            Spacer()
            
            // Balance the header (invisible settings icon)
            Image(systemName: "gearshape.fill")
                .foregroundColor(.clear)
                .font(.system(size: 22))
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 20)
    }
}

