//
//  Extensions.swift
//  ESG
//
//  Created by Alikhan Kassiman on 2026.02.17.
//

import SwiftUI

extension View{
    
    func cardStyle(
        backgroundColor: Color = .cardBackground,
        cornerRadius: CGFloat = CornerRadius.medium,
        shadowRadius: CGFloat = 8
    ) -> some View{
        self
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(color: .cardShadow, radius: shadowRadius, x:0, y:4)
    }
    
    func primaryButtonStyle(
        backgroundColor: Color = .primaryGreen,
        foregroundColor: Color = .white
    ) -> some View{
        self
            .font(.buttonLarge)
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(backgroundColor)
            .cornerRadius(CornerRadius.medium)
    }
    
    func secondaryButtonStyle() -> some View{
        self
            .font(.buttonLarge)
            .foregroundColor(.primaryGreen)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.backgroundSecondary)
            .cornerRadius(CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .stroke(Color.primaryGreen, lineWidth: 2)
            )
    }
    
    func textFieldStyle() -> some View{
        self
            .font(.bodyLarge)
            .padding()
            .background(Color.backgroundSecondary)
            .cornerRadius(CornerRadius.small)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.small)
                    .stroke(Color.textTertiary.opacity(0.3), lineWidth: 1)
            )
    }
    
    func hideKeyboard(){
        UIApplication.shared.sendAction(#selector(UIResponder.resolveClassMethod(_:)), to: nil, from: nil, for: nil)
    }
    
    @ViewBuilder
    func `if`<Transform: View>(condition: Bool, tranform: (Self) -> Transform) -> some View{
        if condition {
            tranform(self)
        }
        else{
            self
        }
    }
}

extension String {
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
    
    // Password validation
    var isValidPassword: Bool {
        return self.count >= AppConfig.minPasswordLength
    }
    
    // Truncate string
    func truncated(to length: Int, trailing: String = "...") -> String {
        if self.count > length {
            return String(self.prefix(length)) + trailing
        }
        return self
    }
    
    // Capitalize first letter
    func capitalizedFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
}

extension Date {
    func formatted(style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        return formatter.string(from: self)
    }
    
    func formatted(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func timeAgoDisplay() -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day, .weekOfYear, .month, .year], from: self, to: now)
        
        if let year = components.year, year >= 1 {
            return year == 1 ? "1 year ago" : "\(year) years ago"
        }
        
        if let month = components.month, month >= 1 {
            return month == 1 ? "1 month ago" : "\(month) months ago"
        }
        
        if let week = components.weekOfYear, week >= 1 {
            return week == 1 ? "1 week ago" : "\(week) weeks ago"
        }
        
        if let day = components.day, day >= 1 {
            return day == 1 ? "1 day ago" : "\(day) days ago"
        }
        
        if let hour = components.hour, hour >= 1 {
            return hour == 1 ? "1 hour ago" : "\(hour) hours ago"
        }
        
        if let minute = components.minute, minute >= 1 {
            return minute == 1 ? "1 minute ago" : "\(minute) minutes ago"
        }
        
        return "Just now"
    }
    
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    var isThisWeek: Bool {
        return Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }
}

extension Int {
    // Format as points
    var formattedAsPoints: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
    
    // Format with suffix (K, M)
    var abbreviated: String {
        let number = Double(self)
        
        let thousand = number / 1000
        let million = number / 1000000
        
        if million >= 1.0 {
            return "\(round(million * 10) / 10)M"
        } else if thousand >= 1.0 {
            return "\(round(thousand * 10) / 10)K"
        } else {
            return "\(self)"
        }
    }
}


extension Double {
    // Format as percentage
    var formattedAsPercentage: String {
        return String(format: "%.0f%%", self * 100)
    }
}

extension Array where Element: Identifiable {
    func uniqued() -> [Element] {
        var seen = Set<Element.ID>()
        return filter { seen.insert($0.id).inserted }
    }
}


