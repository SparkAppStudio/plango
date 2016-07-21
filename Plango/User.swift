//
//  User.swift
//  Plango
//
//  Created by Douglas Hewitt on 4/8/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class User: NSObject, NSCoding {
    var id: String!
    var userName: String?
    var displayName: String?
    var email: String?
    
    var avatar: String?
    
    var plans: NSArray?
    
    var invites: Int32?
    var admin: Bool?
    var confirmed: Bool?
    var showPlan: Bool?
    var showSum: Bool?
    
    init(id: String) {
        self.id = id
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
       let tempID = aDecoder.decodeObjectForKey("id") as! String
        self.init(id: tempID)
        self.userName = aDecoder.decodeObjectForKey("userName") as? String
        self.displayName = aDecoder.decodeObjectForKey("displayName") as? String
        self.email = aDecoder.decodeObjectForKey("email") as? String
        self.avatar = aDecoder.decodeObjectForKey("avatar") as? String
        self.plans = aDecoder.decodeObjectForKey("plans") as? NSArray
        self.invites = aDecoder.decodeInt32ForKey("invites")
        self.admin = aDecoder.decodeBoolForKey("admin")
        self.confirmed = aDecoder.decodeBoolForKey("confirmed")
        self.showPlan = aDecoder.decodeBoolForKey("showPlan")
        self.showSum = aDecoder.decodeBoolForKey("showSum")
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(id, forKey: "id")
        aCoder.encodeObject(userName, forKey: "userName")
        aCoder.encodeObject(displayName, forKey: "displayName")
        aCoder.encodeObject(email, forKey: "email")
        aCoder.encodeObject(avatar, forKey: "avatar")
        aCoder.encodeObject(plans, forKey: "plans")
        if let invites = invites {
            aCoder.encodeInt32(invites, forKey: "invites")
        }
        if let admin = admin {
            aCoder.encodeBool(admin, forKey: "admin")
        }
        if let confirmed = confirmed {
            aCoder.encodeBool(confirmed, forKey: "confirmed")
        }
        if let showPlan = showPlan {
            aCoder.encodeBool(showPlan, forKey: "showPlan")
        }
        if let showSum = showSum {
            aCoder.encodeBool(showSum, forKey: "showSum")
        }
    }
    
    class func getUsersFromJSON(objectJSON: JSON) -> [User] {
        var tempUsers = [User?]()
        
        if let array = objectJSON["data"].arrayObject {
            for item in array {
                let dictionary = item as! NSDictionary
                tempUsers.append(createUser(dictionary))
            }
        } else if let dictionary = objectJSON["data"].dictionaryObject {
            tempUsers.append(createUser(dictionary))
        }
        
        //remote nil users
        return tempUsers.flatMap { $0 }
    }
    
    class func createUser(dictionary: NSDictionary) -> User? {
        let tempID = dictionary["_id"] as! String
        let newUser = User(id: tempID)
        
        newUser.userName = dictionary["username"] as? String
        newUser.displayName = dictionary["displayname"] as? String
        newUser.email = dictionary["email"] as? String
        newUser.avatar = dictionary["avatarUrl"] as? String
        newUser.plans = dictionary["plans"] as? NSArray
        
        if let invites = dictionary["num_invites"] as? String {
            newUser.invites = Int32(invites)
        }
        
        newUser.admin = dictionary["admin"] as? Bool
        newUser.confirmed = dictionary["confirmed"] as? Bool
        newUser.showPlan = dictionary["showplanonboard"] as? Bool
        newUser.showSum = dictionary["showsumonboard"] as? Bool
        
        return newUser
    }
}
