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
    let env = Bundle.main.infoDictionary!["BASE_ENDPOINT"] as! String

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
        case Members = "http://dev.plango.us/members"
        
        var value: String {
            switch self {
            case .UserByID: return "https://\(Plango.sharedInstance.env)/users/"
            case .PlanByID: return "https://\(Plango.sharedInstance.env)/plans/"
            case .FindPlans: return "https://\(Plango.sharedInstance.env)/findplans"
            case .AllTags: return "https://\(Plango.sharedInstance.env)/tags"
            case .Login: return "https://\(Plango.sharedInstance.env)/login"
            case .NewAccount: return "https://\(Plango.sharedInstance.env)/createuser"
            case .Logout: return "https://\(Plango.sharedInstance.env)/logout"
            case .AmazonImageRoot: return "https://plango-images.s3.amazonaws.com/"
            case .Home: return "https://\(Plango.sharedInstance.env)/"
            case .Report: return "https://\(Plango.sharedInstance.env)/plan/reportSpam/"
            case .MyPlans: return "https://\(Plango.sharedInstance.env)/me/plans"
            case .SendConfirmation: return "https://\(Plango.sharedInstance.env)/resendconfirmation"
            case .FacebookLogin: return "https://\(Plango.sharedInstance.env)/user/Facebook/"
            case .PopularDestination: return "https://\(Plango.sharedInstance.env)/findplans?popular_destination=true"
            case .PlangoFavorites: return "https://\(Plango.sharedInstance.env)/findplans?plango_favorite=true"
            case .PlangoFavsMeta: return "https://\(Plango.sharedInstance.env)/plangofavorites"
            case .Members: return "https://\(Plango.sharedInstance.env)/members"

            }
        }
    }
    
    var currentUser: User?
    let alamoManager = Alamofire.Manager.sharedInstance
//    let decoder = ImageDecoder()
//    lazy var facebookAvatarURL = String()
    var searchTotal: Int?

    
    typealias UsersResponse = ([User]?, PlangoError?) -> Void
    typealias PlansResponse = ([Plan]?, PlangoError?) -> Void
    typealias TagsResponse = ([Tag]?, PlangoError?) -> Void
    typealias LoginResponse = (User?, PlangoError?) -> Void
    typealias PlangoCollectionResponse = ([PlangoCollection]?, PlangoError?) -> Void
