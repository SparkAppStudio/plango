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
        case UserByID = "http://dev.plango.us/users/"
        case PlanByID = "http://dev.plango.us/plans/"
        case FindPlans = "http://dev.plango.us/findplans"
        case AllTags = "http://dev.plango.us/tags"
        case Login = "http://dev.plango.us/login"
        case NewAccount = "http://dev.plango.us/createuser"
        case Logout = "http://dev.plango.us/logout"
        case AmazonImageRoot = "https://plango-images.s3.amazonaws.com/"
        case Home = "http://dev.plango.us/"
        case Report = "http://dev.plango.us/plan/reportSpam/"
        case MyPlans = "http://dev.plango.us/me/plans"
        case SendConfirmation = "http://dev.plango.us/resendconfirmation"
        case FacebookLogin = "http://dev.plango.us/user/Facebook/"
        case PopularDestination = "http://dev.plango.us/findplans?popular_destination=true"
        case PlangoFavorites = "http://dev.plango.us/findplans?plango_favorite=true"
        case PlangoFavsMeta = "http://dev.plango.us/plangofavorites"
    }
    
    let env = NSBundle.mainBundle().infoDictionary!["BASE_ENDPOINT"] as! String
    
    var currentUser: User?
    let alamoManager = Alamofire.Manager.sharedInstance
//    let decoder = ImageDecoder()
    
    
    typealias UsersResponse = ([User]?, PlangoError?) -> Void
    typealias PlansResponse = ([Plan]?, PlangoError?) -> Void
    typealias TagsResponse = ([Tag]?, PlangoError?) -> Void
    typealias LoginResponse = (User?, PlangoError?) -> Void
    typealias PlangoCollectionResponse = ([PlangoCollection]?, PlangoError?) -> Void
