//
//  Plan.swift
//  Plango
//
//  Created by Douglas Hewitt on 4/8/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class Plan: NSObject {
    var id: String!
    var name: String?
    var avatar: String?
    var planDescription: String?
    var isPublic: Bool?

    var authorID: String!
    
    var durationDays: Int?
    var startDate: NSDate?
    var endDate: NSDate?
    
    var lastViewedDate: NSDate?
    var lastUpdatedDate: NSDate?
    var createdDate: NSDate?
    
    var viewCount: Int?
    var usedCount: Int?
    
    var spamReported: NSArray?
    var members: NSArray?
    var tags: [String]?
    var todos: NSArray?
    var events: NSArray?
    var places: NSArray?
    var experiences: NSArray?
    var plangoFavorite: String?
    
    
    class func getPlansFromJSON(objectJSON: JSON) -> [Plan]? {
        var tempUsers = [Plan?]()
        
        if let array = objectJSON["data"].arrayObject {
            for item in array {
                let dictionary = item as! NSDictionary
                tempUsers.append(createPlan(dictionary))
            }
        } else if let topDictionary = objectJSON["data"].dictionaryObject {
            guard let array = topDictionary["plans"] as? [AnyObject] else {
                print("In \(classForCoder()) failed to parse JSON")
                return nil
            }
            
            for item in array {
                let dictionary = item as! NSDictionary
                tempUsers.append(createPlan(dictionary))
            }
        }
        
        //remote nil users
        return tempUsers.flatMap { $0 }
    }
    
    class func createPlan(dictionary: NSDictionary) -> Plan? {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        let newPlan = Plan()
        newPlan.id = dictionary["_id"] as! String
        newPlan.name = dictionary["name"] as? String
        newPlan.avatar = dictionary["avatarUrl"] as? String
        newPlan.planDescription = dictionary["description"] as? String
        newPlan.isPublic = dictionary["is_public"] as? Bool
        newPlan.authorID = dictionary["created_by"] as! String
        newPlan.durationDays = dictionary["duration"] as? Int

        if let startDate = dictionary["start"] as? String {
            newPlan.startDate = dateFormatter.dateFromString(startDate)
        }
        
        if let endDate = dictionary["end"] as? String {
            newPlan.endDate = dateFormatter.dateFromString(endDate)
        }
        
        if let lastViewed = dictionary["last_viewed"] as? String {
            newPlan.lastViewedDate = dateFormatter.dateFromString(lastViewed)
        }
        
        if let lastUpdated = dictionary["last_updated"] as? String {
            newPlan.lastUpdatedDate = dateFormatter.dateFromString(lastUpdated)
        }
        
        if let createdDate = dictionary["created_date"] as? String {
            newPlan.createdDate = dateFormatter.dateFromString(createdDate)
        }
        
        newPlan.viewCount = dictionary["viewCount"] as? Int
        newPlan.usedCount = dictionary["usedCount"] as? Int
        
        newPlan.spamReported = dictionary["spamReported"] as? NSArray
        newPlan.members = dictionary["members"] as? NSArray
        newPlan.tags = dictionary["tags"] as? [String]
        newPlan.todos = dictionary["todos"] as? NSArray
        newPlan.events = dictionary["events"] as? NSArray
        newPlan.places = dictionary["places"] as? NSArray
        newPlan.experiences = dictionary["experiences"] as? NSArray
        newPlan.plangoFavorite = dictionary["plango_favorite"] as? String
        
        return newPlan
    }
}

struct Destination {
    var city: String?
    var state: String?
    var country: String?
}

struct Duration {
    var minimum: Int
    var maximum: Int
}