//    typealias log = () throws -> User
    typealias ReportSpamResponse = (PlangoError?) -> Void
    typealias ImageResponse = (UIImage?, PlangoError?) -> Void
    
    //memory usage scales to physical memory available on device
    let photoCache = AutoPurgingImageCache(memoryCapacity: ProcessInfo.processInfo.physicalMemory/5, preferredMemoryUsageAfterPurge: ProcessInfo.processInfo.physicalMemory/10)
    
    
    var userCache = [String : User]()

    func cleanEndPoint(_ endPoint: String) -> String {
        var cleanedEndPoint = endPoint
        if endPoint.lowercased().range(of: "http") == nil {
            if endPoint.lowercased().range(of: "../") != nil {
                cleanedEndPoint = String(endPoint.characters.dropFirst(3))
            }
            if endPoint.characters.first == "/" {
                cleanedEndPoint = String(endPoint.characters.dropFirst())
            }
            cleanedEndPoint = Plango.EndPoint.Home.value + cleanedEndPoint
        }
                
        return cleanedEndPoint
    }
    
    func thumbEndPoint(_ endPoint: String) -> String {
        var cleanString = cleanEndPoint(endPoint)
        let index = cleanString.range(of: "/", options:NSString.CompareOptions.backwards)?.upperBound
        //            let index = cleanString.startIndex.distanceTo(range!.startIndex)
        
        cleanString.insert(contentsOf: "thumb/".characters, at: index!)
        return cleanString
    }
    
    func fetchUsers(_ endPoint: String, onCompletion: UsersResponse) -> Request {
        return Alamofire.request(.GET, endPoint).responseJSON { response in
            var receivedUsers = [User]()
            
            switch response.result {
            case .success(let value):
                
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
                
            case .failure(let error):
                let newError = PlangoError(statusCode: response.response?.statusCode, message: error.localizedFailureReason)
                onCompletion(nil, newError)
            }
        }
    }
    
    func fetchMembersFromPlan(_ endPoint: String, members: [Member], onCompletion: UsersResponse) -> Request {

        var memberIDs = [String]()
        for member in members {
            memberIDs.append(member.id)
        }
        
        let encodableURLRequest = URLRequest(url: URL(string: endPoint)!)

        let mutableURLRequest = NSMutableURLRequest(url: encodableURLRequest.url!)
        mutableURLRequest.httpMethod = "POST"
        mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        mutableURLRequest.httpBody = try! JSONSerialization.data(withJSONObject: memberIDs, options: [])
        
        
        return Alamofire.request(mutableURLRequest).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let dataJSON = JSON(value)
                if dataJSON["status"].stringValue == "success" || dataJSON["status"].intValue == 200 {
                    let receivedUsers = User.getUsersFromJSON(dataJSON)

                    onCompletion(receivedUsers, nil)
                } else {
                    let newError = PlangoError(statusCode: response.response?.statusCode, message: dataJSON["message"].stringValue)
                    
                    onCompletion(nil, newError)
                }
            case .failure(let error):
                let newError = PlangoError(statusCode: response.response?.statusCode, message: error.localizedFailureReason)
                
                onCompletion(nil, newError)
            }

        }
    }
    
    func fetchPlans(_ endPoint: String, onCompletion: PlansResponse) -> Request {
        return Alamofire.request(.GET, endPoint).validate().responseJSON { response in
            print(response.request?.URLString)

            switch response.result {
            case .success(let value):
                let dataJSON = JSON(value)

                onCompletion(Plan.getPlansFromJSON(dataJSON), nil)
            case .failure(let error):
                let newError = PlangoError(statusCode: response.response?.statusCode, message: error.localizedFailureReason)

                onCompletion(nil, newError)
            }
        }
    }
    
    func findPlans(_ endPoint: String, page: Int, parameters: [String : AnyObject], onCompletion: PlansResponse) -> Request {
        
        //pagination
        var newParameters = parameters
        newParameters["maxResults"] = 14
        newParameters["pageNum"] = page
        
        //encoding
        let encodableURLRequest = URLRequest(url: URL(string: endPoint)!)
        let encodedURLRequest = ParameterEncoding.url.encode(encodableURLRequest, parameters: newParameters).0
        
        let mutableURLRequest = NSMutableURLRequest(url: encodedURLRequest.url!)
        mutableURLRequest.httpMethod = "GET"
        mutableURLRequest.setValue("text/html; charset=utf-8", forHTTPHeaderField: "Content-Type")

        print(mutableURLRequest.URLString)
        
        return Alamofire.request(mutableURLRequest).validate().responseJSON { response in
            print(response.request?.URLString)
            switch response.result {
            case .success(let value):
                let dataJSON = JSON(value)
                if dataJSON["status"].stringValue == "success" {
                    onCompletion(Plan.getPlansFromJSON(dataJSON), nil)
                } else {
                    
                    let newError = PlangoError(statusCode: response.response?.statusCode, message: dataJSON["message"].stringValue)
                    
                    onCompletion(nil, newError)
                }
            case .failure(let error):
                let newError = PlangoError(statusCode: response.response?.statusCode, message: error.localizedFailureReason)

                onCompletion(nil, newError)
            }

        }
    }
    
    func buildParameters(_ minDuration: Int?, maxDuration: Int?, tags: [Tag]?, selectedDestinations: [Destination]?, user: User?, isJapanSearch: Bool?) -> [String:AnyObject] {
        var parameters: [String : AnyObject] = [:]
        
        if let item = minDuration {
            parameters["durationFrom"] = String(item) as AnyObject?
        }
        if let item = maxDuration {
            parameters["durationTo"] = String(item) as AnyObject?
        }
        if let tags = tags {
            
            var tagString = ""
            
            for item in tags {
                tagString.append("\(item.name!),")
            }
            
            let cleanedTags = String(tagString.characters.dropLast())
            
            parameters["tags"] = cleanedTags as AnyObject?
        }
        if let destinations = selectedDestinations {
            var placesString = ""
            
            for item in destinations {
                if let city = item.city {
                    placesString.append("city:\(city),")
                }
                if let state = item.state {
                    if let country = item.country { //if you have both check for district bug
                        if state != "\(country) District" { //this is necessary for some international places bc google does weird things
                            placesString.append("state:\(state),")
                        }
                    } else { //if no country let state pass as normal
                        placesString.append("state:\(state),")
                    }

                }
                if let country = item.country {
                    placesString.append("country:\(country)_")
                }
            }
            
            let cleanedPlaces = String(placesString.characters.dropLast())
            parameters["selectedPlaces"] = cleanedPlaces as AnyObject?
        }
        if let item = user {
            parameters["user"] = item.displayName as AnyObject?
        }
        if let item = isJapanSearch {
            parameters["isJapanSearch"] = item as AnyObject?
        }
        
        return parameters
    }
    
    func fetchPlangoFavoritesMeta(_ endPoint: String, onCompletion: @escaping PlangoCollectionResponse) {
        Alamofire.request(.GET, endPoint).validate().responseJSON { response in
            print(response.request?.URLString)

            switch response.result {
            case .success(let value):
                let dataJSON = JSON(value)
                if dataJSON["status"].stringValue == "success" {
                    onCompletion(PlangoCollection.getPlangoCollectionsFromJSON(dataJSON), nil)
                } else {
                    let newError = PlangoError(statusCode: response.response?.statusCode, message: dataJSON["message"].stringValue)
                    
                    onCompletion(nil, newError)
                }
                
            case .failure(let error):
                let newError = PlangoError(statusCode: response.response?.statusCode, message: error.localizedFailureReason)
                
                onCompletion(nil, newError)
            }
        }
    }
    
    func fetchTags(_ endPoint: String, onCompletion: @escaping TagsResponse) -> Void {
        Alamofire.request(.GET, endPoint).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let dataJSON = JSON(value)
                if dataJSON["status"].stringValue == "success" {
                    onCompletion(Tag.getTagsFromJSON(dataJSON), nil)
                } else {
                    let newError = PlangoError(statusCode: response.response?.statusCode, message: dataJSON["message"].stringValue)
                    
                    onCompletion(nil, newError)
                }
                
            case .failure(let error):
                let newError = PlangoError(statusCode: response.response?.statusCode, message: error.localizedFailureReason)

                onCompletion(nil, newError)
            }
        }
    }
    
    func fetchImage(_ endPoint: String, onCompletion: ImageResponse) -> Request {
        return Alamofire.request(.GET, endPoint).validate().responseImage { (response) in
            
            switch response.result {
            case .success(let image):
                onCompletion(image, nil)
                self.photoCache.addImage(image, withIdentifier: endPoint)
            case .failure(let error):
                let newError = PlangoError(statusCode: response.response?.statusCode, message: error.localizedFailureReason)

                onCompletion(nil, newError)
            }
        }
    }
    
    func reportSpam(_ endPoint: String, planID: String, onCompletion: @escaping ReportSpamResponse) -> Void {
        let spamEndPoint = "\(endPoint)\(planID)"
        
        Alamofire.request(.POST, spamEndPoint).validate().responseJSON { response in
            print(response.request)
            switch response.result {
            case .success(let value):
                let dataJSON = JSON(value)
                if dataJSON["status"].stringValue == "success" || dataJSON["status"].intValue == 200 {
                    onCompletion(nil)
                } else {
                    let newError = PlangoError(statusCode: response.response?.statusCode, message: dataJSON["message"].stringValue)
                    
                    onCompletion(newError)
                }
            case .failure(let error):
                let newError = PlangoError(statusCode: response.response?.statusCode, message: error.localizedFailureReason)
                
                onCompletion(newError)
            }
        }
    }
    
    func confirmEmail(_ endPoint: String, email: String, onCompletion: @escaping ReportSpamResponse) -> Void {
        let parameters = ["email" : email]
        Alamofire.request(.POST, endPoint, parameters: parameters).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let dataJSON = JSON(value)
                if dataJSON["status"].stringValue == "success" || dataJSON["status"].intValue == 200 {
                    onCompletion(nil)
                } else {
                    let newError = PlangoError(statusCode: response.response?.statusCode, message: dataJSON["message"].stringValue)
                    
                    onCompletion(newError)
                }
            case .failure(let error):
                let newError = PlangoError(statusCode: response.response?.statusCode, message: error.localizedFailureReason)
                
                onCompletion(newError)
            }
        }
    }
    
    func authPlangoUser(_ endPoint: String, parameters: [String:AnyObject]?, onCompletion: @escaping LoginResponse) -> Void {
        
        Alamofire.request(.POST, endPoint, parameters: parameters).responseJSON { response in
            print("The request is \(response.request)")
            switch response.result {
            case .success(let value):
                let dataJSON = JSON(value)
                if dataJSON["status"].stringValue == "success" || dataJSON["status"].intValue == 200 {
                    
                    //set cookies for future requests
                    if let headerFields = response.response?.allHeaderFields as? [String: String],
//                        responseURL = response.response?.URL,
                        let requestURL = response.request?.url {
                        let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: requestURL)
                        Alamofire.Manager.sharedInstance.session.configuration.httpCookieStorage?.setCookies(cookies, for: requestURL, mainDocumentURL: nil)
                    }

                    
                    onCompletion(User.getUsersFromJSON(dataJSON).first, nil)
                } else {
                    let newError = PlangoError(statusCode: response.response?.statusCode, message: dataJSON["message"].stringValue)
                    onCompletion(nil, newError)
                }
                
            case .failure(let error):
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
