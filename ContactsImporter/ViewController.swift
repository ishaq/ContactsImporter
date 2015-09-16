//
//  ViewController.swift
//  ContactsImporter
//
//  Created by Muhammad Ishaq on 12/9/14.
//  Copyright (c) 2014 Kahaf. All rights reserved.
//

import UIKit
import AddressBook
import FacebookSDK
import MRProgress

class ViewController: UIViewController {
    
    private var twitterContactsImporter = TwitterContactsImporter()
    private var facebookContactsImporter = FacebookContactsImporter()
    private var googlePlusContactsImpoter = GooglePlusContactsImporter()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func importContacts(sender: AnyObject) {
        MRProgressOverlayView.showOverlayAddedTo(self.view, animated: true)
        ContactsImporter.importContacts(showContacts)
    }

    @IBAction func importFacebookContacts(sender: AnyObject) {
        MRProgressOverlayView.showOverlayAddedTo(self.view, animated: true)
        self.facebookContactsImporter.importContacts(showContacts)
    }
    
    @IBAction func importGooglePlusContacts(sender: AnyObject) {
        MRProgressOverlayView.showOverlayAddedTo(self.view, animated: true)
        self.googlePlusContactsImpoter.importContacts(showContacts)
    }
    
    @IBAction func importTwitterContacts(sender: AnyObject) {
        MRProgressOverlayView.showOverlayAddedTo(self.view, animated: true)
        self.twitterContactsImporter.importContacts(showContacts)
    }
    
    func showContacts(contacts: Array<Contact>, error: NSError!) {
        print(contacts)
        dispatch_async(dispatch_get_main_queue(), {
            MRProgressOverlayView.dismissAllOverlaysForView(self.view, animated: true)
            if(error == nil) {
                let alertView = UIAlertView(title: "Success!", message: "\(contacts.count) contacts imported successfully", delegate: nil, cancelButtonTitle: "OK")
                alertView.show()
                
            }
            else {
                let alertView = UIAlertView(title: "Error \(error.code)",
                    message: "[\(error.code)] \(error.localizedDescription)\n\n\(contacts.count) contacts imported successfully",
                    delegate: nil,
                    cancelButtonTitle: "OK")
                alertView.show()
            }
        })
    }
    
}

