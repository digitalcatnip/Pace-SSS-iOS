//
//  RealmModels.swift
//  Pace SSS
//
//  Created by James McCarthy on 8/31/16.
//  Copyright © 2016 Digital Catnip. All rights reserved.
//

import RealmSwift

class Course: Object {
    dynamic var id = 0
    dynamic var campus = ""
    dynamic var course_number = ""
    dynamic var title = ""
    dynamic var subject_desc = ""
    dynamic var term_desc = ""
    dynamic var course_level = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func initializeFromSpreadsheet(values: [String]) {
        campus = values[0]
        course_number = values[1]
        title = values[2]
        subject_desc = values[3]
        term_desc = values[4]
        course_level = values[5]
        id = getHashForID(subject_desc, course_number: course_number)
    }
    
    func getHashForID(subject: String, course_number: String) -> Int {
        return "\(subject) \(course_number)".hash
    }
}