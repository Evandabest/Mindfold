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
        Game(title: "Shikaku", description: "Fill the grid into rectangles", color: Color(red: 1.0, green: 0.4, blue: 0.6), iconName: "square.grid.3x3"),
        Game(title: "Takuzu", description: "Fill grid with equal black and white cells", color: .green, iconName: "grid"),
        Game(title: "Star Battle", description: "Place stars in each region and row", color: Color(red: 0.7, green: 0.5, blue: 1.0), iconName: "star.fill"),
        Game(title: "Netwalk", description: "Rotate tiles to power the network", color: .cyan, iconName: "pipe.and.arrow"),
        Game(title: "LITS", description: "Place L-I-T-S tetrominoes in regions", color: .yellow, iconName: "square.grid.2x2"),
        Game(title: "Mastermind", description: "Crack the secret color code", color: Color(red: 0.8, green: 0.6, blue: 0.4), iconName: "square.stack"),
        Game(title: "Flood Fill", description: "Paint the board one color", color: Color(red: 1.0, green: 0.4, blue: 0.6), iconName: "square.grid.3x3.fill"),
        Game(title: "Bridges", description: "Connect islands with bridges", color: Color(red: 0.5, green: 0.7, blue: 1.0), iconName: "circle.grid.cross"),
        Game(title: "Number Snake", description: "Draw a snake through numbered cells", color: Color(red: 0.7, green: 0.5, blue: 1.0), iconName: "number")
    ]
}

