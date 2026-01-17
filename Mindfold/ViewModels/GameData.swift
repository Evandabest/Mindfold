//
//  GameData.swift
//  Mindfold
//
//  Created by Evan Haque on 1/9/26.
//

import SwiftUI

class GameData: ObservableObject {
    // Sample game data
    let games: [Game] = [
        Game(title: "Shikaku", description: "Fill the board with chopsticks", color: Color(red: 1.0, green: 0.4, blue: 0.6), iconName: "square.grid.3x3"),
        Game(title: "Takuzu", description: "Harmonize the grid of elements", color: .green, iconName: "grid"),
        Game(title: "Star Battle", description: "Crown each region with single star", color: Color(red: 0.7, green: 0.5, blue: 1.0), iconName: "star.fill"),
        Game(title: "Netwalk", description: "Rotate pipes to complete the flow", color: .cyan, iconName: "pipe.and.arrow"),
        Game(title: "LITS", description: "Place tetrominoes in regions", color: .yellow, iconName: "square.grid.2x2"),
        Game(title: "Mastermind", description: "Find the secret color sequence", color: Color(red: 0.8, green: 0.6, blue: 0.4), iconName: "square.stack"),
        Game(title: "Flood Fill", description: "Paint the whole area one color", color: Color(red: 1.0, green: 0.4, blue: 0.6), iconName: "square.grid.3x3.fill"),
        Game(title: "Bridges", description: "Connect dots with bridges", color: Color(red: 0.5, green: 0.7, blue: 1.0), iconName: "circle.grid.cross"),
        Game(title: "Number Snake", description: "Draw path connecting numbers in order", color: Color(red: 0.7, green: 0.5, blue: 1.0), iconName: "number")
    ]
}

