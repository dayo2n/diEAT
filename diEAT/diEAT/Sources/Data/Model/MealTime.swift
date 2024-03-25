//
//  MealTime.swift
//  diEAT
//
//  Created by 제나 on 3/25/24.
//

enum MealTime: String, CaseIterable, Identifiable {
    case Breakfast, Lunch, Dinner, etc
    var id: Self { self } // Identifiable 프로토콜을 받으면 ForEach문을 사용 가능
    var toString: String {
        self.rawValue.localized()
    }
}
