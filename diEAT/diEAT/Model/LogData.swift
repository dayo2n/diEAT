//
//  LogData.swift
//  diEAT
//
//  Created by 문다 on 2021/11/04.
//

import Foundation
import RealmSwift

class LogData: Object{
    
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var date: String?
    @Persisted dynamic var time: String?
    
    convenience init(content: String){
        self.init()
    }
}
