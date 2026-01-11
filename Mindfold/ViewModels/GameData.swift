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
        Game(title: "Netwalk", description: "Rotate pipes to complete the flow", color: .cyan, iconName: "pipe.and.arrow")
    ]
    
    // Other puzzles data
    let otherPuzzles: [OtherPuzzle] = [
        OtherPuzzle(title: "Snap", color: Color(red: 0.7, green: 0.5, blue: 1.0), iconName: "s.square"),
        OtherPuzzle(title: "Tower", color: Color(red: 0.8, green: 0.6, blue: 0.4), iconName: "square.stack"),
        OtherPuzzle(title: "LITS", color: .yellow, iconName: "square.grid.2x2"),
        OtherPuzzle(title: "Plates", color: Color(red: 0.5, green: 0.8, blue: 0.5), iconName: "circle.grid.2x2"),
        OtherPuzzle(title: "Atoms", color: Color(red: 0.5, green: 0.7, blue: 1.0), iconName: "atom"),
        OtherPuzzle(title: "Sets", color: Color(red: 0.5, green: 0.7, blue: 1.0), iconName: "square.grid.3x3"),
        OtherPuzzle(title: "Mosaic", color: Color(red: 1.0, green: 0.4, blue: 0.6), iconName: "square.grid.3x3.fill")
    ]
}

