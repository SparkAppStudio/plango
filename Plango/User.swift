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
    
//    var password: String!
//    var authToken: String!
    
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
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(id, forKey: "id")
        aCoder.encodeObject(userName, forKey: "userName")
    }
    
    class func getUsersFromJSON(objectJSON: JSON) -> [User] {
        var tempUsers = [User?]()

        guard let dictionary = objectJSON["data"].dictionaryObject else {
            return [User]()
        }
        
        tempUsers.append(createUser(dictionary))
        
        //remote nil users
        return tempUsers.flatMap { $0 }
    }
    
    class func createUser(dictionary: NSDictionary) -> User? {
        let tempID = dictionary["_id"] as! String
        let newUser = User(id: tempID)
        
        newUser.userName = dictionary["username"] as? String
        newUser.displayName = dictionary["displayname"] as? String
        newUser.email = dictionary["email"] as? String
//        newUser.password = dictionary["password"] as! String
//        newUser.authToken = dictionary["auth_token"] as! String
        newUser.avatar = dictionary["avatar"] as? String
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
