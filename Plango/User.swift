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

class User: NSObject {
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
        let newUser = User()
        newUser.id = dictionary["_id"] as! String
        newUser.userName = dictionary["username"] as? String
        newUser.displayName = dictionary["displayname"] as? String
        newUser.email = dictionary["email"] as? String
//        newUser.password = dictionary["password"] as! String
//        newUser.authToken = dictionary["auth_token"] as! String
        newUser.avatar = dictionary["avatar"] as? String
        newUser.plans = dictionary["plans"] as? NSArray
        newUser.invites = dictionary["num_invites"] as? Int32
        newUser.admin = dictionary["admin"] as? Bool
        newUser.confirmed = dictionary["confirmed"] as? Bool
        newUser.showPlan = dictionary["showplanonboard"] as? Bool
        newUser.showSum = dictionary["showsumonboard"] as? Bool
        
        return newUser
    }
}
