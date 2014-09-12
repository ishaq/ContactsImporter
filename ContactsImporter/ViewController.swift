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
        self.requestAccessAndImportContacts()
    }
    func extractABAddressBookRef(abRef: Unmanaged<ABAddressBookRef>!) -> ABAddressBookRef? {
        if let ab = abRef {
            return Unmanaged<NSObject>.fromOpaque(ab.toOpaque()).takeUnretainedValue()
        }
        return nil
    }
    
    func requestAccessAndImportContacts() {
        if(ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.Denied || ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.Restricted) {
            let alert = UIAlertView(title: "Address Book Access Denied", message: "Please grant us access to your Address Book in Settings -> Privacy -> Contacts", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            return
        }
        else if (ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.NotDetermined) {
            var errorRef: Unmanaged<CFError>? = nil
            var addressBook: ABAddressBookRef? = extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, &errorRef))
            ABAddressBookRequestAccessWithCompletion(addressBook, { (accessGranted: Bool, error: CFError!) -> Void in
                if(accessGranted) {
                    let contacts = self.importContacts()
                    self.showContacts(contacts)
                }
            })
        }
        else if (ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.Authorized) {
            let contacts = self.importContacts()
            self.showContacts(contacts)
        }
    }
    
    
    func importContacts() -> Array<Contact> {
        var errorRef: Unmanaged<CFError>? = nil
        var addressBook: ABAddressBookRef? = extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, &errorRef))
        var contactsList: NSArray = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue()
        println("\(contactsList.count) records in the array")
        
        var importedContacts = Array<Contact>()
        
        for record:ABRecordRef in contactsList {
            var contactPerson: ABRecordRef = record
            var firstName: String = ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty).takeRetainedValue() as NSString
            var lastName: String = ABRecordCopyValue(contactPerson, kABPersonLastNameProperty).takeRetainedValue() as NSString
            
            println("-------------------------------")
            println("\(firstName) \(lastName)")
            
            var phonesRef: ABMultiValueRef = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty).takeRetainedValue() as ABMultiValueRef
            var phonesArray  = Array<Dictionary<String,String>>()
            for var i:Int = 0; i < ABMultiValueGetCount(phonesRef); i++ {
                var label: String = ABMultiValueCopyLabelAtIndex(phonesRef, i).takeRetainedValue() as NSString
                var value: String = ABMultiValueCopyValueAtIndex(phonesRef, i).takeRetainedValue() as NSString
                
                println("Phone: \(label) = \(value)")
                
                var phone = [label: value]
                phonesArray.append(phone)
            }
            
            println("All Phones: \(phonesArray)")
            
            var emailsRef: ABMultiValueRef = ABRecordCopyValue(contactPerson, kABPersonEmailProperty).takeRetainedValue() as ABMultiValueRef
            var emailsArray = Array<Dictionary<String, String>>()
            for var i:Int = 0; i < ABMultiValueGetCount(emailsRef); i++ {
                var label: String = ABMultiValueCopyLabelAtIndex(emailsRef, i).takeRetainedValue() as NSString
                var value: String = ABMultiValueCopyValueAtIndex(emailsRef, i).takeRetainedValue() as NSString
                
                println("Email: \(label) = \(value)")
                
                var email = [label: value]
                emailsArray.append(email)
            }
            
            println("All Emails: \(emailsArray)")
            
            var birthday: NSDate? = ABRecordCopyValue(contactPerson, kABPersonBirthdayProperty).takeRetainedValue() as? NSDate
            
            println ("Birthday: \(birthday)")
            
            var thumbnail: NSData? = nil
            var original: NSData? = nil
            if ABPersonHasImageData(contactPerson) {
                thumbnail = ABPersonCopyImageDataWithFormat(contactPerson, kABPersonImageFormatThumbnail).takeRetainedValue() as NSData
                original = ABPersonCopyImageDataWithFormat(contactPerson, kABPersonImageFormatOriginalSize).takeRetainedValue() as NSData
            }
            
            let currentContact = Contact(firstName: firstName, lastName: lastName, birthday: birthday)
            currentContact.phonesArray = phonesArray
            currentContact.emailsArray = emailsArray
            currentContact.thumbnailImage = thumbnail
            currentContact.originalImage = original
            
            importedContacts.append(currentContact)
        }
        
        return importedContacts
    }
    
    func showContacts(contacts: Array<Contact>) {
        let alertView = UIAlertView(title: "Success!", message: "\(contacts.count) contacts imported successfully", delegate: nil, cancelButtonTitle: "OK")
        alertView.show()
    }
    
}