//    typealias log = () throws -> User
    typealias ReportSpamResponse = (PlangoError?) -> Void
    typealias ImageResponse = (UIImage?, PlangoError?) -> Void
    
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
    
    func fetchUsers(endPoint: String, onCompletion: UsersResponse) -> Request {
        return Alamofire.request(.GET, endPoint).responseJSON { response in
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
                let newError = PlangoError(statusCode: response.response?.statusCode, message: error.localizedFailureReason)
                onCompletion(nil, newError)
            }
        }
    }
    
    func fetchPlans(endPoint: String, onCompletion: PlansResponse) -> Request {
        return Alamofire.request(.GET, endPoint).validate().responseJSON { response in
            switch response.result {
            case .Success(let value):
                let dataJSON = JSON(value)

                onCompletion(Plan.getPlansFromJSON(dataJSON), nil)
            case .Failure(let error):
                let newError = PlangoError(statusCode: response.response?.statusCode, message: error.localizedFailureReason)

                onCompletion(nil, newError)
            }
        }
    }
    
    func findPlans(endPoint: String, page: Int, parameters: [String : AnyObject], onCompletion: PlansResponse) -> Request {
        
        //pagination
        var newParameters = parameters
        newParameters["maxResults"] = 14
        newParameters["pageNum"] = page
        
        //encoding
        let encodableURLRequest = NSURLRequest(URL: NSURL(string: endPoint)!)
        let encodedURLRequest = ParameterEncoding.URL.encode(encodableURLRequest, parameters: newParameters).0
        
        let mutableURLRequest = NSMutableURLRequest(URL: encodedURLRequest.URL!)
        mutableURLRequest.HTTPMethod = "GET"
        mutableURLRequest.setValue("text/html; charset=utf-8", forHTTPHeaderField: "Content-Type")

        print(mutableURLRequest.URLString)
        
        return Alamofire.request(mutableURLRequest).validate().responseJSON { response in
            print(response.request?.URLString)
            switch response.result {
            case .Success(let value):
                let dataJSON = JSON(value)
                if dataJSON["status"].stringValue == "success" {
                    onCompletion(Plan.getPlansFromJSON(dataJSON), nil)
                } else {
                    
                    let newError = PlangoError(statusCode: response.response?.statusCode, message: dataJSON["message"].stringValue)
                    
                    onCompletion(nil, newError)
                }
            case .Failure(let error):
                let newError = PlangoError(statusCode: response.response?.statusCode, message: error.localizedFailureReason)

                onCompletion(nil, newError)
            }

        }
    }
    
    func buildParameters(minDuration: Int?, maxDuration: Int?, tags: [Tag]?, selectedDestinations: [Destination]?, user: User?, isJapanSearch: Bool?) -> [String:AnyObject] {
        var parameters: [String : AnyObject] = [:]
        
        if let item = minDuration {
            parameters["durationFrom"] = String(item)
        }
        if let item = maxDuration {
            parameters["durationTo"] = String(item)
        }
        if let tags = tags {
            
            var tagString = ""
            
            for item in tags {
                tagString.appendContentsOf("\(item.name!),")
            }
            
            let cleanedTags = String(tagString.characters.dropLast())
            
            parameters["tags"] = cleanedTags
        }
        if let destinations = selectedDestinations {
            var placesString = ""
            
            for item in destinations {
                if let city = item.city {
                    placesString.appendContentsOf("city:\(city),")
                }
                if let state = item.state {
                    placesString.appendContentsOf("state:\(state),")
                }
                if let country = item.country {
                    placesString.appendContentsOf("country:\(country)_")
                }
            }
            
            let cleanedPlaces = String(placesString.characters.dropLast())
            parameters["selectedPlaces"] = cleanedPlaces
        }
        if let item = user {
            parameters["user"] = item.displayName
        }
        if let item = isJapanSearch {
            parameters["isJapanSearch"] = item
        }
        
        return parameters
    }
    
    func fetchPlangoFavoritesMeta(endPoint: String, onCompletion: PlangoCollectionResponse) {
        Alamofire.request(.GET, endPoint).validate().responseJSON { response in
            switch response.result {
            case .Success(let value):
                let dataJSON = JSON(value)
                if dataJSON["status"].stringValue == "success" {
                    onCompletion(PlangoCollection.getPlangoCollectionsFromJSON(dataJSON), nil)
                } else {
                    let newError = PlangoError(statusCode: response.response?.statusCode, message: dataJSON["message"].stringValue)
                    
                    onCompletion(nil, newError)
                }
                
            case .Failure(let error):
                let newError = PlangoError(statusCode: response.response?.statusCode, message: error.localizedFailureReason)
                
                onCompletion(nil, newError)
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
                    let newError = PlangoError(statusCode: response.response?.statusCode, message: dataJSON["message"].stringValue)
                    
                    onCompletion(nil, newError)
                }
                
            case .Failure(let error):
                let newError = PlangoError(statusCode: response.response?.statusCode, message: error.localizedFailureReason)

                onCompletion(nil, newError)
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
                let newError = PlangoError(statusCode: response.response?.statusCode, message: error.localizedFailureReason)

                onCompletion(nil, newError)
            }
        }
    }
    
    func reportSpam(endPoint: String, planID: String, onCompletion: ReportSpamResponse) -> Void {
        let spamEndPoint = "\(endPoint)\(planID)"
        
        Alamofire.request(.POST, spamEndPoint).validate().responseJSON { response in
            print(response.request)
            switch response.result {
            case .Success(let value):
                let dataJSON = JSON(value)
                if dataJSON["status"].stringValue == "success" || dataJSON["status"].intValue == 200 {
                    onCompletion(nil)
                } else {
                    let newError = PlangoError(statusCode: response.response?.statusCode, message: dataJSON["message"].stringValue)
                    
                    onCompletion(newError)
                }
            case .Failure(let error):
                let newError = PlangoError(statusCode: response.response?.statusCode, message: error.localizedFailureReason)
                
                onCompletion(newError)
            }
        }
    }
    
    func confirmEmail(endPoint: String, email: String, onCompletion: ReportSpamResponse) -> Void {
        let parameters = ["email" : email]
        Alamofire.request(.POST, endPoint, parameters: parameters).validate().responseJSON { response in
            switch response.result {
            case .Success(let value):
                let dataJSON = JSON(value)
                if dataJSON["status"].stringValue == "success" || dataJSON["status"].intValue == 200 {
                    onCompletion(nil)
                } else {
                    let newError = PlangoError(statusCode: response.response?.statusCode, message: dataJSON["message"].stringValue)
                    
                    onCompletion(newError)
                }
            case .Failure(let error):
                let newError = PlangoError(statusCode: response.response?.statusCode, message: error.localizedFailureReason)
                
                onCompletion(newError)
            }
        }
    }
    
    func authPlangoUser(endPoint: String, parameters: [String:AnyObject]?, onCompletion: LoginResponse) -> Void {
        
        Alamofire.request(.POST, endPoint, parameters: parameters).responseJSON { response in
            print("The request is \(response.request)")
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
                    let newError = PlangoError(statusCode: response.response?.statusCode, message: dataJSON["message"].stringValue)
                    onCompletion(nil, newError)
                }
                
            case .Failure(let error):
                let newError = PlangoError(statusCode: response.response?.statusCode, message: error.localizedFailureReason)
                
                onCompletion(nil, newError)
            }
        }
    }
    
}

struct PlangoError {
    var statusCode: Int?
    var message: String?
}
