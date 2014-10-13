//
//  FacebookContactsImporter.swift
//  ContactsImporter
//
//  Created by Muhammad Ishaq on 10/10/2014.
//  Copyright (c) 2014 Kahaf. All rights reserved.
//

import UIKit

// imports friends from facebook who are also using the app
// create an app id and configure your project: https://developers.facebook.com/docs/ios/getting-started

class FacebookContactsImporter {
    private var contacts = Array<Contact>()
    private var callback: ((contacts: Array<Contact>, error: NSError!) -> Void)! = nil
    
    func importContacts(callback: ((contacts: Array<Contact>, error: NSError!) -> Void)!) {
        self.callback = callback
        
        if(FBSession.activeSession().state == FBSessionState.CreatedTokenLoaded) {
            FBSession.openActiveSessionWithReadPermissions(["public_profile", "email", "user_friends", "user_birthday"],
                allowLoginUI: false, completionHandler: { (session:FBSession!, state: FBSessionState, error: NSError!) -> Void in
                    self.sessionStateChanged(session, state: state, error: error)
            })
        }
        else if(FBSession.activeSession().state == FBSessionState.Open ||
            FBSession.activeSession().state == FBSessionState.OpenTokenExtended) {
                self.getFacebookFriends()
        }
        else {
            FBSession .openActiveSessionWithReadPermissions(["public_profile", "email", "user_friends", "user_birthday"],
                allowLoginUI: true,
                completionHandler: { (session: FBSession!, state: FBSessionState, error: NSError!) -> Void in
                    self.sessionStateChanged(session, state: state, error: error)
            })
        }

    }
    
    func sessionStateChanged(session: FBSession!, state: FBSessionState, error: NSError!) -> Void {
        if let e = error {
            dispatch_async(dispatch_get_main_queue(), {
                self.handleFacebookError(e)
            })
            self.callback(contacts: Array<Contact>(), error:error)
            return;
        }
        // implicit else
        if(state == FBSessionState.Closed || state == FBSessionState.ClosedLoginFailed) {
            println("Facebook: Session Closed")
            return
        }
        
        if(state == FBSessionState.Open || state == FBSessionState.OpenTokenExtended) {
            self.getFacebookFriends()
        }
    }
    
    func getFacebookFriends() {
        FBRequest.requestForMyFriends().startWithCompletionHandler({ (requestConnection: FBRequestConnection!, response: AnyObject!, error: NSError!) -> Void in
            if let e = error {
                println("ERROR: \(e)")
                return
            }
            
            if let resultDict = response as? NSDictionary {
                
                let friends = resultDict["data"] as NSArray
                for f in friends {
                    let name = f["name"] as String
                    let facebookId = f["id"] as String
                    let c = Contact(name: name)
                    c.facebookId = facebookId
                    self.contacts.append(c)
                }
                
                self.callback(contacts: self.contacts, error: nil)
            }
        })
    }
    
    func handleFacebookError(e:NSError) -> Void {
        println("Facebook: Error: \(e)")
        if(FBErrorUtility.shouldNotifyUserForError(e)) {
            let alert = UIAlertView(title: "Something went wrong",
                message: FBErrorUtility.userMessageForError(e),
                delegate: nil,
                cancelButtonTitle: "OK")
            alert.show()
        }
        else {
            if(FBErrorUtility.errorCategoryForError(e) == FBErrorCategory.UserCancelled) {
                println("User cancelled the login")
            }
            else if(FBErrorUtility.errorCategoryForError(e) == FBErrorCategory.AuthenticationReopenSession) {
                let alert = UIAlertView(title: "Session Error",
                    message: "Your current session is no longer valid. Please log in again.",
                    delegate: nil,
                    cancelButtonTitle: "OK")
                alert.show()
            }
            else {
                // TODO
                // let errorInfo = e.userInfo["com.facebook.sdk:ParsedJSONResponseKey"]?["body"]?["error"] as NSDictionary
                let alertTitle = "Something went wrong."
                let alertBody = "Please retry. \n\n If the problem persists contact us" //" and mention this error code: TODO"
                let alert = UIAlertView(title: alertTitle, message: alertBody, delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
            FBSession.activeSession().closeAndClearTokenInformation()
        }
    }

}
