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

class Plan: PlangoObject {
//    var id: String!
    var name: String?
//    var avatar: String?
//    var localAvatar: NSData?
    var planDescription: String?
    var isPublic: Bool!

    var authorID: String!
    
    var durationDays: Int!
    var startDate: Date?
    var endDate: Date?
    
    var lastViewedDate: Date?
    var lastUpdatedDate: Date?
    var createdDate: Date?
    
    var viewCount: Int!
    var usedCount: Int!
    
//    let spamReported = List<PlangoString>()
    var spamReported: [String]?
    var members: [Member]?
    var tags: [String]?
    var todos: [Todo]?
    var events: [Event]?
    var places: [Place]?
    var experiences: [Experience]?
    var plangoFavorite: String?
    
//    init(id: String) {
//        self.id = id
//    }
//    
//    required convenience init?(coder aDecoder: NSCoder) {
//        let tempID = aDecoder.decodeObjectForKey("id") as! String
//        self.init(id: tempID)
//        self.name = aDecoder.decodeObjectForKey("name") as? String
//        self.avatar = aDecoder.decodeObjectForKey("avatar") as? String
//        self.planDescription = aDecoder.decodeObjectForKey("planDescription") as? String
//        self.isPublic = aDecoder.decodeBoolForKey("isPublic")
//        self.authorID = aDecoder.decodeObjectForKey("authorID") as? String
//        self.durationDays = aDecoder.decodeIntegerForKey("durationDays")
//        self.startDate = aDecoder.decodeObjectForKey("startDate") as? NSDate
//        self.endDate = aDecoder.decodeObjectForKey("endDate") as? NSDate
//        lastViewedDate = aDecoder.decodeObjectForKey("lastViewedDate") as? NSDate
//        lastUpdatedDate = aDecoder.decodeObjectForKey("lastUpdatedDate") as? NSDate
//        createdDate = aDecoder.decodeObjectForKey("createdDate") as? NSDate
//        viewCount = aDecoder.decodeIntegerForKey("viewCount")
//        usedCount = aDecoder.decodeIntegerForKey("usedCount")
//        spamReported = aDecoder.decodeObjectForKey("spamReported") as? [String]
//        members = aDecoder.decodeObjectForKey("members") as? [Member]
//        tags = aDecoder.decodeObjectForKey("tags") as? [String]
//        todos = aDecoder.decodeObjectForKey("todos") as? [Todo]
//        events = aDecoder.decodeObjectForKey("events") as? [Event]
//        places = aDecoder.decodeObjectForKey("places") as? [Place]
//        experiences = aDecoder.decodeObjectForKey("experiences") as? [Experience]
//        plangoFavorite = aDecoder.decodeObjectForKey("plangoFavorite") as? String
//    }
//    
//    enum CodeKeys: String {
//        case id = "id"
//        case name = "name"
//        case avatar = "avatar"
//        case planDescription = "planDescription"
//        case isPublic = "isPublic"
//        case authorID = "authorID"
//        case durationDays = "durationDays"
//        case startDate = "startDate"
//        case endDate = "endDate"
//        case lastViewedDate = "lastViewedDate"
//        case lastUpdatedDate = "lastUpdatedDate"
//        case createdDate = "createdDate"
//        case viewCount = "viewCount"
//        case usedCount = "usedCount"
//        case spamReported = "spamReported"
//        case members = "members"
//        case tags = "tags"
//        case todos = "todos"
//        case events = "events"
//        case places = "places"
//        case experiences = "experiences"
//        case plangoFavorite = "plangoFavorite"
//    }
//    
//    func encodeWithCoder(aCoder: NSCoder) {
//        aCoder.encodeObject(id, forKey: CodeKeys.id.rawValue)
//        aCoder.encodeObject(name, forKey: CodeKeys.name.rawValue)
//        aCoder.encodeObject(avatar, forKey: CodeKeys.avatar.rawValue)
//        aCoder.encodeObject(planDescription, forKey: CodeKeys.planDescription.rawValue)
//        if let isPublic = isPublic {
//            aCoder.encodeBool(isPublic, forKey: CodeKeys.isPublic.rawValue)
//        }
//        aCoder.encodeObject(authorID, forKey: CodeKeys.authorID.rawValue)
//        if let durationDays = durationDays {
//            aCoder.encodeInteger(durationDays, forKey: CodeKeys.durationDays.rawValue)
//        }
//        aCoder.encodeObject(startDate, forKey: CodeKeys.startDate.rawValue)
//        aCoder.encodeObject(endDate, forKey: CodeKeys.endDate.rawValue)
//        aCoder.encodeObject(lastViewedDate, forKey: CodeKeys.lastViewedDate.rawValue)
//        aCoder.encodeObject(lastUpdatedDate, forKey: CodeKeys.lastUpdatedDate.rawValue)
//        aCoder.encodeObject(createdDate, forKey: CodeKeys.createdDate.rawValue)
//        if let viewCount = viewCount {
//            aCoder.encodeInteger(viewCount, forKey: CodeKeys.viewCount.rawValue)
//        }
//        if let usedCount = usedCount {
//            aCoder.encodeInteger(usedCount, forKey: CodeKeys.usedCount.rawValue)
//        }
//        aCoder.encodeObject(spamReported, forKey: CodeKeys.spamReported.rawValue)
//        aCoder.encodeObject(members, forKey: CodeKeys.members.rawValue)
//        aCoder.encodeObject(tags, forKey: CodeKeys.tags.rawValue)
//        aCoder.encodeObject(todos, forKey: CodeKeys.todos.rawValue)
//        aCoder.encodeObject(events, forKey: CodeKeys.events.rawValue)
//        aCoder.encodeObject(places, forKey: CodeKeys.places.rawValue)
//        aCoder.encodeObject(experiences, forKey: CodeKeys.experiences.rawValue)
//        aCoder.encodeObject(plangoFavorite, forKey: CodeKeys.plangoFavorite.rawValue)
//    }
    
