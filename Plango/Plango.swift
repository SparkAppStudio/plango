//
//  CurrentUser.swift
//  DoItLive
//
//  Created by Douglas Hewitt on 3/3/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON

class Plango: NSObject {
    static let sharedInstance = Plango()
    
    enum EndPoint: String {
        case UserByID = "http://www.plango.us/users/"
        case PlanByID = "http://www.plango.us/plans/"
        case FindPlans = "http://www.plango.us/findplans/"
        case AllTags = "http://dev.plango.us/tags"
        case Login = "http://dev.plango.us/login"
        case NewAccount = "http://www.plango.us/createuser"
        case Logout = "http://www.plango.us/logout"
        case AmazonImageRoot = "https://plango-images.s3.amazonaws.com/"
        case Home = "http://www.plango.us/"
        case Report = "http://dev.plango.us/reportSpam/"
    }
    
    let env = NSBundle.mainBundle().infoDictionary!["BASE_ENDPOINT"] as! String
    
    var currentUser: User?
    let alamoManager = Alamofire.Manager.sharedInstance
//    let decoder = ImageDecoder()
    
    
    typealias UsersResponse = ([User]?, NSError?) -> Void
    typealias PlansResponse = ([Plan]?, String?) -> Void
    typealias TagsResponse = ([Tag]?, String?) -> Void
    typealias LoginResponse = (User?, String?) -> Void
//    typealias log = () throws -> User
    typealias ReportSpamResponse = (String?) -> Void
    typealias ImageResponse = (UIImage?, NSError?) -> Void
    
    let photoCache = AutoPurgingImageCache(memoryCapacity: 100 * 1024 * 1024, preferredMemoryUsageAfterPurge: 60 * 1024 * 1024)
    
    
    func cleanEndPoint(endPoint: String) -> String {
        var cleanedEndPoint = endPoint
        if endPoint.lowercaseString.rangeOfString(Plango.EndPoint.AmazonImageRoot.rawValue) == nil {
            if endPoint.lowercaseString.rangeOfString("../") != nil {
                cleanedEndPoint = String(endPoint.characters.dropFirst(3))
            }
            cleanedEndPoint = Plango.EndPoint.Home.rawValue.stringByAppendingString(cleanedEndPoint)
        }
        return cleanedEndPoint
    }
    
    func fetchUsers(endPoint: String, onCompletion: UsersResponse) {
        Alamofire.request(.GET, endPoint).validate().responseJSON { response in
            var receivedUsers = [User]()
            
            switch response.result {
            case .Success(let value):
                
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
                let dataJSON = JSON(value)
                
                receivedUsers = User.getUsersFromJSON(dataJSON)
                onCompletion(receivedUsers, nil)
                
            case .Failure(let error):
                onCompletion(nil, error)
            }
        }
    }
    
    func fetchPlans(endPoint: String, onCompletion: PlansResponse) -> Void {
        Alamofire.request(.GET, endPoint).validate().responseJSON { response in
            switch response.result {
            case .Success(let value):
                let dataJSON = JSON(value)

                onCompletion(Plan.getPlansFromJSON(dataJSON), nil)
            case .Failure(let error):
                onCompletion(nil, error.localizedFailureReason)
            }
        }
    }
    
    func findPlans(endPoint: String, durationFrom: Int?, durationTo: Int?, tags: [Tag]?, selectedPlaces: [[String : String]]?, user: User?, isJapanSearch: Bool?, onCompletion: PlansResponse) {
        
        var parameters: [String : AnyObject] = [:]
        
        let tempParams: [AnyObject?] = [durationFrom, durationTo, tags, selectedPlaces, user, isJapanSearch]
        
        for item in tempParams {
            if let item = item {
                print(item.description)
                parameters[item.description] = item
            }
        }
            
//        if let item = durationFrom {
//            parameters["durationFrom"] = item
//        }
//        if let item = durationTo {
//            parameters["durationTo"] = item
//        }
//        if let item = tags {
//            parameters["tags"] = item
//        }
//        if let item = selectedPlaces {
//            parameters["selectedPlaces"] = item
//        }
//        if let item = user {
//            parameters["user"] = item
//        }
//        if let item = isJapanSearch {
//            parameters["isJapanSearch"] = item
//        }
        
        Alamofire.request(.GET, endPoint, parameters: parameters).validate().responseJSON { response in
            switch response.result {
            case .Success(let value):
                let dataJSON = JSON(value)
                if dataJSON["status"].stringValue == "success" {
                    onCompletion(Plan.getPlansFromJSON(dataJSON), nil)
                } else {
                    var errorString = "failed to get proper error message"
                    
                    let message = dataJSON["message"].stringValue
                    let status = dataJSON["status"].stringValue
                    errorString = "Status: \(status) Message: \(message)"
                    
                    onCompletion(nil, errorString)
                }
            case .Failure(let error):
                onCompletion(nil, error.localizedFailureReason)
            }

        }
    }
    
