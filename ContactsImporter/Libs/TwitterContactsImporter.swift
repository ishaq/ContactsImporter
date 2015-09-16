//
//  TwitterContactsImporter.swift
//  ContactsImporter
//
//  Created by Muhammad Ishaq on 10/10/2014.
//  Copyright (c) 2014 Kahaf. All rights reserved.
//

import UIKit
import Social
import Accounts
import SwiftyJSON


enum TwitterErrorCodes: Int {
    case NoAccountsFound = 1
}

// fetches all the followers of a user
class TwitterContactsImporter {
    
    private var accountStore: ACAccountStore = ACAccountStore()
    private var contacts = Array<Contact>()
    private var callback: ((contacts: Array<Contact>, error: NSError!) -> Void)! = nil
    
    func importContacts(callback: ((contacts: Array<Contact>, error: NSError!) -> Void)) {
        
        self.callback = callback
        
        let twitterAccountType = self.accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        self.accountStore.requestAccessToAccountsWithType(twitterAccountType, options: nil) { (accessGranted: Bool, error: NSError!) -> Void in
            if accessGranted {
                
                let twitterAccounts = self.accountStore.accountsWithAccountType(twitterAccountType)
                
                if(twitterAccounts.count == 0) {
                    let code = TwitterErrorCodes.NoAccountsFound.rawValue
                    
                    let error = NSError(domain: "com.kahaf.ContactsImporter.errors", code: code, userInfo: [NSLocalizedDescriptionKey: "No Twitter Accounts Found, Please sign in to twitter in your iPhone Settings"])
                    
                    self.callback(contacts: Array<Contact>(), error: error)
                    return
                }
                
                let url = NSURL(string: "https://api.twitter.com/1.1/followers/list.json")
                let twitterAccount = twitterAccounts.last as! ACAccount
                // NOTE: all params are strings because SLRequest does not accept any other parameter type
                let params = ["screen_name": twitterAccount.username, "count": "200", "skip_status": "true"]
                let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: url, parameters: params)
                request.account = twitterAccount
                self.contacts = Array<Contact>()
                request.performRequestWithHandler(self.userLookupCallback)
            }
        }
    }
    
    func userLookupCallback(data: NSData!, response: NSHTTPURLResponse!, error: NSError!) {
        if(error != nil) {
            // show error alert?
            self.callback(contacts: self.contacts, error: error)
            return
        }
        
        if data == nil {
            self.callback(contacts: self.contacts, error: nil)
            return
        }
        
        let json = JSON(data: data)
        
        if let errors = json["errors"].array {
            print("errors: \(errors)")
            print("\(self.contacts)")
            // TODO: pass error object
            self.callback(contacts: self.contacts, error: nil)
            return
        }
        
        let users = json["users"].arrayValue
        
        for u in users {
            var name = u["name"].stringValue
            if(name == "") {
                name = u["screen_name"].stringValue
            }
            let twitterId = u["id_str"].stringValue
            
            let c = Contact(name: name)
            c.twitterId = twitterId
            c.imageURL = u["profile_image_url"].stringValue
            self.contacts.append(c)
        }
        
        let nextCursor = json["next_cursor"].intValue
        
        if(nextCursor != 0) {
            let url = NSURL(string: "https://api.twitter.com/1.1/followers/list.json")
            let twitterAccountType = self.accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
            let twitterAccounts = self.accountStore.accountsWithAccountType(twitterAccountType)
            let twitterAccount = twitterAccounts.last as! ACAccount
            // NOTE: all params are strings because SLRequest does not accept any other parameter type
            let params = ["screen_name": twitterAccount.username, "count": "200", "skip_status": "true", "cursor": "\(nextCursor)"]
            let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: url, parameters: params)
            request.account = twitterAccount
            request.performRequestWithHandler(self.userLookupCallback)
        }
        else {
            self.callback(contacts: self.contacts, error: nil)
        }
    }
}
