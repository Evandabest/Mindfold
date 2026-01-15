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
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Title
                    Text("How to play")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 8)
                    
                    // Rule 1: Exact connections
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 4) {
                            Text("•")
                                .foregroundColor(.white)
                            Text("Each dot must have the exact number of connections represented by a number.")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                        }
                        
                        // Example diagram for connections
                        HStack(spacing: 40) {
                            VStack(spacing: 8) {
                                connectionExample(number: 1, connections: 0)
                                Text("Not enough")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14))
                            }
                            
                            VStack(spacing: 8) {
                                connectionExample(number: 3, connections: 2)
                                Text("Not enough")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14))
                            }
                            
                            VStack(spacing: 8) {
                                connectionExample(number: 2, connections: 1)
                                Text("Not enough")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        
                        // Correct examples
                        HStack(spacing: 40) {
                            VStack(spacing: 8) {
                                connectionExample(number: 1, connections: 2, incorrect: true)
                                Text("Too many")
                                    .foregroundColor(.red)
                                    .font(.system(size: 14))
                            }
                            
                            VStack(spacing: 8) {
                                connectionExample(number: 3, connections: 3)
                                Text("Exact!")
                                    .foregroundColor(.green)
                                    .font(.system(size: 14))
                            }
                            
                            VStack(spacing: 8) {
                                connectionExample(number: 2, connections: 2)
                                Text("Not enough")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        
                        HStack(spacing: 40) {
                            VStack(spacing: 8) {
                                allCorrectExample()
                                Text("Exact!")
                                    .foregroundColor(.green)
                                    .font(.system(size: 14))
                            }
                            
                            VStack(spacing: 8) {
                                allCorrectExample()
                                Text("Exact!")
                                    .foregroundColor(.green)
                                    .font(.system(size: 14))
                            }
                            
                            VStack(spacing: 8) {
                                allCorrectExample()
                                Text("Exact!")
                                    .foregroundColor(.green)
                                    .font(.system(size: 14))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal)
                    
                    // Rule 2: Single or double connections
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 4) {
                            Text("•")
                                .foregroundColor(.white)
                            Text("Build single or double connections between dots.")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                        }
                        
                        VStack(spacing: 20) {
                            HStack(spacing: 20) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 30, height: 30)
                                    Text("8")
                                        .foregroundColor(.black)
                                        .font(.system(size: 14, weight: .bold))
                                }
                                
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(width: 60, height: 3)
                                
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 30, height: 30)
                                    Text("8")
                                        .foregroundColor(.black)
                                        .font(.system(size: 14, weight: .bold))
                                }
                            }
                            Text("Possible")
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                            
                            HStack(spacing: 20) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 30, height: 30)
                                    Text("8")
                                        .foregroundColor(.black)
                                        .font(.system(size: 14, weight: .bold))
                                }
                                
                                ZStack {
                                    Rectangle()
                                        .fill(Color.white)
                                        .frame(width: 60, height: 3)
                                        .offset(y: -4)
                                    Rectangle()
                                        .fill(Color.white)
                                        .frame(width: 60, height: 3)
                                        .offset(y: 4)
                                }
                                
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 30, height: 30)
                                    Text("8")
                                        .foregroundColor(.black)
                                        .font(.system(size: 14, weight: .bold))
                                }
                            }
                            Text("Possible")
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                            
                            HStack(spacing: 20) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 30, height: 30)
                                    Text("8")
                                        .foregroundColor(.black)
                                        .font(.system(size: 14, weight: .bold))
                                }
                                
                                ZStack {
                                    Rectangle()
                                        .fill(Color.white)
                                        .frame(width: 60, height: 3)
                                        .offset(y: -6)
                                    Rectangle()
                                        .fill(Color.white)
                                        .frame(width: 60, height: 3)
                                    Rectangle()
                                        .fill(Color.white)
                                        .frame(width: 60, height: 3)
                                        .offset(y: 6)
                                }
                                
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 30, height: 30)
                                    Text("8")
                                        .foregroundColor(.black)
                                        .font(.system(size: 14, weight: .bold))
                                }
                            }
                            Text("Impossible")
                                .foregroundColor(.red)
                                .font(.system(size: 14))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal)
                    
                    // Rule 3: No crossing
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 4) {
                            Text("•")
                                .foregroundColor(.white)
                            Text("Crossing connections are not allowed.")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                        }
                        
                        HStack(spacing: 40) {
                            VStack(spacing: 8) {
                                crossingExample(crossing: true)
                                Text("Impossible")
                                    .foregroundColor(.red)
                                    .font(.system(size: 14))
                            }
                            
                            VStack(spacing: 8) {
                                crossingExample(crossing: false)
                                Text("Correct")
                                    .foregroundColor(.green)
                                    .font(.system(size: 14))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 30)
                }
            }
        }
    }
    
    // Helper views for examples
    @ViewBuilder
    private func connectionExample(number: Int, connections: Int, incorrect: Bool = false) -> some View {
        ZStack {
            // Grid background
            Rectangle()
                .fill(Color(white: 0.1))
                .frame(width: 80, height: 40)
            
            // Node
            ZStack {
                Circle()
                    .fill(incorrect ? Color.red.opacity(0.7) : Color.white)
                    .frame(width: 30, height: 30)
                Text("\(number)")
                    .foregroundColor(incorrect ? .white : .black)
                    .font(.system(size: 14, weight: .bold))
            }
            
            // Connections (simple representation)
            if connections > 0 {
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 25, height: 3)
                    .offset(x: -27)
            }
        }
    }
    
    @ViewBuilder
    private func allCorrectExample() -> some View {
        ZStack {
            Rectangle()
                .fill(Color(white: 0.1))
                .frame(width: 80, height: 40)
            
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                    Text("1")
                        .foregroundColor(.black)
                        .font(.system(size: 10, weight: .bold))
                }
                
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 20, height: 2)
                
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                    Text("3")
                        .foregroundColor(.black)
                        .font(.system(size: 10, weight: .bold))
                }
                
                ZStack {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 20, height: 2)
                        .offset(y: -2)
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 20, height: 2)
                        .offset(y: 2)
                }
                
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                    Text("2")
                        .foregroundColor(.black)
                        .font(.system(size: 10, weight: .bold))
                }
            }
        }
    }
    
    @ViewBuilder
    private func crossingExample(crossing: Bool) -> some View {
        ZStack {
            Rectangle()
                .fill(Color(white: 0.1))
                .frame(width: 120, height: 120)
            
            if crossing {
                // Incorrect: crossing connections
                VStack(spacing: 40) {
                    HStack(spacing: 40) {
                        Circle().fill(Color.white).frame(width: 20, height: 20)
                        Circle().fill(Color.white).frame(width: 20, height: 20)
                    }
                    HStack(spacing: 40) {
                        Circle().fill(Color.white).frame(width: 20, height: 20)
                        Circle().fill(Color.white).frame(width: 20, height: 20)
                    }
                }
                
                // Horizontal line
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 40, height: 2)
                    .offset(y: -20)
                
                // Vertical line (crossing)
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 2, height: 40)
                    .offset(x: -20)
            } else {
                // Correct: no crossing
                VStack(spacing: 40) {
                    HStack(spacing: 40) {
                        Circle().fill(Color.white).frame(width: 20, height: 20)
                        Circle().fill(Color.white).frame(width: 20, height: 20)
                    }
                    HStack(spacing: 40) {
                        Circle().fill(Color.white).frame(width: 20, height: 20)
                        Circle().fill(Color.white).frame(width: 20, height: 20)
                    }
                }
                
                // Top horizontal line
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 40, height: 2)
                    .offset(y: -20)
                
                // Right vertical line (not crossing)
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 2, height: 40)
                    .offset(x: 20)
            }
        }
    }
}

