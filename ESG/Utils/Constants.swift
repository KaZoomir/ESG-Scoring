//
//  Constants.swift
//  ESG
//
//  Created by Alikhan Kassiman on 2026.02.15.
//

import SwiftUI

extension Color{
    static let primaryGreen = Color(hex: "#00B383")
    static let primaryBlue = Color(hex: "#0066FF")
    static let primaryRed = Color(hex: "#7B61FF")
    
    static let environmentalColor = primaryGreen
    static let socialColor = primaryBlue
    static let governanceColor = primaryRed
    
    static let backgroundPrimary = Color(hex: "#FFFFFF")
    static let backgroundSecondary = Color(hex: "#F5F7FA")
    static let backgroundTertiary = Color(hex: "#E8ECF1")
    
    static let textPrimary = Color(hex: "#1A1D26")
    static let textSecondary = Color(hex: "#6B7280")
    static let textTertiary = Color(hex: "#9CA3AF")
    
    static let successColor = Color(hex: "#10B981")
    static let warningColor = Color(hex: "F59E0B")
    static let errorColor = Color(hex: "#EF4444")
    static let infoColor = Color(hex: "#3B92F6")
    
    static let cardBackground = Color(hex: "#FFFFFF")
    static let cardShadow = Color(hex: "#000000").opacity(0.08)
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner (string: hex).scanHexInt64(&int)
        let a,r,g,b: Int64
        switch hex.count{
        case 3:
            (a,r,g,b) = (255,(int >> 8 ) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a,r,g,b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a,r,g,b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a,r,g,b) = (255,0,0,0)
        }
        self.init(
            .sRGB,
            red:Double(r)/255,
            green:Double(g)/255,
            blue: Double(b)/255,
            opacity: Double(a)/255
        )
    }
}

extension Font{
    static let h1 = Font.system(size:32, weight: .bold)
    static let h2 = Font.system(size:28, weight: .bold)
    static let h3 = Font.system(size:24, weight: .semibold)
    static let h4 = Font.system(size:20, weight: .semibold)
    static let h5 = Font.system(size:18, weight: .medium)
    static let h6 = Font.system(size:16, weight: .medium)
    
    static let bodyLarge = Font.system(size:16, weight: .regular)
    static let bodyMedium = Font.system(size:14, weight: .regular)
    static let bodySmall = Font.system(size:12, weight: .regular)
    
    static let buttonLarge = Font.system(size: 16, weight: .semibold)
    static let buttonMedium = Font.system(size:14, weight: .semibold)
    static let buttonSmall = Font.system(size: 12, weight: .semibold)
    
    static let caption = Font.system(size:12, weight: .regular)
    static let captionSmall = Font.system(size:10, weight: .regular)
}

struct Spacing{
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 48
}

struct CornerRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let xlarge: CGFloat = 24
    static let circle: CGFloat = 999
}

struct ShadowStyle{
    static let card: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) = (.cardShadow, 8, 0, 4)
    static let button: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) = (.cardShadow, 4, 0, 2)
    static let floating: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) = (.cardShadow, 12, 0, 2)
}

struct AnimationDuration{
    static let fast: Double = 0.2
    static let normal: Double = 0.3
    static let slow: Double = 0.5
}

struct AppIcons {
    static let home = "house.fill"
    static let events = "calendar"
    static let ratings = "chat.bar.fill"
    static let profile = "person.fill"
    static let shop = "bag.fill"
    static let settings = "gearshape.fill"
    static let enviromental = "leaf.fill"
    static let social = "person.3.fill"
    static let governance = "building.columns.fill"
    static let plus = "plus"
    static let search = "magnifyingglass"
    static let filter = "line.3.horizontal.decrease.circle"
    static let close = "xmark"
    static let check = "checkmark"
    static let star = "star.fill"
    static let heart = "heart.fill"
    static let share = "square.and.arrow.up"
    static let notification = "bell.fill"
}

struct AppConfig{
    static let appName = "ESG KBTU"
    static let version = "1.0.0"
    static let mainPasswordLegth = 8
    static let maxEventParticipants = 100
    static let pointsPerLevel = [0,100,300,600,1000,2000]
    static let levelNames = ["Beginner", "Activist", "Champion", "Leader", "Legend"]
}


