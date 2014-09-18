//
//  ViewController.swift
//  ContactsImporter
//
//  Created by Muhammad Ishaq on 12/9/14.
//  Copyright (c) 2014 Kahaf. All rights reserved.
//

import UIKit
import AddressBook

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func importContacts(sender: AnyObject) {
        ContactsImporter.importContacts(showContacts)
    }

    func showContacts(contacts: Array<Contact>) {
        let alertView = UIAlertView(title: "Success!", message: "\(contacts.count) contacts imported successfully", delegate: nil, cancelButtonTitle: "OK")
        alertView.show()
    }
    
}

