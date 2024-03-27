//
//  Date+.swift
//  diEAT
//
//  Created by 제나 on 3/27/24.
//

import Foundation

extension Date {
    static let defaultDateFormat = "yyyy-MM-dd HH:mm:ss"
    // Date 타입에서 "2000-01-01" 형식의 문자열로 리턴
    var date2OnlyDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Date.defaultDateFormat
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let splitOnlyDate = dateFormatter.string(from: self).split(separator: " ")
        return "\(splitOnlyDate[0])"
    }
    // Date 타입에서 "2000-01" 형식의 문자열로 리턴
    var date2OnlyMonth: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Date.defaultDateFormat
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let splitOnlyDate = dateFormatter.string(from: self).split(separator: " ")
        return "\(splitOnlyDate[0])"
    }

    var utc2kst: Date {
        let dateFormatterKST = DateFormatter()
        dateFormatterKST.dateFormat = Date.defaultDateFormat
        dateFormatterKST.timeZone = TimeZone(identifier: "KST")
        let stringKST = dateFormatterKST.string(from: self)
        
        let dateFormatterUTC = DateFormatter()
        dateFormatterUTC.dateFormat = Date.defaultDateFormat
        dateFormatterUTC.timeZone = TimeZone(identifier: "UTC")
        return dateFormatterUTC.date(from: stringKST)!
    }

}
