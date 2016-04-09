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
    var userName: String!
    var displayName: String!
    var email: String!
    
    var password: String!
    var authToken: String!
    
    var avatar: NSData!
    
    var plans: NSArray!
    
    var invites: Int32!
    var admin: Bool!
    var confirmed: Bool!
    var showPlan: Bool!
    var showSumon: Bool!
    
    class func getUsersFromJSON(objectJSON: JSON) -> [User] {
        var tempUsers = [User?]()
        
        guard let array = objectJSON["parentKey"]["usersKey"].arrayObject else {
            return [User]()
        }
        
        for dataObject: AnyObject in array {
            guard let dict = dataObject as? NSDictionary else {
                continue
            }
            tempUsers.append(createUser(dict))
        }
        
        //remote nil users
        return tempUsers.flatMap { $0 }
    }
    
    class func createUser(dict: NSDictionary) -> User? {
        //TODO: - parse JSON return User
    }
}
