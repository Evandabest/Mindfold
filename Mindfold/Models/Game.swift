//
//  Game.swift
//  Mindfold
//
//  Created by Evan Haque on 1/9/26.
//

import SwiftUI

struct Game: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let color: Color
    let iconName: String // For now, using SF Symbols, can be replaced with custom icons
}

