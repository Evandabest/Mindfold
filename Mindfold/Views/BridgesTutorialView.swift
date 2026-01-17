//
//  BridgesTutorialView.swift
//  Mindfold
//
//  Created by Evan Haque on 1/15/26.
//

import SwiftUI

struct BridgesTutorialView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .medium))
                    }
                    Spacer()
                    Text("How to play")
                        .foregroundColor(.white)
                        .font(.system(size: 22, weight: .bold))
                    Spacer()
                    Image(systemName: "xmark")
                        .foregroundColor(.clear)
                        .font(.system(size: 20, weight: .medium))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        // Game description
                        Text("Connect islands with bridges")
                            .foregroundColor(.gray)
                            .font(.system(size: 16))
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        // Rule 1: Number meaning
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Rule 1: Island Numbers")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                            Text("Each number tells you how many bridges must connect to that island.")
                                .foregroundColor(.gray)
                                .font(.system(size: 15))
                            
                            bridgeIsland(number: "3", bridges: 3)
                                .frame(maxWidth: .infinity)
                        }
                        
                        // Rule 2: Bridge rules
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Rule 2: Bridge Rules")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                            Text("Bridges can only go horizontally or vertically")
                                .foregroundColor(.gray)
                                .font(.system(size: 15))
                            
                            HStack(spacing: 30) {
                                VStack(spacing: 8) {
                                    bridgeRuleExample1(valid: true)
                                    Text("✓ Horizontal/vertical")
                                        .foregroundColor(.green)
                                        .font(.system(size: 13))
                                }
                                
                                VStack(spacing: 8) {
                                    bridgeRuleExample1(valid: false)
                                    Text("✗ No diagonals")
                                        .foregroundColor(.red)
                                        .font(.system(size: 13))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            
                            Text("Maximum 2 bridges between any two islands")
                                .foregroundColor(.gray)
                                .font(.system(size: 15))
                                .padding(.top, 8)
                            
                            HStack(spacing: 30) {
                                VStack(spacing: 8) {
                                    bridgeRuleExample2(bridges: 2)
                                    Text("✓ Two bridges OK")
                                        .foregroundColor(.green)
                                        .font(.system(size: 13))
                                }
                                
                                VStack(spacing: 8) {
                                    bridgeRuleExample2(bridges: 3)
                                    Text("✗ Three is too many")
                                        .foregroundColor(.red)
                                        .font(.system(size: 13))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            
                            Text("Bridges cannot cross each other")
                                .foregroundColor(.gray)
                                .font(.system(size: 15))
                                .padding(.top, 8)
                            
                            HStack(spacing: 30) {
                                VStack(spacing: 8) {
                                    bridgeRuleExample3(crossing: false)
                                    Text("✓ No crossing")
                                        .foregroundColor(.green)
                                        .font(.system(size: 13))
                                }
                                
                                VStack(spacing: 8) {
                                    bridgeRuleExample3(crossing: true)
                                    Text("✗ Bridges cross")
                                        .foregroundColor(.red)
                                        .font(.system(size: 13))
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        // Rule 3: Connected graph
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Rule 3: All Connected")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                            Text("All islands must be connected into one network.")
                                .foregroundColor(.gray)
                                .font(.system(size: 15))
                        }
                        
                        // Example
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Example")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                            
                            bridgeExample()
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
                
                Button(action: { dismiss() }) {
                    Text("Got it!")
                        .foregroundColor(.black)
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private func bridgeIsland(number: String, bridges: Int) -> some View {
        ZStack {
            // Lines representing bridges
            ForEach(0..<bridges, id: \.self) { i in
                let angle = Double(i) * (360.0 / Double(bridges))
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 40, height: 3)
                    .rotationEffect(.degrees(angle))
            }
            
            // Island
            Circle()
                .fill(Color(white: 0.3))
                .frame(width: 40, height: 40)
            Circle()
                .stroke(Color.white, lineWidth: 2)
                .frame(width: 40, height: 40)
            Text(number)
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .bold))
        }
    }
    
    private func bridgeExample() -> some View {
        ZStack {
            // Bridges (lines)
            Path { path in
                path.move(to: CGPoint(x: 60, y: 60))
                path.addLine(to: CGPoint(x: 140, y: 60))
            }
            .stroke(Color.white, lineWidth: 3)
            
            Path { path in
                path.move(to: CGPoint(x: 140, y: 60))
                path.addLine(to: CGPoint(x: 140, y: 140))
            }
            .stroke(Color.white, lineWidth: 3)
            
            // Islands
            island(x: 60, y: 60, number: "1")
            island(x: 140, y: 60, number: "2")
            island(x: 140, y: 140, number: "1")
        }
        .frame(width: 200, height: 200)
    }
    
    private func island(x: CGFloat, y: CGFloat, number: String) -> some View {
        ZStack {
            Circle()
                .fill(Color(white: 0.3))
                .frame(width: 35, height: 35)
            Circle()
                .stroke(Color.white, lineWidth: 2)
                .frame(width: 35, height: 35)
            Text(number)
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .bold))
        }
        .position(x: x, y: y)
    }
    
    // Rule 2 examples
    private func bridgeRuleExample1(valid: Bool) -> some View {
        ZStack {
            if valid {
                // Horizontal bridge
                Path { path in
                    path.move(to: CGPoint(x: 30, y: 50))
                    path.addLine(to: CGPoint(x: 70, y: 50))
                }
                .stroke(Color.white, lineWidth: 2)
                
                miniIsland(x: 30, y: 50, number: "1")
                miniIsland(x: 70, y: 50, number: "1")
            } else {
                // Diagonal bridge (invalid)
                Path { path in
                    path.move(to: CGPoint(x: 30, y: 30))
                    path.addLine(to: CGPoint(x: 70, y: 70))
                }
                .stroke(Color.red, lineWidth: 2)
                
                miniIsland(x: 30, y: 30, number: "1")
                miniIsland(x: 70, y: 70, number: "1")
            }
        }
        .frame(width: 100, height: 100)
    }
    
    private func bridgeRuleExample2(bridges: Int) -> some View {
        ZStack {
            // Draw bridges
            if bridges >= 1 {
                Path { path in
                    path.move(to: CGPoint(x: 30, y: 48))
                    path.addLine(to: CGPoint(x: 70, y: 48))
                }
                .stroke(bridges > 2 ? Color.red : Color.white, lineWidth: 2)
            }
            if bridges >= 2 {
                Path { path in
                    path.move(to: CGPoint(x: 30, y: 52))
                    path.addLine(to: CGPoint(x: 70, y: 52))
                }
                .stroke(bridges > 2 ? Color.red : Color.white, lineWidth: 2)
            }
            if bridges >= 3 {
                Path { path in
                    path.move(to: CGPoint(x: 30, y: 56))
                    path.addLine(to: CGPoint(x: 70, y: 56))
                }
                .stroke(Color.red, lineWidth: 2)
            }
            
            miniIsland(x: 30, y: 50, number: "\(bridges)")
            miniIsland(x: 70, y: 50, number: "\(bridges)")
        }
        .frame(width: 100, height: 100)
    }
    
    private func bridgeRuleExample3(crossing: Bool) -> some View {
        ZStack {
            if crossing {
                // Crossing bridges (invalid)
                Path { path in
                    path.move(to: CGPoint(x: 30, y: 50))
                    path.addLine(to: CGPoint(x: 70, y: 50))
                }
                .stroke(Color.red, lineWidth: 2)
                
                Path { path in
                    path.move(to: CGPoint(x: 50, y: 30))
                    path.addLine(to: CGPoint(x: 50, y: 70))
                }
                .stroke(Color.red, lineWidth: 2)
                
                miniIsland(x: 30, y: 50, number: "1")
                miniIsland(x: 70, y: 50, number: "1")
                miniIsland(x: 50, y: 30, number: "1")
                miniIsland(x: 50, y: 70, number: "1")
            } else {
                // Non-crossing bridges (valid)
                Path { path in
                    path.move(to: CGPoint(x: 30, y: 35))
                    path.addLine(to: CGPoint(x: 70, y: 35))
                }
                .stroke(Color.white, lineWidth: 2)
                
                Path { path in
                    path.move(to: CGPoint(x: 50, y: 55))
                    path.addLine(to: CGPoint(x: 50, y: 80))
                }
                .stroke(Color.white, lineWidth: 2)
                
                miniIsland(x: 30, y: 35, number: "1")
                miniIsland(x: 70, y: 35, number: "1")
                miniIsland(x: 50, y: 55, number: "1")
                miniIsland(x: 50, y: 80, number: "1")
            }
        }
        .frame(width: 100, height: 100)
    }
    
    private func miniIsland(x: CGFloat, y: CGFloat, number: String) -> some View {
        ZStack {
            Circle()
                .fill(Color(white: 0.3))
                .frame(width: 20, height: 20)
            Circle()
                .stroke(Color.white, lineWidth: 1.5)
                .frame(width: 20, height: 20)
            Text(number)
                .foregroundColor(.white)
                .font(.system(size: 10, weight: .bold))
        }
        .position(x: x, y: y)
    }
}
