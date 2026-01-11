//
//  NetwalkGameView.swift
//  Almanac-clone
//
//  Created by Evan Haque on 1/9/26.
//

import SwiftUI

struct NetwalkGameView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showTutorial = false
    
    let columns = 6
    let rows = 6
    
    var body: some View {
        ZStack {
            // Dark background
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Header
                HStack {
                    // Back button
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .medium))
                    }
                    
                    Spacer()
                    
                    // Game Title
                    Text("Netwalk")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .bold))
                    
                    Spacer()
                    
                    // Help and Settings icons
                    HStack(spacing: 16) {
                        Button(action: { showTutorial = true }) {
                            Image(systemName: "questionmark.bubble")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                        }
                        
                        Button(action: {}) {
                            Image(systemName: "gearshape")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 24)
                
                // Game Board
                VStack(spacing: 2) {
                    ForEach(0..<rows, id: \.self) { row in
                        HStack(spacing: 2) {
                            ForEach(0..<columns, id: \.self) { column in
                                NetwalkGameCell()
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity)
                
                Spacer()
            }
        }
        .sheet(isPresented: $showTutorial) {
            NetwalkTutorialView()
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// Game cell component for Netwalk
struct NetwalkGameCell: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color(white: 0.2))
            .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    NetwalkGameView()
}

