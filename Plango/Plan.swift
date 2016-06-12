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
        
        
        if let members = dictionary["members"] as? [[String:AnyObject]] {
            for member in members {
                let userID = member["_id"] as! String
                let confirmed = member["confirmed"] as! Bool
                
                let aMember = Member(userID: userID, confirmed: confirmed)
                newPlan.members?.append(aMember)
            }
        }
        
        newPlan.tags = dictionary["tags"] as? [String]
                
        if let todos = dictionary["todos"] as? [[String:AnyObject]] {
            newPlan.todos = [Todo]()
            for todo in todos {
                let id = todo["_id"] as! String
                let item = todo["todoitem"] as! String
                let done = todo["done"] as! Bool
                
                let aTodo = Todo(id: id, item: item, done: done)
                newPlan.todos?.append(aTodo)
            }
        }
        
        if let events = dictionary["events"] as? [[String:AnyObject]] {
            newPlan.events = [Event]()
            for event in events {
                let id = event["_id"] as! String
                let experienceID = event["experience_id"] as! String
                let duration = event["duration"] as? Int
                let allDay = event["all_day"] as? Bool

                var startDate: NSDate? = nil
                if let start = event["start"] as? String {
                    startDate = dateFormatter.dateFromString(start)
                }
                
                let anEvent = Event(id: id, experienceID: experienceID, duration: duration, startDate: startDate, allDay: allDay)
                newPlan.events?.append(anEvent)
            }
        }
        
        if let places = dictionary["places"] as? [[String:AnyObject]] {
            newPlan.places = [Place]()
            for place in places {
                let id = place["_id"] as! String
                let city = place["city"] as? String
                let state = place["state"] as? String
                let country = place["country"] as? String
                let notes = place["notes"] as? String
                let duration = place["duration"] as? Int

                var startDate: NSDate? = nil
                if let start = place["start"] as? String {
                    startDate = dateFormatter.dateFromString(start)
                }
        
                var endDate: NSDate? = nil
                if let end = place["end"] as? String {
                    endDate = dateFormatter.dateFromString(end)
                }
                
                let aPlace = Place(id: id, city: city, state: state, country: country, notes: notes, startDate: startDate, endDate: endDate, durationDays: duration)
                newPlan.places?.append(aPlace)
            }
        }
        
        if let experiences = dictionary["experiences"] as? [[String:AnyObject]] {
            newPlan.experiences = [Experience]()
            for experience in experiences {
                let id = experience["_id"] as! String
                let placeID = experience["place_id"] as? String
                let authorID = experience["created_by"] as? String
                let name = experience["name"] as? String
                let avatar = experience["thumb"] as? String
                let address = experience["address"] as? String
                let city = experience["city"] as? String
                let state = experience["state"] as? String
                let country = experience["country"] as? String
                let url = experience["url"] as? String
                let rating = experience["rating"] as? String
                let description = experience["description"] as? String
                let notes = experience["notes"] as? String
                let phone = experience["phone"] as? String
                let tipCount = experience["tip_count"] as? Int
                let price = experience["price"] as? Int
                let likes = experience["likes"] as? Int
                let locationType = experience["location_type"] as? String
                let isPublic = experience["is_public"] as? Bool
                let isCustom = experience["isCustom"] as? Bool
                let photos = experience["photos"] as? NSArray
                let hours = experience["hours"] as? NSArray
                let reviews = experience["reviews"] as? NSArray
                let geoArr = experience["geocode"] as? [Float]
                
                let anExperience = Experience(id: id, placeID: placeID, authorID: authorID, name: name, avatar: avatar, address: address, city: city, state: state, country: country, url: url, rating: rating, experienceDescription: description, notes: notes, phone: phone, tipCount: tipCount, price: price, likes: likes, locationType: locationType, isPublic: isPublic, isCustom: isCustom, photos: photos, hours: hours, reviews: reviews, geocode: geoArr)
                newPlan.experiences?.append(anExperience)
            }
        }
        
        newPlan.plangoFavorite = dictionary["plango_favorite"] as? String
        
        return newPlan
    }
}

struct Member { //"_id":"558b8126817ff2433428d992","confirmed":true
    var userID: String
    var confirmed: Bool
}

struct Todo { //"done":false,"todoitem":"book hotels/hostels","_id":"56131ece0fdcab250243fb3f"
    var id: String
    var item: String
    var done: Bool
}

struct Event { //"experience_id":"560de35905c85ada730e7f14","start":"2015-11-21T13:00:00.000Z","all_day":false,"_id":"560f546f0fdcab250243f6f7","duration":5400
    var id: String
    var experienceID: String?
    var duration: Int?
    var startDate: NSDate?
    var allDay: Bool?
}

struct Place { //"state":"Alajuela","country":"Costa Rica","_id":"560de21405c85ada730e7f04","city":"La Fortuna","notes":"Volcano and hot springs. Book a boat taxi to and from Monteverde because there is no direct driving route.","start":"2015-11-21T08:00:00.000Z","end":"2015-11-22T08:00:00.000Z","duration":2
    var id: String
    var city: String?
    var state: String?
    var country: String?
    var notes: String?
    var startDate: NSDate?
    var endDate: NSDate?
    var durationDays: Int?
}

struct Experience { //"name":"PRO rafting Costa Rica","thumb":"http://placehold.it/160x100&text=image","address":"","city":"","state":"","country":"Costa Rica","created_by":"558b8126817ff2433428d992","url":"","rating":"","description":"","notes":"http://www.anywherecostarica.com/destinations/manuel-antonio/tours/whitewater-rafting-savegre\n                        \n                        ","phone":"","tip_count":0,"price":null,"likes":0,"place_id":"5221f7ac11d2c4664aafcbc7","_id":"56131b390fdcab250243fb1c","location_type":"River","is_public":true,"isCustom":false,"photos":[],"hours":[],"reviews":[],"geocode":[9.426961611091167,-84.1584320386772]
    var id: String
    var placeID: String?
    var authorID: String?
    var name: String?
    var avatar: String?
    var address: String?
    var city: String?
    var state: String?
    var country: String?
    var url: String?
    var rating: String?
    var experienceDescription: String?
    var notes: String?
    var phone: String?
    var tipCount: Int?
    var price: Int?
    var likes: Int?
    var locationType: String?
    var isPublic: Bool?
    var isCustom: Bool?
    var photos: NSArray?
    var hours: NSArray?
    var reviews: NSArray?
    var geocode: [Float]?
    
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
