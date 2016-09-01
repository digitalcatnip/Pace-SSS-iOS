//
//  TutorCell.swift
//  Pace SSS
//
//  Created by James McCarthy on 8/31/16.
//  Copyright © 2016 Digital Catnip. All rights reserved.
//

class TutorCell: UITableViewCell {
    @IBOutlet weak var tutorName: UILabel?
    @IBOutlet weak var tutorSubject: UILabel?
    @IBOutlet weak var tutorEmail: UILabel?
    var tutorObj: Tutor? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure() {
        if tutorName != nil && tutorObj != nil {
            tutorName!.text = tutorObj!.fullName()
        }
        if tutorSubject != nil && tutorObj != nil {
            tutorSubject!.text = tutorObj!.subjects
        }
        if tutorEmail != nil && tutorObj != nil {
            tutorEmail!.text = tutorObj!.email
        }
    }
}
