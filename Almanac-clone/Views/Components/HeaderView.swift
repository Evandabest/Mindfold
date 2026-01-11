//
//  HeaderView.swift
//  Almanac-clone
//
//  Created by Evan Haque on 1/9/26.
//

import SwiftUI

struct HeaderView: View {
    let crownCount: Int
    
    var body: some View {
        HStack {
            // Crown icon with count
            HStack(spacing: 4) {
                Image(systemName: "crown.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 20))
                Text("\(crownCount)")
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .medium))
            }
            
            Spacer()
            
            // Title
            Text("The Almanac")
                .foregroundColor(.white)
                .font(.system(size: 24, weight: .medium, design: .serif))
                .italic()
            
            Spacer()
            
            // Balance the header
            HStack(spacing: 4) {
                Image(systemName: "crown.fill")
                    .foregroundColor(.clear)
                    .font(.system(size: 20))
                Text("\(crownCount)")
                    .foregroundColor(.clear)
                    .font(.system(size: 20, weight: .medium))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 20)
    }
}

