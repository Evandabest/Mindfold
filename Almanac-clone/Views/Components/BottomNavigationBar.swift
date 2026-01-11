//
//  BottomNavigationBar.swift
//  Almanac-clone
//
//  Created by Evan Haque on 1/9/26.
//

import SwiftUI

struct BottomNavigationBar: View {
    @State private var selectedTab: Int = 1 // Calendar is selected
    
    var body: some View {
        HStack {
            Spacer()
            
            // Profile
            Button(action: { selectedTab = 0 }) {
                Image(systemName: "person.fill")
                    .font(.system(size: 24))
                    .foregroundColor(selectedTab == 0 ? .white : .gray)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(selectedTab == 0 ? Color(white: 0.3) : Color.clear)
                    )
            }
            
            Spacer()
            
            // Calendar (selected)
            Button(action: { selectedTab = 1 }) {
                Image(systemName: "calendar")
                    .font(.system(size: 24))
                    .foregroundColor(selectedTab == 1 ? .white : .gray)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(selectedTab == 1 ? Color(white: 0.3) : Color.clear)
                    )
            }
            
            Spacer()
            
            // Settings
            Button(action: { selectedTab = 2 }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 24))
                    .foregroundColor(selectedTab == 2 ? .white : .gray)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(selectedTab == 2 ? Color(white: 0.3) : Color.clear)
                    )
            }
            
            Spacer()
        }
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color(white: 0.15))
                .frame(height: 60)
        )
        .padding(.horizontal, 20)
    }
}

