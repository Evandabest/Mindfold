//
//  ShikakuTutorialView.swift
//  Mindfold
//
//  Created by Evan Haque on 1/9/26.
//

import SwiftUI

struct ShikakuTutorialView: View {
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
                            Text("• Fill the board with rectangles. (square is also a rectangle)")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                        }
                        
                        // Rule 2
                        VStack(alignment: .leading, spacing: 12) {
                            Text("• Each rectangle has to cover an amount of tiles indicated by the number.")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                            
                            // Example box with "4"
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(white: 0.3))
                                    .frame(width: 60, height: 60)
                                
                                Text("4")
                                    .foregroundColor(.white)
                                    .font(.system(size: 24, weight: .bold))
                            }
                            .padding(.leading, 20)
                        }
                        
                        // Rule 3
                        VStack(alignment: .leading, spacing: 12) {
                            Text("• Rectangles cannot overlap.")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                        }
                        
                        // Rule 4
                        VStack(alignment: .leading, spacing: 12) {
                            Text("• There shouldn't be any empty spaces.")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                        }
                        
                        // Rule 5
                        VStack(alignment: .leading, spacing: 12) {
                            Text("• Rectangles can have any dimensions as long as they cover the correct amount of tiles.")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                            
                            // Example boxes with "6" in different shapes
                            VStack(spacing: 12) {
                                // Horizontal rectangle
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(white: 0.3))
                                        .frame(width: 120, height: 40)
                                    
                                    Text("6")
                                        .foregroundColor(.white)
                                        .font(.system(size: 24, weight: .bold))
                                }
                                
                                // Square
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(white: 0.3))
                                        .frame(width: 60, height: 60)
                                    
                                    Text("6")
                                        .foregroundColor(.white)
                                        .font(.system(size: 24, weight: .bold))
                                }
                            }
                            .padding(.leading, 20)
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
    ShikakuTutorialView()
}

