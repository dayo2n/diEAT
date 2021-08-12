//
//  DataRealm.swift
//  diEAT
//
//  Created by 문다 on 2021/08/09.
//

import Foundation
import RealmSwift

class LogData: Object{
    @objc dynamic var year = ""
    @objc dynamic var month = ""
    @objc dynamic var day = ""
    
    @objc dynamic var breakfast : String = ""
    @objc dynamic var lunch : String = ""
    @objc dynamic var dinner : String = ""
    @objc dynamic var etc : String = ""
//    let breakfast = List<String>()
//    let lunch = List<String>()
//    let dinner = List<String>()
//    let etc = List<String>()
}