    func fetchTags(endPoint: String, onCompletion: TagsResponse) -> Void {
        Alamofire.request(.GET, endPoint).validate().responseJSON { response in
            switch response.result {
            case .Success(let value):
                let dataJSON = JSON(value)
                if dataJSON["status"].stringValue == "success" {
                    onCompletion(Tag.getTagsFromJSON(dataJSON), nil)
                } else {
                    var errorString = "failed to get proper error message"
                    
                    let message = dataJSON["message"].stringValue
                    let status = dataJSON["status"].stringValue
                    errorString = "Status: \(status) Message: \(message)"
                    
                    onCompletion(nil, errorString)
                }
                
            case .Failure(let error):
                onCompletion(nil, error.localizedFailureReason)
            }
        }
    }
    
    func fetchImage(endPoint: String, onCompletion: ImageResponse) -> Request {
        return Alamofire.request(.GET, endPoint).validate().responseImage { (response) in
            
            switch response.result {
            case .Success(let image):
                onCompletion(image, nil)
                self.photoCache.addImage(image, withIdentifier: endPoint)
            case .Failure(let error):
                onCompletion(nil, error)
            }
        }
    }
    
    func reportSpam(endPoint: String, planID: String, onCompletion: ReportSpamResponse) -> Void {
        let spamEndPoint = "\(endPoint)\(planID)"
        
        Alamofire.request(.POST, spamEndPoint).validate().responseJSON { response in
            switch response.result {
            case .Success(let value):
                let dataJSON = JSON(value)
                if dataJSON["status"].stringValue == "success" || dataJSON["status"].intValue == 200 {
                    onCompletion(nil)
                } else {
                    onCompletion("User does not exist")
                }
            case .Failure(let error):
                onCompletion(error.localizedFailureReason)
            }
            
//            guard let receivedValue = response.result.value else {
//                onCompletion(receivedUsers, nil)
//                return
//            }
        }
    }
    
    func loginUserWithPassword(endPoint: String, email: String, password: String, onCompletion: LoginResponse) -> Void {
        let parameters = ["email" : email, "password" : password]
        
        Alamofire.request(.POST, endPoint, parameters: parameters).validate().responseJSON { response in
            
            switch response.result {
            case .Success(let value):
                let dataJSON = JSON(value)
                if dataJSON["status"].stringValue == "success" || dataJSON["status"].intValue == 200 {
                    
                    //set cookies for future requests
                    if let headerFields = response.response?.allHeaderFields as? [String: String],
//                        responseURL = response.response?.URL,
                        requestURL = response.request?.URL {
                        let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(headerFields, forURL: requestURL)
                        Alamofire.Manager.sharedInstance.session.configuration.HTTPCookieStorage?.setCookies(cookies, forURL: requestURL, mainDocumentURL: nil)
                    }

                    
                    onCompletion(User.getUsersFromJSON(dataJSON).first, nil)
                } else {
                    var errorString = "failed to get proper error message"
                    
                    let message = dataJSON["message"].stringValue
                    let status = dataJSON["status"].stringValue
                    errorString = "Status: \(status) Message: \(message)"
                    
                    onCompletion(nil, errorString)
                }
                
            case .Failure(let error):
                onCompletion(nil, error.localizedFailureReason)
            }
        }
    }
}
