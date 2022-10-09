//
//  Them.swift
//  diEAT_SwiftUI
//
//  Created by 문다 on 2022/10/09.
//

import SwiftUI

struct Theme {
    static func bgColor(_ scheme: ColorScheme) -> Color {
        let lightColor = Color("bgColor")
        let darckColor = Color("bgColor")
        
        switch scheme {
        case .light : return lightColor
        case .dark : return darckColor
        @unknown default: return lightColor
        }
    }
    
    static func defaultColor(_ scheme: ColorScheme) -> Color {
        let lightColor = Color("defaultColor")
        let darckColor = Color("defaultColor")
        
        switch scheme {
        case .light : return lightColor
        case .dark : return darckColor
        @unknown default: return lightColor
        }
    }
    
    static func textColor(_ scheme: ColorScheme) -> Color {
        let lightColor = Color(.black)
        let darckColor = Color(.white)
        
        switch scheme {
        case .light : return lightColor
        case .dark : return darckColor
        @unknown default: return lightColor
        }
    }
}
