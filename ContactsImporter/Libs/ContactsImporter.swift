//
//  ContactsImporter.swift
//  ContactsImporter
//
//  Created by Muhammad Ishaq on 15/9/14.
//  Copyright (c) 2014 Kahaf. All rights reserved.
//

import AddressBook
import UIKit

class ContactsImporter {
    
    private class func extractABAddressBookRef(abRef: Unmanaged<ABAddressBookRef>!) -> ABAddressBookRef? {
        if let ab = abRef {
            return Unmanaged<NSObject>.fromOpaque(ab.toOpaque()).takeUnretainedValue()
        }
        return nil
    }
    
    class func importContacts(callback: ((contacts: Array<Contact>, error: NSError!) -> Void)!) {
        if(ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.Denied || ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.Restricted) {
            dispatch_async(dispatch_get_main_queue(), {
                let alert = UIAlertView(title: "Address Book Access Denied", message: "Please grant us access to your Address Book in Settings -> Privacy -> Contacts", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
                })
            return
        }
        else if (ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.NotDetermined) {
            var errorRef: Unmanaged<CFError>? = nil
            let addressBook: ABAddressBookRef? = extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, &errorRef))
            ABAddressBookRequestAccessWithCompletion(addressBook, { (accessGranted: Bool, error: CFError!) -> Void in
                if(accessGranted) {
                    let contacts = self.copyContacts()
                    callback(contacts: contacts, error: nil)
                }
            })
        }
        else if (ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.Authorized) {
            let contacts = self.copyContacts()
            callback(contacts: contacts, error: nil)
        }
    }
    
    private class func retrievePersonProperty(person person: ABRecord!, property: ABPropertyID) -> String? {
        // http://stackoverflow.com/questions/26001636/swift-checking-unmanaged-address-book-single-value-property-for-nil
        
        let value = ABRecordCopyValue(person, property)
        return value?.takeRetainedValue() as? String
        
    }
    
    private class func retreivePersonMultiValuePropertyLabel(record: ABMultiValueRef, index: Int) -> String? {
        let value = ABMultiValueCopyLabelAtIndex(record, index)
        if value == nil {
            return nil
        }
        return value.takeRetainedValue() as NSString as String?
    }
    
    private class func retreivePersonMultiValuePropertyValue(record: ABMultiValueRef, index: Int) -> String? {
        let value: Unmanaged<AnyObject>? = ABMultiValueCopyValueAtIndex(record, index)
        return value?.takeRetainedValue() as AnyObject? as! String?
    }

    private class func copyContacts() -> Array<Contact> {
        var errorRef: Unmanaged<CFError>? = nil
        let addressBook: ABAddressBookRef? = extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, &errorRef))
        let contactsList: NSArray = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue() as NSArray
        print("\(contactsList.count) records in the array")
        
        var importedContacts = Array<Contact>()
        
        for record:ABRecordRef in contactsList {
            let contactPerson: ABRecordRef = record
            var firstName: String? = self.retrievePersonProperty(person: contactPerson, property: kABPersonFirstNameProperty)
            if firstName == nil {
                firstName = ""
            }
            var lastName: String? = self.retrievePersonProperty(person: contactPerson, property: kABPersonLastNameProperty)
            if lastName == nil {
                lastName = ""
            }
            
            print("-------------------------------")
            print("\(firstName!) \(lastName!)")
            
            let phonesRef: ABMultiValueRef = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty).takeRetainedValue() as ABMultiValueRef
            var phonesArray  = Array<Dictionary<String,String>>()
            var firstPhone: NSString? = nil
            for var i:Int = 0; i < ABMultiValueGetCount(phonesRef); i++ {
                var label: String? = self.retreivePersonMultiValuePropertyLabel(phonesRef, index: i)
                if label == nil {
                    label = ""
                }
                let value: String = self.retreivePersonMultiValuePropertyValue(phonesRef, index: i)!
                let phone = [label!: value]
                phonesArray.append(phone)
                
                if i == 0 {
                    firstPhone = value
                }
            }
            
            print("All Phones: \(phonesArray)")
            
            let emailsRef: ABMultiValueRef = ABRecordCopyValue(contactPerson, kABPersonEmailProperty).takeRetainedValue() as ABMultiValueRef
            var emailsArray = Array<Dictionary<String, String>>()
            var firstEmail:NSString? = nil
            for var i:Int = 0; i < ABMultiValueGetCount(emailsRef); i++ {
                var label: String? = self.retreivePersonMultiValuePropertyLabel(emailsRef, index: i)
                if label == nil {
                    label = ""
                }
                let value: String = self.retreivePersonMultiValuePropertyValue(emailsRef, index: i)!
                let email = [label!: value]
                emailsArray.append(email)
                
                if i == 0 {
                    firstEmail = value
                }
            }
            
            print("All Emails: \(emailsArray)")
            
            let birthday: NSDate? = ABRecordCopyValue(contactPerson, kABPersonBirthdayProperty)?.takeRetainedValue() as? NSDate
            
            print ("Birthday: \(birthday)")
            
            var thumbnail: NSData? = nil
            if ABPersonHasImageData(contactPerson) {
                thumbnail = ABPersonCopyImageDataWithFormat(contactPerson, kABPersonImageFormatThumbnail).takeRetainedValue() as NSData
            }
            
            let c = Contact(name: "\(firstName!) \(lastName!)")
            c.birthday = birthday
            c.phonesArray = phonesArray
            c.emailsArray = emailsArray
            c.thumbnailImage = thumbnail
            
            importedContacts.append(c)
        }
        
        return importedContacts
    }

    
}
