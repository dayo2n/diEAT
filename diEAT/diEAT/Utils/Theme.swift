//
//  Them.swift
//  diEAT
//
//  Created by 문다 on 2022/10/09.
//

import SwiftUI

struct Theme {
    
    static let saturdayTextColor = Color("saturdayTextColor")
    static let sundayTextColor = Color("sundayTextColor")
    
    static func bgColor(_ scheme: ColorScheme) -> Color {
        let lightColor = Color("bgColor")
        let darkColor = Color("bgColor")
        
        switch scheme {
        case .light : return lightColor
        case .dark : return darkColor
        @unknown default: return lightColor
        }
    }
    
    static func defaultColor(_ scheme: ColorScheme) -> Color {
        let lightColor = Color("defaultColor")
        let darkColor = Color("defaultColor")
        
        switch scheme {
        case .light : return lightColor
        case .dark : return darkColor
        @unknown default: return lightColor
        }
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