    class func getPlansFromJSON(_ objectJSON: JSON) -> [Plan]? {
        var tempUsers = [Plan?]()
        
        if let array = objectJSON["data"].arrayObject { //sometimes plango server sends array in top level
            
            if array.count == 0 {
                return tempUsers.flatMap { $0 } //end of pagination, found empty array
            }
            
            for item in array {
                let dictionary = item as! NSDictionary
                tempUsers.append(createPlan(dictionary))
            }
        } else if let topDictionary = objectJSON["data"].dictionaryObject { //sometimes plango server sends a dictionary with the array nested one more level
            guard let array = topDictionary["plans"] as? [AnyObject] else {
                print("In \(self.classForCoder()) failed to parse JSON this shouldn't happen, check data from server")
                return nil
            }
            
            if let total = topDictionary["total"] as? Int {
                Plango.sharedInstance.searchTotal = total
            }
            
            if array.count == 0 {
                return tempUsers.flatMap { $0 } //end of pagination, found empty array
            }
            
            for item in array {
                let dictionary = item as! NSDictionary
                tempUsers.append(createPlan(dictionary))
            }
        }
        
        //remote nil users
        return tempUsers.flatMap { $0 }
    }
    
    class func createPlan(_ dictionary: NSDictionary) -> Plan? {
        
        // ----------------------------------------------------------------------------------
        
        // NOTE: - the time given in the JSON is actually in yyyy-MM-dd’T'HH:mm:ss.SSSZ format. However, that denotes timezone of UTC for ISODate, and the times received are actually local times. Each time is local to the timezone that event is created in. Here I will set all of them to the local time of the device. This means the calculation between device and time of a certain event is only accurate if the device is in the same timezone of that event. This also requires me to drop the last 5 chars of the JSON string to match this timezoneless template, which we just assign to be local time.
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        // ----------------------------------------------------------------------------------

        let newPlan = Plan(id: dictionary["_id"] as! String)
        newPlan.name = dictionary["name"] as? String
        newPlan.avatar = dictionary["avatarUrl"] as? String
        newPlan.planDescription = dictionary["description"] as? String
        newPlan.isPublic = dictionary["is_public"] as! Bool
        newPlan.authorID = dictionary["created_by"] as! String
        newPlan.durationDays = dictionary["duration"] as? Int

        if let startDate = dictionary["start"] as? String {
            //Trimming timezone is necessary because the JSON object actually has timezone data '.SSSZ' which we dont want
            newPlan.startDate = dateFormatter.date(from: startDate.trimDateTimeZone())
        }
        
        if let endDate = dictionary["end"] as? String {
            newPlan.endDate = dateFormatter.date(from: endDate.trimDateTimeZone())
        }
        
