//
//  DateConverter.swift
//  diEAT_SwiftUI
//
//  Created by 문다 on 2022/10/15.
//

import Foundation

struct DateConverter {
    let todayDate : String = Date2OnlyDate(date: Date())
}

// Date 타입에서 "2000-01-01" 형식의 문자열로 리턴
func Date2OnlyDate(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.timeZone = TimeZone(identifier: "UTC")
    let splitOnlyDate = dateFormatter.string(from: date).split(separator: " ")
    
    return "\(splitOnlyDate[0])"
}

func UTC2KST(date: Date) -> Date {
    let dateFormatterKST = DateFormatter()
    dateFormatterKST.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatterKST.timeZone = TimeZone(identifier: "KST")
    let stringKST: String = dateFormatterKST.string(from: date)
    
    
    let dateFormatterUTC = DateFormatter()
    dateFormatterUTC.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatterUTC.timeZone = TimeZone(identifier: "UTC")
    return dateFormatterUTC.date(from: stringKST)!
}
