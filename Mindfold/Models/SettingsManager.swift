//
//  SettingsManager.swift
//  Mindfold
//
//  Created by Evan Haque on 1/17/26.
//

import Foundation
import SwiftUI

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    @AppStorage("demoModeEnabled") var demoModeEnabled: Bool = false
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = false
    @AppStorage("hapticsEnabled") var hapticsEnabled: Bool = true
    @AppStorage("selectedTheme") var selectedTheme: String = "System"
    
    private init() {}
}
