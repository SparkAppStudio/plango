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
    var mongoUsersLocation = "server address"
    
    typealias UsersResponse = ([User]?, NSError?) -> Void
    
    func fetchUsers(onCompletion: UsersResponse) {
        Alamofire.request(.GET, mongoUsersLocation).validate().responseString { response in
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
