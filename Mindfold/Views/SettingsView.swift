//
//  SettingsView.swift
//  Mindfold
//
//  Created by Evan Haque on 1/17/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var settings = SettingsManager.shared
    
    let themes = ["Light", "Dark", "System"]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .medium))
                    }
                    
                    Spacer()
                    
                    Text("Settings")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .bold))
                    
                    Spacer()
                    
                    // Balance the header
                    Image(systemName: "chevron.left")
                        .foregroundColor(.clear)
                        .font(.system(size: 20, weight: .medium))
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 24)
                
                // Settings content
                ScrollView {
                    VStack(spacing: 24) {
                        // Notifications Section
                        SettingRow(
                            icon: "bell.fill",
                            title: "Notifications",
                            toggle: $settings.notificationsEnabled
                        )
                        
                        // Haptics Section
                        SettingRow(
                            icon: "hand.tap.fill",
                            title: "Haptics",
                            toggle: $settings.hapticsEnabled
                        )
                        
                        Divider()
                            .background(Color(white: 0.3))
                            .padding(.vertical, 8)
                        
                        // Theme Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 12) {
                                Image(systemName: "paintbrush.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 20))
                                    .frame(width: 28)
                                
                                Text("Theme")
                                    .foregroundColor(.white)
                                    .font(.system(size: 18, weight: .medium))
                            }
                            
                            VStack(spacing: 12) {
                                ForEach(themes, id: \.self) { theme in
                                    ThemeOptionButton(
                                        title: theme,
                                        isSelected: settings.selectedTheme == theme
                                    ) {
                                        settings.selectedTheme = theme
                                    }
                                }
                            }
                        }
                        
                        Divider()
                            .background(Color(white: 0.3))
                            .padding(.vertical, 8)
                        
                        // Demo Mode Section
                        SettingRow(
                            icon: "play.circle.fill",
                            title: "Demo Mode",
                            toggle: $settings.demoModeEnabled
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
                
                Spacer()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Setting Row Component
struct SettingRow: View {
    let icon: String
    let title: String
    @Binding var toggle: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white)
                .font(.system(size: 20))
                .frame(width: 28)
            
            Text(title)
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .medium))
            
            Spacer()
            
            Toggle("", isOn: $toggle)
                .toggleStyle(SwitchToggleStyle(tint: .blue))
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Theme Option Button
struct ThemeOptionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 20))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color(white: 0.2) : Color(white: 0.15))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 2)
            )
        }
    }
}

#Preview {
    SettingsView()
}
