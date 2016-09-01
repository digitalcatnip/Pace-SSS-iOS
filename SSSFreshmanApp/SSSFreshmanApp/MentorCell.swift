//
//  MentorCell.swift
//  Pace SSS
//
//  Created by James McCarthy on 8/31/16.
//  Copyright © 2016 Digital Catnip. All rights reserved.
//

class MentorCell: UITableViewCell {
    @IBOutlet weak var mentorName: UILabel?
    @IBOutlet weak var mentorMajor: UILabel?
    @IBOutlet weak var mentorEmail: UILabel?
    var mentorObj: Mentor? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure() {
        if mentorName != nil && mentorObj != nil {
            mentorName!.text = mentorObj!.fullName()
        }
        if mentorMajor != nil && mentorObj != nil {
            mentorMajor!.text = mentorObj!.major
        }
        if mentorEmail != nil && mentorObj != nil {
            mentorEmail!.text = mentorObj!.email
        }
    }
}
