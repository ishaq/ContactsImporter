//
//  Contact.swift
//  ContactsImporter
//
//  Created by Muhammad Ishaq on 12/9/14.
//  Copyright (c) 2014 Kahaf. All rights reserved.
//

import UIKit

class Contact: NSObject {
    
    // will contain the name if Contact object is loaded from iOS Phonebook, otherwise it may contain username
    var name : String
    var birthday: NSDate?
    
    // will only be set in case Contact object is loaded from iOS Phonebook
    var thumbnailImage: NSData?
    var originalImage: NSData?
    
    // will only be set in case Contact object is loaded from a Social Network e.g. Twitter/Facebook/GooglePlus
    var imageURL: NSString?
    
    // these two contain emails and phones in <label> = <value> format
    var emailsArray: Array<Dictionary<String, String>>?
    var phonesArray: Array<Dictionary<String, String>>?
    
    // if the object is loaded from phonebook, these three would be nil
    // if the object is loaded from a social network, one of these may be set
    var facebookId: String?
    var googlePlusId: String?
    var twitterId: String?
    
    override var description: String { get {
        return "\n\n\(name) \nBirthday: \(birthday) \nPhones: \(phonesArray) \nEmails: \(emailsArray)\nImageURL: \(imageURL)\n(Twitter ID: \(twitterId) - Google+ ID: \(googlePlusId) - Facebook ID: \(facebookId))"}
    }
    
    init(name: String) {
        self.name = name
    }
}
