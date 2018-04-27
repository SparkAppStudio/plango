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
//    var facebookAvatar: String?
    
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
       let tempID = aDecoder.decodeObject(forKey: "id") as! String
        self.init(id: tempID)
        self.userName = aDecoder.decodeObject(forKey: "userName") as? String
        self.displayName = aDecoder.decodeObject(forKey: "displayName") as? String
        self.email = aDecoder.decodeObject(forKey: "email") as? String
        self.avatar = aDecoder.decodeObject(forKey: "avatar") as? String
        self.plans = aDecoder.decodeObject(forKey: "plans") as? NSArray
        self.invites = aDecoder.decodeInt32(forKey: "invites")
        self.admin = aDecoder.decodeBool(forKey: "admin")
        self.confirmed = aDecoder.decodeBool(forKey: "confirmed")
        self.showPlan = aDecoder.decodeBool(forKey: "showPlan")
        self.showSum = aDecoder.decodeBool(forKey: "showSum")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(userName, forKey: "userName")
        aCoder.encode(displayName, forKey: "displayName")
        aCoder.encode(email, forKey: "email")
        aCoder.encode(avatar, forKey: "avatar")
        aCoder.encode(plans, forKey: "plans")
        if let invites = invites {
            aCoder.encode(invites, forKey: "invites")
        }
        if let admin = admin {
            aCoder.encode(admin, forKey: "admin")
        }
        if let confirmed = confirmed {
            aCoder.encode(confirmed, forKey: "confirmed")
        }
        if let showPlan = showPlan {
            aCoder.encode(showPlan, forKey: "showPlan")
        }
        if let showSum = showSum {
            aCoder.encode(showSum, forKey: "showSum")
        }
    }
    
    class func getUsersFromJSON(_ objectJSON: JSON) -> [User] {
        var tempUsers = [User?]()
        
        if let array = objectJSON["data"].arrayObject {
            for item in array {
                let dictionary = item as! NSDictionary
                tempUsers.append(createUser(dictionary))
            }
        } else if let dictionary = objectJSON["data"].dictionaryObject {
            tempUsers.append(createUser(dictionary as NSDictionary))
        }
        
        //remote nil users
        return tempUsers.compactMap { $0 }
    }
    
    class func createUser(_ dictionary: NSDictionary) -> User? {
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
        
//        if Plango.sharedInstance.facebookAvatarURL != "" {
//            newUser.facebookAvatar = Plango.sharedInstance.facebookAvatarURL
//        }
        
        return newUser
    }
}
