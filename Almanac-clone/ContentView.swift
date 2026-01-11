//
//  ContentView.swift
//  Almanac-clone
//
//  Created by Evan Haque on 1/9/26.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedDifficulty: String = "Standard"
    @StateObject private var gameData = GameData()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Dark background
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HeaderView(crownCount: 0)
                    
                    // Difficulty selector
                    HStack(spacing: 0) {
                        DifficultyButton(title: "Standard", isSelected: selectedDifficulty == "Standard") {
                            selectedDifficulty = "Standard"
                        }
                        
                        DifficultyButton(title: "Hard", isSelected: selectedDifficulty == "Hard") {
                            selectedDifficulty = "Hard"
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    
                    // Game list
                    ScrollView {
                        VStack(spacing: 24) {
                            // Main games
                            VStack(spacing: 16) {
                                ForEach(gameData.games) { game in
                                    NavigationLink(destination: destinationView(for: game)) {
                                        GameCard(
                                            title: game.title,
                                            description: game.description,
                                            color: game.color,
                                            icon: AnyView(GameIconView(game: game))
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            
                            // Other puzzles section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Other puzzles")
                                    .foregroundColor(.white)
                                    .font(.system(size: 20, weight: .semibold))
                                    .padding(.horizontal, 20)
                                
                                // Grid layout for other puzzles
                                LazyVGrid(columns: [
                                    GridItem(.flexible(), spacing: 12),
                                    GridItem(.flexible(), spacing: 12)
                                ], spacing: 12) {
                                    ForEach(gameData.otherPuzzles) { puzzle in
                                        OtherPuzzleCard(
                                            title: puzzle.title,
                                            color: puzzle.color,
                                            icon: AnyView(OtherPuzzleIcon(iconName: puzzle.iconName))
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            .padding(.bottom, 20)
                        }
                        .padding(.top, 0)
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
    
    @ViewBuilder
    private func destinationView(for game: Game) -> some View {
        switch game.title {
        case "Shikaku":
            ShikakuGameView()
        case "Takuzu":
            TakuzuGameView()
        case "Star Battle":
            StarBattleGameView()
        case "Netwalk":
            NetwalkGameView()
        default:
            // Placeholder for other games
            Text("\(game.title) game coming soon")
                .foregroundColor(.white)
        }
    }
}

#Preview {
    ContentView()
}
