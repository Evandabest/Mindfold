//
//  NetwalkTutorialView.swift
//  Mindfold
//
//  Created by Evan Haque on 1/9/26.
//

import SwiftUI

struct NetwalkTutorialView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Dark background
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Header
                HStack {
                    // Close button (X)
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .medium))
                    }
                    
                    Spacer()
                    
                    // Title
                    Text("How to play")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .bold))
                    
                    Spacer()
                    
                    // Balance the header
                    Image(systemName: "xmark")
                        .foregroundColor(.clear)
                        .font(.system(size: 20, weight: .medium))
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 30)
                
                // Tutorial content
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Rule 1
                        VStack(alignment: .leading, spacing: 12) {
                            Text("• The goal of the puzzle is to rotate the segments in such a way, that it forms a single connected group of pipes")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                        }
                        
                        // Rule 2
                        VStack(alignment: .leading, spacing: 12) {
                            Text("• Closed loops are not allowed")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                        }
                        
                        // Rule 3
                        VStack(alignment: .leading, spacing: 12) {
                            Text("• There shouldn't be groups, isolated from the rest of the pipes")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                        }
                        
                        // Rule 4
                        VStack(alignment: .leading, spacing: 12) {
                            Text("• Loose ends are not allowed, because the water would flow out of the pipes")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                
                Spacer()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NetwalkTutorialView()
}