        if let lastViewed = dictionary["last_viewed"] as? String {
            newPlan.lastViewedDate = dateFormatter.date(from: lastViewed)
        }
        
        if let lastUpdated = dictionary["last_updated"] as? String {
            newPlan.lastUpdatedDate = dateFormatter.date(from: lastUpdated)
        }
        
        if let createdDate = dictionary["created_date"] as? String {
            newPlan.createdDate = dateFormatter.date(from: createdDate.trimDateTimeZone())
        }
        
        newPlan.viewCount = dictionary["viewCount"] as? Int
        newPlan.usedCount = dictionary["usedCount"] as? Int
        
        newPlan.spamReported = dictionary["spamReported"] as? [String]
        
        
        if let members = dictionary["members"] as? [[String:AnyObject]] {
            newPlan.members = [Member]()
            for member in members {
                //possibly change this to optional
                let userID = member["_id"] as! String
                let confirmed = member["confirmed"] as! Bool
                
                let aMember = Member(id: userID)
                aMember.confirmed = confirmed
//                let aMember = Member(userID: userID, confirmed: confirmed)
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
                
                let aTodo = Todo(id: id)
                aTodo.item = item
                aTodo.done = done
//                let aTodo = Todo(id: id, item: item, done: done)
                newPlan.todos?.append(aTodo)
            }
        }
        
        if let events = dictionary["events"] as? [[String:AnyObject]] {
            newPlan.events = [Event]()
            for event in events {
                let id = event["_id"] as! String
                let experienceID = event["experience_id"] as? String
                let duration = event["duration"] as? Int
                let allDay = event["all_day"] as? Bool

                var startDate: Date? = nil
                if let start = event["start"] as? String {
                    startDate = dateFormatter.date(from: start.trimDateTimeZone())
                }
                
                let anEvent = Event(id: id)
                anEvent.experienceID = experienceID
                anEvent.duration = duration
                anEvent.startDate = startDate
                anEvent.allDay = allDay
//                let anEvent = Event(id: id, experienceID: experienceID, duration: duration, startDate: startDate, allDay: allDay)
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

                var startDate: Date? = nil
                if let start = place["start"] as? String {
                    startDate = dateFormatter.date(from: start.trimDateTimeZone())
                }
        
                var endDate: Date? = nil
                if let end = place["end"] as? String {
                    endDate = dateFormatter.date(from: end.trimDateTimeZone())
                }
                
                let aPlace = Place(id: id)
                aPlace.city = city
                aPlace.state = state
                aPlace.country = country
                aPlace.notes = notes
                aPlace.startDate = startDate
                aPlace.endDate = endDate
                aPlace.durationDays = duration
                
//                let aPlace = Place(id: id, city: city, state: state, country: country, notes: notes, startDate: startDate, endDate: endDate, durationDays: duration)
                
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
                
                var reviews: [Review]? = nil
                if let reviewsToParse = experience["reviews"] as? [[String:AnyObject]] {
                    var tempReviews = [Review]()

                    for review in reviewsToParse {
                        let id = review["_id"] as! String
                        let name = review["review"] as? String
                        let author = review["reviewer"] as? String
                        let authorAvatar = review["reviewer_photo"] as? String
                        let likes = review["likes"] as? Int
                        
                        var date: Date? = nil
                        if let reviewDate = review["review_date"] as? String {
                            date = dateFormatter.date(from: reviewDate.trimDateTimeZone())
                        }
                        
                        let aReview = Review(id: id)
                        aReview.name = name
                        aReview.author = author
                        aReview.avatar = authorAvatar
                        aReview.likes = likes
                        aReview.date = date
//                        let aReview = Review(id: id, name: name, author: author, authorAvatar: authorAvatar, likes: likes, date: date)
                        tempReviews.append(aReview)
                    }
                    
                    reviews = tempReviews
                }
                
                let geoArr = experience["geocode"] as? [Double]
                
                let anExperience = Experience(id: id)
                anExperience.placeID = placeID
                anExperience.authorID = authorID
                anExperience.name = name
                anExperience.avatar = avatar
                anExperience.address = address
                anExperience.city = city
                anExperience.state = state
                anExperience.country = country
                anExperience.url = url
                anExperience.rating = rating
                anExperience.experienceDescription = description
                anExperience.notes = notes
                anExperience.phone = phone
                anExperience.tipCount = tipCount
                anExperience.price = price
                anExperience.likes = likes
                anExperience.locationType = locationType
                anExperience.isPublic = isPublic
                anExperience.isCustom = isCustom
                anExperience.photos = photos
                anExperience.hours = hours
                anExperience.reviews = reviews
                anExperience.geocode = geoArr
                
//                let anExperience = Experience(id: id, placeID: placeID, authorID: authorID, name: name, avatar: avatar, address: address, city: city, state: state, country: country, url: url, rating: rating, experienceDescription: description, notes: notes, phone: phone, tipCount: tipCount, price: price, likes: likes, locationType: locationType, isPublic: isPublic, isCustom: isCustom, photos: photos, hours: hours, reviews: reviews, geocode: geoArr)
                newPlan.experiences?.append(anExperience)
            }
        }
        
