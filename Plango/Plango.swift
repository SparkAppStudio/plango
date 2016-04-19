//
//  CurrentUser.swift
//  DoItLive
//
//  Created by Douglas Hewitt on 3/3/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class Plango: NSObject {
    static let sharedInstance = Plango()
    
    var currentUser: User!
    
    typealias UsersResponse = ([User]?, NSError?) -> Void
    
    func findUserFromID(id: String) -> User? {
        var aUser = User()
        fetchObjects("http://www.plango.us/users/\(id)") {
            (receivedUsers: [User]?, error: NSError?) in
            if let error = error {
                print(error.description)
            } else if let users = receivedUsers {
                aUser = users.first!
            }
        }
        return aUser
    }
    
    func fetchObjects(location: String, onCompletion: UsersResponse) {
        Alamofire.request(.GET, location).validate().responseString { response in
            var receivedUsers = [User]()
            switch response.result {
            case .Success:
                guard let receivedValue = response.result.value else {
                    onCompletion(receivedUsers, nil)
                    return
                }
                guard let receivedData = receivedValue.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) else {
                    onCompletion(receivedUsers, nil)
                    return
                }
                
                let objectJSON = JSON(data: receivedData)
                
                receivedUsers = User.getUsersFromJSON(objectJSON)
                onCompletion(receivedUsers, nil)
                
            case .Failure(let error):
                onCompletion(nil, error)
            }
        }
    }
}
