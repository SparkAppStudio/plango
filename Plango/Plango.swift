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
    
    enum EndPoint: String {
        case UserByID = "http://www.plango.us/users/"
        case PlanByID = "http://www.plango.us/plans/"
        case FindPlans = "http://www.plango.us/findplans/"
        case AllTags = "http://www.plango.us/tags"
//        case Login = "http://www.plango.us/login"
        case Login = "http://dc65be72.ngrok.io/login"
        case NewAccount = "https://www.plango.us/createuser"
        case Logout = "https://www.plango.us/logout"
    }
    
    var currentUser: User?
    
    typealias UsersResponse = ([User]?, NSError?) -> Void
    typealias PlansResponse = ([Plan]?, NSError?) -> Void
    typealias TagsResponse = ([Tag]?, NSError?) -> Void
    typealias LoginResponse = (User?, NSError?) -> Void
    
    func fetchUsers(endPoint: String, onCompletion: UsersResponse) {
        Alamofire.request(.GET, endPoint).validate().responseJSON { response in
            var receivedUsers = [User]()
            
            switch response.result {
            case .Success(let dataJSON):
                
                // MARK: - NOTE: the verbose way
                //using generic response from Alamofire. Checks if the data may arrive but be empty, otherwise unnecessary
                
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
    
    func fetchPlans(endPoint: String, onCompletion: PlansResponse) -> Void {
        Alamofire.request(.GET, endPoint).validate().responseJSON { response in
            switch response.result {
            case .Success(let dataJSON):
                onCompletion(Plan.getPlansFromJSON(JSON(dataJSON)), nil)
            case .Failure(let error):
                onCompletion(nil, error)
            }
        }
    }
    
    func fetchTags(endPoint: String, onCompletion: TagsResponse) -> Void {
        Alamofire.request(.GET, endPoint).validate().responseJSON { response in
            switch response.result {
            case .Success(let dataJSON):
                onCompletion(Tag.getTagsFromJSON(JSON(dataJSON)), nil)
            case .Failure(let error):
                onCompletion(nil, error)
            }
        }
    }
    
    func loginUserWithPassword(endPoint: String, email: String, password: String, onCompletion: LoginResponse) -> Void {
        let parameters = ["email" : email, "password" : password]
        
        Alamofire.request(.POST, endPoint, parameters: parameters).responseJSON { response in
//            print(response)
//            print(response.debugDescription)
//            print(response.description)
//            print(response.response)
//            print(response.result)
//            print(response.result.debugDescription)
//            print(response.result.description)
//            print(response.result.error)
            
            switch response.result {
            case .Success(let value):
                let dataJSON = JSON(value)
                if dataJSON["status"].stringValue == "success" {
                    onCompletion(User.getUsersFromJSON(dataJSON).first, nil)
                } else {
                    onCompletion(nil, nil)
                }
                
            case .Failure(let error):
                onCompletion(nil, error)
            }
        }
    }
}
