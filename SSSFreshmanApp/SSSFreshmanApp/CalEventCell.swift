//
//  CalEventCell.swift
//  Pace SSS
//
//  Created by James McCarthy on 9/1/16.
//  Copyright © 2016 Digital Catnip. All rights reserved.
//

class CalEventCell: UITableViewCell {
    @IBOutlet weak var eventName: UILabel?
    @IBOutlet weak var eventDesc: UILabel?
    @IBOutlet weak var eventTime: UILabel?
    var eventObj: CalEvent? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure() {
        if eventName != nil && eventObj != nil {
            eventName!.text = eventObj!.title
        }
        if eventDesc != nil && eventObj != nil {
            eventDesc!.text = eventObj!.desc
        }
        if eventTime != nil && eventObj != nil {
            eventTime!.text = eventObj!.eventTimeRange()
        }
    }
}
