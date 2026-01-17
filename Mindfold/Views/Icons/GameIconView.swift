//
//  GameIconView.swift
//  Mindfold
//
//  Created by Evan Haque on 1/9/26.
//

import SwiftUI

struct GameIconView: View {
    let game: Game
    
    var body: some View {
        Group {
            switch game.title {
            case "Shikaku":
                ShikakuIcon()
            case "Takuzu":
                TakuzuIcon()
            case "Star Battle":
                StarBattleIcon()
            case "Netwalk":
                NetwalkIcon()
            case "LITS":
                LITSIcon()
            case "Mastermind":
                MastermindIcon()
            case "Flood Fill":
                FloodFillIcon()
            case "Bridges":
                BridgesIcon()
            case "Number Snake":
                NumberSnakeIcon()
            default:
                DefaultIcon(iconName: game.iconName)
            }
        }
    }
}

