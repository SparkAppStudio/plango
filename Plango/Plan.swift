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
    
    var startDate: NSDate?
    var endDate: NSDate?
    var durationDays: Int32?
    
    var lastViewedDate: NSDate?
    var lastUpdatedDate: NSDate?
    var createdDate: NSDate?
    
    var spamReported: NSArray?
    var members: NSArray?
    var tags: [String]?
    var todos: NSArray?
    var events: NSArray?
    var places: NSArray?
    var experiences: NSArray?
    
    
    class func getPlansFromJSON(objectJSON: JSON) -> [Plan] {
        var tempUsers = [Plan?]()
        
        guard let array = objectJSON["data"].arrayObject else {
            return [Plan]()
        }
        
        for item in array {
            let dictionary = item as! NSDictionary
            tempUsers.append(createPlan(dictionary))
        }
        
        //remote nil users
        return tempUsers.flatMap { $0 }
    }
    
    class func createPlan(dictionary: NSDictionary) -> Plan? {

        let newPlan = Plan()
        newPlan.id = dictionary["_id"] as! String
        newPlan.name = dictionary["name"] as? String
        newPlan.avatar = dictionary["avatarUrl"] as? String
        newPlan.planDescription = dictionary["description"] as? String
        newPlan.isPublic = dictionary["is_public"] as? Bool
        newPlan.authorID = dictionary["created_by"] as! String
        
        newPlan.startDate = dictionary["start"] as? NSDate
        let date = NSDateFormatter()
        date.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        newPlan.endDate = dictionary["end"] as? NSDate
        
        if let duration = dictionary["duration"] as? String {
            newPlan.durationDays = Int32(duration)
        }
    
        
        newPlan.lastViewedDate = dictionary["last_viewed"] as? NSDate
        newPlan.lastUpdatedDate = dictionary["last_updated"] as? NSDate
        newPlan.createdDate = dictionary["created_date"] as? NSDate
        
        newPlan.spamReported = dictionary["spamReported"] as? NSArray
        newPlan.members = dictionary["members"] as? NSArray
        newPlan.tags = dictionary["tags"] as? [String]
        newPlan.todos = dictionary["todos"] as? NSArray
        newPlan.events = dictionary["events"] as? NSArray
        newPlan.places = dictionary["places"] as? NSArray
        newPlan.experiences = dictionary["experiences"] as? NSArray
        
        return newPlan
    }
}