        newPlan.plangoFavorite = dictionary["plango_favorite"] as? String
        
        return newPlan
    }
}

class Member: PlangoObject { //"_id":"558b8126817ff2433428d992","confirmed":true
    
//    var userID: String!
    var confirmed: Bool!
    
//    init(userID: String, confirmed: Bool) {
//        self.userID = userID
//        self.confirmed = confirmed
//    }
    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
}

class Todo: PlangoObject { //"done":false,"todoitem":"book hotels/hostels","_id":"56131ece0fdcab250243fb3f"
//    var id: String!
    var item: String!
    var done: Bool!
    
//    init(id: String, item: String, done: Bool) {
//        self.id = id
//        self.item = item
//        self.done = done
//    }
}

class Event: PlangoObject { //"experience_id":"560de35905c85ada730e7f14","start":"2015-11-21T13:00:00.000Z","all_day":false,"_id":"560f546f0fdcab250243f6f7","duration":5400
//    var id: String!
    var experienceID: String?
    var duration: Int?
    var startDate: Date?
    var allDay: Bool!
    
//    init(id: String, experienceID: String?, duration: Int?, startDate: NSDate?, allDay: Bool?) {
//        self.id = id
//        self.experienceID = experienceID
//        self.duration = duration
//        self.startDate = startDate
//        self.allDay = allDay
//    }
}

class Place: PlangoObject { //"state":"Alajuela","country":"Costa Rica","_id":"560de21405c85ada730e7f04","city":"La Fortuna","notes":"Volcano and hot springs. Book a boat taxi to and from Monteverde because there is no direct driving route.","start":"2015-11-21T08:00:00.000Z","end":"2015-11-22T08:00:00.000Z","duration":2
//    var id: String!
    var city: String?
    var state: String?
    var country: String?
    var notes: String?
    var startDate: Date?
    var endDate: Date?
    var durationDays: Int?
    
//    init(warehouse: JSONWarehouse) {
//        self.id = warehouse.get("id")!
//        self.city = warehouse.get("city")
//        self.state = warehouse.get("state")
//        self.country = warehouse.get("country")
//        self.notes = warehouse.get("notes")
//        self.startDate = warehouse.get("start")
//        self.endDate = warehouse.get("end")
//        self.durationDays = warehouse.get("duration")
//    }
//    
//    func toDictionary() -> [String : AnyObject] {
//        <#code#>
//    }
}

class Experience: PlangoObject { //"name":"PRO rafting Costa Rica","thumb":"http://placehold.it/160x100&text=image","address":"","city":"","state":"","country":"Costa Rica","created_by":"558b8126817ff2433428d992","url":"","rating":"","description":"","notes":"http://www.anywherecostarica.com/destinations/manuel-antonio/tours/whitewater-rafting-savegre\n                        \n                        ","phone":"","tip_count":0,"price":null,"likes":0,"place_id":"5221f7ac11d2c4664aafcbc7","_id":"56131b390fdcab250243fb1c","location_type":"River","is_public":true,"isCustom":false,"photos":[],"hours":[],"reviews":[],"geocode":[9.426961611091167,-84.1584320386772]
//    var id: String!
    var placeID: String?
    var authorID: String?
    var name: String?
//    var avatar: String?
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
    var isPublic: Bool!
    var isCustom: Bool!
    var photos: NSArray?
    var hours: NSArray?
    var reviews: [Review]?
    var geocode: [Double]?
    
}

class Review: PlangoObject {
//    var id: String!
    var name: String?
    var author: String?
//    var authorAvatar: String?
    var likes: Int?
    var date: Date?
    
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
