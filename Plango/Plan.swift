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
    
    var spamReported: [String]?
    var members: [Member]?
    var tags: [String]?
    var todos: [Todo]?
    var events: [Event]?
    var places: [Place]?
    var experiences: [Experience]?
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
        
        newPlan.spamReported = dictionary["spamReported"] as? [String]
        newPlan.members = dictionary["members"] as? [Member]
        newPlan.tags = dictionary["tags"] as? [String]
        newPlan.todos = dictionary["todos"] as? [Todo]
        newPlan.events = dictionary["events"] as? [Event]
        newPlan.places = dictionary["places"] as? [Place]
        newPlan.experiences = dictionary["experiences"] as? [Experience]
        newPlan.plangoFavorite = dictionary["plango_favorite"] as? String
        
        return newPlan
    }
}

struct Member { //"_id":"558b8126817ff2433428d992","confirmed":true
    var userID: String
    var confirmed: String
}

struct Todo { //"done":false,"todoitem":"book hotels/hostels","_id":"56131ece0fdcab250243fb3f"
    var id: String
    var item: String
    var done: String
}

struct Event { //"experience_id":"560de35905c85ada730e7f14","start":"2015-11-21T13:00:00.000Z","all_day":false,"_id":"560f546f0fdcab250243f6f7","duration":5400
    var id: String
    var experienceID: String
    var duration: Int
    var startDate: NSDate
    var allDay: Bool
}

struct Place { //"state":"Alajuela","country":"Costa Rica","_id":"560de21405c85ada730e7f04","city":"La Fortuna","notes":"Volcano and hot springs. Book a boat taxi to and from Monteverde because there is no direct driving route.","start":"2015-11-21T08:00:00.000Z","end":"2015-11-22T08:00:00.000Z","duration":2
    var id: String
    var city: String
    var state: String
    var country: String
    var notes: String
    var startDate: NSDate
    var endDate: NSDate
    var durationDays: Int
}

struct Experience { //"name":"PRO rafting Costa Rica","thumb":"http://placehold.it/160x100&text=image","address":"","city":"","state":"","country":"Costa Rica","created_by":"558b8126817ff2433428d992","url":"","rating":"","description":"","notes":"http://www.anywherecostarica.com/destinations/manuel-antonio/tours/whitewater-rafting-savegre\n                        \n                        ","phone":"","tip_count":0,"price":null,"likes":0,"place_id":"5221f7ac11d2c4664aafcbc7","_id":"56131b390fdcab250243fb1c","location_type":"River","is_public":true,"isCustom":false,"photos":[],"hours":[],"reviews":[],"geocode":[9.426961611091167,-84.1584320386772]
    var id: String
    var placeID: String
    var authorID: String
    var name: String
    var avatar: String
    var address: String
    var city: String
    var state: String
    var country: String
    var url: String
    var rating: String
    var description: String
    var notes: String
    var phone: String
    var tipCount: Int
    var price: Int
    var likes: Int
    var locationType: String
    var isPublic: Bool
    var isCustom: Bool
    var photos: NSArray
    var hours: NSArray
    var reviews: NSArray
    var geocode: [Float]
    
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
