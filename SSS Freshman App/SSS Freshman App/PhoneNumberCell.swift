//
//  PhoneNumberCell.swift
//  Pace SSS
//
//  Created by James McCarthy on 8/15/16.
//  Copyright © 2016 Digital Catnip. All rights reserved.
//

import UIKit

class PhoneNumberCell: UITableViewCell {
    @IBOutlet weak var contact: UILabel?
    @IBOutlet weak var number: UILabel?
    var contactObj: Contact? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure() {
        if contact != nil && contactObj != nil{
            contact!.text = contactObj!.contactName
        }
        if number != nil && contactObj != nil {
            number!.text = contactObj!.formattedNumber
        }
    }
}
