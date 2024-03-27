//
//  Them.swift
//  diEAT
//
//  Created by 문다 on 2022/10/09.
//

import SwiftUI

struct Theme {
    static let saturdayTextColor = Color(String.saturdayTextColor)
    static let sundayTextColor = Color(String.sundayTextColor)
    
    static func bgColor(_ scheme: ColorScheme) -> Color {
        Color(String.bgColor)
    }
    
    static func defaultColor(_ scheme: ColorScheme) -> Color {
        Color(String.defaultColor)
    }
    
    static func textColor(_ scheme: ColorScheme) -> Color {
        let lightColor = Color(.black)
        let darkColor = Color(.white)
        
        switch scheme {
        case .light : return lightColor
        case .dark : return darkColor
        @unknown default: return lightColor
        }
    }
    
    static func btnColor(_ scheme: ColorScheme) -> Color {
        let lightColor = Color(.lightGray)
        let darkColor = Color(.darkGray)
        
        switch scheme {
        case .light : return lightColor
        case .dark : return darkColor
        @unknown default: return lightColor
        }
    }
}
