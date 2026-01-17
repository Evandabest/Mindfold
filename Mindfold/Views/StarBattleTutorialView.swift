//
//  StarBattleTutorialView.swift
//  Mindfold
//
//  Created by Evan Haque on 1/9/26.
//

import SwiftUI

struct StarBattleTutorialView: View {
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
                            Text("• Each Row and Column has to have only one Star")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                        }
                        
                        // Rule 2
                        VStack(alignment: .leading, spacing: 12) {
                            Text("• Stars can't touch - not even diagonally:")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                            
                            // Examples
                            HStack(spacing: 30) {
                                // Correct example
                                VStack(spacing: 8) {
                                    // 3x3 grid with kings
                                    VStack(spacing: 2) {
                                        ForEach(0..<3, id: \.self) { row in
                                            HStack(spacing: 2) {
                                                ForEach(0..<3, id: \.self) { col in
                                                    ZStack {
                                                        RoundedRectangle(cornerRadius: 4)
                                                            .stroke(Color.white, lineWidth: 1)
                                                            .frame(width: 40, height: 40)
                                                        
                                                        if (row == 0 && col == 0) || (row == 2 && col == 2) {
                                                            Image(systemName: "star.fill")
                                                                .foregroundColor(.white)
                                                                .font(.system(size: 20))
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                    Text("Correct")
                                        .foregroundColor(.white)
                                        .font(.system(size: 14))
                                }
                                
                                // Incorrect example
                                VStack(spacing: 8) {
                                    // 3x3 grid with kings (diagonal touching)
                                    VStack(spacing: 2) {
                                        ForEach(0..<3, id: \.self) { row in
                                            HStack(spacing: 2) {
                                                ForEach(0..<3, id: \.self) { col in
                                                    ZStack {
                                                        RoundedRectangle(cornerRadius: 4)
                                                            .fill(Color(red: 1.0, green: 0.6, blue: 0.6))
                                                            .frame(width: 40, height: 40)
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: 4)
                                                                    .stroke(Color.white, lineWidth: 1)
                                                            )
                                                        
                                                        if (row == 0 && col == 0) || (row == 1 && col == 1) {
                                                            Image(systemName: "star.fill")
                                                                .foregroundColor(.white)
                                                                .font(.system(size: 20))
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                    Text("Incorrect")
                                        .foregroundColor(.white)
                                        .font(.system(size: 14))
                                }
                            }
                            .padding(.leading, 20)
                        }
                        
                        // Rule 3
                        VStack(alignment: .leading, spacing: 12) {
                            Text("• Each region marked by color, has to have a Star inside.")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                        }
                        
                        // Rule 4
                        VStack(alignment: .leading, spacing: 12) {
                            Text("• No guessing is needed, only deduction!")
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
    StarBattleTutorialView()
}

