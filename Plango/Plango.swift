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
    
    enum Address: String {
        case Home = "http://www.plango.us/"
        case HomeSecure = "https://www.plango.us/"
        case Users = "users/"
        case Plans = "plans/"
    }
    
    var currentUser: User!
    
    typealias UsersResponse = ([User]?, NSError?) -> Void
    typealias PlansResponse = ([Plan]?, NSError?) -> Void
    typealias TagsResponse = ([Tag]?, NSError?) -> Void
    
    func fetchUsers(location: String, onCompletion: UsersResponse) {
        Alamofire.request(.GET, location).validate().responseJSON { response in
            var receivedUsers = [User]()
            
            switch response.result {
            case .Success(let dataJSON):
                
                //the verbose way, using generic response from Alamofire. Checks if the data may arrive but be empty, otherwise unnecessary
                
//                guard let receivedValue = response.result.value else {
//                    onCompletion(receivedUsers, nil)
//                    return
//                }
//                guard let receivedData = receivedValue.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) else {
//                    onCompletion(receivedUsers, nil)
//                    return
//                }
//                
//                let theJSON = JSON(data: receivedData)
                
                let theJSON = JSON(dataJSON)
                
                receivedUsers = User.getUsersFromJSON(theJSON)
                onCompletion(receivedUsers, nil)
                
            case .Failure(let error):
                onCompletion(nil, error)
            }
        }
    }
    
    func fetchPlans(location: String, onCompletion: PlansResponse) -> Void {
        Alamofire.request(.GET, location).validate().responseJSON { response in
            switch response.result {
            case .Success(let dataJSON):
                onCompletion(Plan.getPlansFromJSON(JSON(dataJSON)), nil)
            case .Failure(let error):
                onCompletion(nil, error)
            }
        }
    }
    
    func fetchTags(location: String, onCompletion: TagsResponse) -> Void {
        Alamofire.request(.GET, location).validate().responseJSON { response in
            switch response.result {
            case .Success(let dataJSON):
                onCompletion(Tag.getTagsFromJSON(JSON(dataJSON)), nil)
            case .Failure(let error):
                onCompletion(nil, error)
            }
        }
    }
}
