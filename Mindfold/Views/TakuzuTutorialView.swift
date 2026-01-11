//
//  TakuzuTutorialView.swift
//  Mindfold
//
//  Created by Evan Haque on 1/9/26.
//

import SwiftUI

struct TakuzuTutorialView: View {
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
                            Text("• No more than 2 of the same symbol may be placed next to each other:")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                            
                            // Examples
                            VStack(alignment: .leading, spacing: 12) {
                                // Correct example
                                HStack(spacing: 12) {
                                    HStack(spacing: 2) {
                                        // Two squares with circles
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(Color(red: 0.5, green: 0.7, blue: 1.0))
                                                .frame(width: 50, height: 50)
                                            Circle()
                                                .fill(Color(red: 0.1, green: 0.2, blue: 0.5))
                                                .frame(width: 30, height: 30)
                                        }
                                        
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(Color(red: 0.5, green: 0.7, blue: 1.0))
                                                .frame(width: 50, height: 50)
                                            Circle()
                                                .fill(Color(red: 0.1, green: 0.2, blue: 0.5))
                                                .frame(width: 30, height: 30)
                                        }
                                    }
                                    
                                    Text("• Correct")
                                        .foregroundColor(.white)
                                        .font(.system(size: 14))
                                }
                                
                                // Incorrect example
                                HStack(spacing: 12) {
                                    HStack(spacing: 2) {
                                        // Three squares with circles (highlighted with red border)
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(Color(red: 0.5, green: 0.7, blue: 1.0))
                                                .frame(width: 50, height: 50)
                                            Circle()
                                                .fill(Color(red: 0.1, green: 0.2, blue: 0.5))
                                                .frame(width: 30, height: 30)
                                        }
                                        
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(Color(red: 0.5, green: 0.7, blue: 1.0))
                                                .frame(width: 50, height: 50)
                                            Circle()
                                                .fill(Color(red: 0.1, green: 0.2, blue: 0.5))
                                                .frame(width: 30, height: 30)
                                        }
                                        
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(Color(red: 0.5, green: 0.7, blue: 1.0))
                                                .frame(width: 50, height: 50)
                                            Circle()
                                                .fill(Color(red: 0.1, green: 0.2, blue: 0.5))
                                                .frame(width: 30, height: 30)
                                        }
                                    }
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Color.red, lineWidth: 2)
                                            .frame(width: 158, height: 50)
                                    )
                                    
                                    Text("• Incorrect")
                                        .foregroundColor(.white)
                                        .font(.system(size: 14))
                                }
                            }
                            .padding(.leading, 20)
                        }
                        
                        // Rule 2
                        VStack(alignment: .leading, spacing: 12) {
                            Text("• There must be equal number of symbols in each row and column.")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                        }
                        
                        // Rule 3
                        VStack(alignment: .leading, spacing: 12) {
                            Text("• = sign means both adjacent cells has to have the same symbol.")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                        }
                        
                        // Rule 4
                        VStack(alignment: .leading, spacing: 12) {
                            Text("• x sign means both adjacent cells have to have different symbol.")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                        }
                        
                        // Rule 5
                        VStack(alignment: .leading, spacing: 12) {
                            Text("• There is no guessing needed, only deduction.")
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
    TakuzuTutorialView()
}

