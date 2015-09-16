//
//  GooglePlusContactsImporter.swift
//  ContactsImporter
//
//  Created by Muhammad Ishaq on 10/10/2014.
//  Copyright (c) 2014 Kahaf. All rights reserved.
//

import UIKit

// imports friends from visible circles
// docs here: https://developers.google.com/+/mobile/ios/
class GooglePlusContactsImporter : NSObject, GPPSignInDelegate {
    private var contacts = Array<Contact>()
    private var callback: ((contacts: Array<Contact>, error: NSError!) -> Void)! = nil
    
    // FIXME: paste your google client id
    // follow the instructions here: https://developers.google.com/+/mobile/ios/getting-started
    private let GoogleClientId = "623330778218-lj9ql2mn31ajffaf28sp6egbopu9ln6r.apps.googleusercontent.com";
    
    func importContacts(callback: ((contacts: Array<Contact>, error: NSError!) -> Void)) {
        self.callback = callback
        self.signInGooglePlus()
    }
    
    func signInGooglePlus() {
        let signIn = GPPSignIn.sharedInstance()
        
        signIn.shouldFetchGooglePlusUser = true
        signIn.shouldFetchGoogleUserEmail = true
        
        signIn.clientID = self.GoogleClientId
        
        signIn.scopes = [kGTLAuthScopePlusLogin]
        
        signIn.delegate = self
        
        let result = signIn.trySilentAuthentication()
        if result == false {
            signIn.authenticate()
        }
    }

    func finishedWithAuth(auth: GTMOAuth2Authentication!, error: NSError!) {
        print("Received error \(error) and auth object \(auth)")
        print("User's Email \(auth.userEmail)")
        kickOffContactsRequest()
    }

    func kickOffContactsRequest() {
        let plusService = GTLServicePlus()
        plusService.retryEnabled = true
        plusService.authorizer = GPPSignIn.sharedInstance().authentication
        
        self.contacts = Array<Contact>()
        let query = GTLQueryPlus.queryForPeopleListWithUserId("me", collection: kGTLPlusCollectionVisible) as! GTLQueryPlus
        plusService.executeQuery(query, completionHandler: self.googlePlusContactsCallback);
    }
    
    func googlePlusContactsCallback(ticket: GTLServiceTicket!, returnObject: AnyObject?, error: NSError!) {
        if (error != nil) {
            // show error alert
            self.callback(contacts: self.contacts, error:error)
            return
        }
        
        let peopleFeed = returnObject as! GTLPlusPeopleFeed
        
        let peopleList = peopleFeed.items()
        
        print("peopleFeed.totalItems: \(peopleFeed.totalItems) peopleFeed.items().count: \(peopleFeed.items().count) peopleFeed.nextPageToken: \(peopleFeed.nextPageToken)")
        
        for personObject in peopleList {
            let person = personObject as! GTLPlusPerson
            
            let c = Contact(name: person.displayName)
            c.googlePlusId = person.identifier
            c.imageURL = person.image.url
            
            self.contacts.append(c)
        }
        
        if(peopleFeed.nextPageToken != nil) {
            let plusService = GTLServicePlus()
            plusService.retryEnabled = true
            plusService.authorizer = GPPSignIn.sharedInstance().authentication
            
            let query = GTLQueryPlus.queryForPeopleListWithUserId("me", collection: kGTLPlusCollectionVisible) as! GTLQueryPlus
            query.pageToken = peopleFeed.nextPageToken
            plusService.executeQuery(query, completionHandler: googlePlusContactsCallback)
        }
        else {
            self.callback(contacts:self.contacts, error:nil)
        }
        
    }
   
}
