//
//  Contacts.swift
//  Code Test Carlos Estevez
//
//  Created by Carlos Estevez on 12/18/18.
//  Copyright © 2018 Carlos Estevez. All rights reserved.
//

import Foundation

class Contact: NSObject, NSCoding {
    
    var firstName:String
    var lastName:String
    var dob:String
    var phoneNumbers:[String]
    var emails:[String]
    var addresses:[[String:String]]
    
    var fullName:String
    
    var id:Int?
    
    init(firstName:String, lastName:String, dob:String, phoneNumbers:[String], emails:[String], addresses:[[String:String]], fullName:String) {
        self.firstName = firstName
        self.lastName = lastName
        self.dob = dob
        self.phoneNumbers = phoneNumbers
        self.emails = emails
        self.addresses = addresses
        self.fullName = fullName
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let firstName = aDecoder.decodeObject(forKey: "firstName") as! String
        let lastName = aDecoder.decodeObject(forKey: "lastName") as! String
        let dob = aDecoder.decodeObject(forKey: "dob") as! String
        let phoneNumbers = aDecoder.decodeObject(forKey: "phoneNumbers") as! [String]
        let emails = aDecoder.decodeObject(forKey: "emails") as! [String]
        let addresses = aDecoder.decodeObject(forKey: "addresses") as! [[String:String]]
        let fullName = aDecoder.decodeObject(forKey: "fullName") as! String
        
        self.init(firstName: firstName, lastName: lastName, dob: dob, phoneNumbers: phoneNumbers, emails: emails, addresses: addresses, fullName: fullName)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(firstName, forKey: "firstName")
        aCoder.encode(lastName, forKey: "lastName")
        aCoder.encode(dob, forKey: "dob")
        aCoder.encode(phoneNumbers, forKey: "phoneNumbers")
        aCoder.encode(emails, forKey: "emails")
        aCoder.encode(addresses, forKey: "addresses")
        aCoder.encode(fullName, forKey: "fullName")
    }
}
