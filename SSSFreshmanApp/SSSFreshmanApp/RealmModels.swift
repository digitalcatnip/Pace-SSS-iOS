//
//  RealmModels.swift
//  Pace SSS
//
//  Created by James McCarthy on 8/31/16.
//  Copyright © 2016 Digital Catnip. All rights reserved.
//

import RealmSwift
import GoogleAPIClient

class BaseObject: Object {
    dynamic var id = 0

    override static func primaryKey() -> String? {
        return "id"
    }
}

class Course: BaseObject {
    dynamic var campus = ""
    dynamic var course_number = ""
    dynamic var title = ""
    dynamic var subject_code = ""
    dynamic var subject_desc = ""
    dynamic var term_desc = ""
    dynamic var course_level = ""
    dynamic var subject_course = ""
    
    func initializeFromSpreadsheet(values: [String]) {
        campus = values[0]
        course_number = values[1]
        title = values[2]
        subject_code = values[3]
        subject_desc = values[4]
        if subject_code.characters.count > 0 && course_number.characters.count > 0 {
            subject_course = "\(subject_code) \(course_number)"
        } else {
            subject_course = ""
        }
//        term_desc = values[5]
//        course_level = values[6]
        id = getHashForID(subject_desc, course_number: course_number)
    }
    
    func getHashForID(subject: String, course_number: String) -> Int {
        return "\(subject) \(course_number)".hash
    }
    
    func fullSubject() -> String {
        if subject_course.characters.count > 0 {
            return "\(subject_desc) (\(subject_course))"
        }
        return subject_desc
    }
}

class Tutor: BaseObject {
    dynamic var first_name = ""
    dynamic var last_name = ""
    dynamic var email = ""
    dynamic var subjects = ""
    
    func initializeFromSpreadsheet(values: [String]) {
        first_name = values[0]
        last_name = values[1]
        email = values[2]
        subjects = values[3]
        
        id = getHashForID(first_name, lastName: last_name)
    }
    
    func getHashForID(firstName: String, lastName: String) -> Int {
        return "\(firstName) \(lastName)".hash
    }
    
    func fullName() -> String {
        return "\(first_name) \(last_name)"
    }
}

class Mentor: BaseObject {
    dynamic var first_name = ""
    dynamic var last_name = ""
    dynamic var email = ""
    dynamic var role = ""
    dynamic var major = ""
    
    func initializeFromSpreadsheet(values: [String]) {
        first_name = values[0]
        last_name = values[1]
        email = values[2]
        role = values[3]
        major = values[4]
        
        id = getHashForID(first_name, lastName: last_name)
    }
    
    func getHashForID(firstName: String, lastName: String) -> Int {
        return "\(firstName) \(lastName)".hash
    }
    
    func fullName() -> String {
        return "\(first_name) \(last_name)"
    }
}

class CalEvent: Object {
    dynamic var event_id = ""
    dynamic var start_time = NSDate()
    dynamic var end_time = NSDate()
    dynamic var title = ""
    dynamic var desc = "" //description
    
    func initializeFromGoogle(event: GTLCalendarEvent) {
        event_id = event.identifier
        var temp : GTLDateTime! = event.start.dateTime ?? event.start.date
        start_time = temp.date
        temp = event.end.dateTime ?? event.end.date
        end_time = temp.date
        title = event.summary
        if event.descriptionProperty != nil {
            desc = event.descriptionProperty
        }
    }
    
    override static func primaryKey() -> String? {
        return "event_id"
    }
    
    func eventTimeRange() -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.timeZone = NSTimeZone.defaultTimeZone()
        return "\(formatter.stringFromDate(start_time)) - \(formatter.stringFromDate(end_time))"
    }
}
