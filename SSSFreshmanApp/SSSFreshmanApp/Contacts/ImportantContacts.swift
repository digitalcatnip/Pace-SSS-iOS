//
//  ImportantContacts.swift
//  Pace SSS
//
//  Created by James McCarthy on 8/15/16.
//  Copyright © 2016 Digital Catnip. All rights reserved.
//

import UIKit

class ImportantContacts: UITableViewController {
    
    var contacts: [Contact] = [Contact]()
    var alphabetsArray: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeAlphabet()
        readContacts()
        contacts.sortInPlace() { c1, c2 in
            return c1.contactName.compare(c2.contactName) == NSComparisonResult.OrderedAscending
        }
    }
    
    //MARK: UITableViewDataSource functions
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65.0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("contactCell", forIndexPath: indexPath) as! PhoneNumberCell
        cell.contactObj = contacts[indexPath.row]
        cell.configure()
        return cell
    }

    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return alphabetsArray
    }
    
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String,
                            atIndex index: Int) -> Int {
        for (idx, contact) in contacts.enumerate() {
            let s = contact.contactName.substringToIndex(contact.contactName.characters.startIndex.successor())
            if s == title {
                tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: idx, inSection: 0), atScrollPosition: .Top, animated: true)
                break
            }
        }
        return -1
    }
    
    //MARK: UITableViewDelegate functions
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let contact = contacts[indexPath.row]
        contact.dialNumber()
        
    }
    
    // MARK: Contact Specific code
    func readContacts() {
        var lines = [String]()
        if let path = NSBundle.mainBundle().pathForResource("important_numbers", ofType: "txt") {
            do {
                let text = try String(contentsOfFile: path)
                let separators = NSCharacterSet(charactersInString: "\n")
                lines = text.componentsSeparatedByCharactersInSet(separators)
                NSLog("Number of lines read: %d", lines.count)
                
            } catch {
                NSLog("Unable to read file")
            }
        }
        
        var i = 0;
        var contact = Contact()
        for line in lines {
            if(i % 2 == 0) {
                contact.contactName = line
            } else {
                contact.addPhoneNumber(line)
                NSLog("Adding contact %@", contact.contactName)
                contacts.append(contact)
                contact = Contact()
            }
            i = i+1
        }
    }
    
    func initializeAlphabet() {
        alphabetsArray.append("A")
        alphabetsArray.append("B")
        alphabetsArray.append("C")
        alphabetsArray.append("D")
        alphabetsArray.append("F")
        alphabetsArray.append("G")
        alphabetsArray.append("H")
        alphabetsArray.append("I")
        alphabetsArray.append("J")
        alphabetsArray.append("L")
        alphabetsArray.append("N")
        alphabetsArray.append("O")
        alphabetsArray.append("P")
        alphabetsArray.append("R")
        alphabetsArray.append("S")
        alphabetsArray.append("T")
        alphabetsArray.append("U")
    }
}

class Contact {
    var contactName = "";
    var phoneNumber = "";
    var formattedNumber = ""
    
    func addPhoneNumber(newNumber: String) {
        self.phoneNumber = newNumber
        if(newNumber.characters.count == 10) {
            let acRange = newNumber.startIndex..<newNumber.startIndex.advancedBy(3)
            let exRange = newNumber.startIndex.advancedBy(3)..<newNumber.endIndex.advancedBy(-4)
            let lastRange = newNumber.endIndex.advancedBy(-4)..<newNumber.endIndex
            let str = "(\(newNumber.substringWithRange(acRange)))\(newNumber.substringWithRange(exRange))-\(newNumber.substringWithRange(lastRange))"
            self.formattedNumber = str
        } else {
            self.formattedNumber = newNumber
        }
    }
    
    func dialNumber() {
        if let url = NSURL(string: "tel://\(phoneNumber)") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
}
