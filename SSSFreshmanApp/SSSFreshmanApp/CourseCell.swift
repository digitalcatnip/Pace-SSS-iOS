//
//  CourseCell.swift
//  Pace SSS
//
//  Created by James McCarthy on 8/31/16.
//  Copyright © 2016 Digital Catnip. All rights reserved.
//


class CourseCell: UITableViewCell {
    @IBOutlet weak var courseTitle: UILabel?
    @IBOutlet weak var subject: UILabel?
    @IBOutlet weak var campus: UILabel?
    var courseObj: Course? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure() {
        if courseTitle != nil && courseObj != nil {
            courseTitle!.text = courseObj!.title
        }
        if subject != nil && courseObj != nil {
            subject!.text = courseObj!.fullSubject()
        }
        if campus != nil && courseObj != nil {
            campus!.text = courseObj!.campus
        }
    }
}
