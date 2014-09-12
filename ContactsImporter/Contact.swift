//
//  Contact.swift
//  ContactsImporter
//
//  Created by Muhammad Ishaq on 12/9/14.
//  Copyright (c) 2014 Kahaf. All rights reserved.
//

import UIKit

class Contact: NSObject {
    
    var firstName : String
    var lastName : String
    var birthday: NSDate?
    var thumbnailImage: NSData?
    var originalImage: NSData?
    
    // these two contain emails and phones in <label> = <value> format
    var emailsArray: Array<Dictionary<String, String>>?
    var phonesArray: Array<Dictionary<String, String>>?
    
    override var description: String { get {
        return "\(firstName) \(lastName) \nBirthday: \(birthday) \nPhones: \(phonesArray) \nEmails: \(emailsArray)\n\n"}
    }
    
    init(firstName: String, lastName: String, birthday: NSDate?) {
        self.firstName = firstName
        self.lastName = lastName
        self.birthday = birthday
    }

   
}
