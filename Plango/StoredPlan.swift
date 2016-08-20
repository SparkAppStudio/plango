//
//  StoredPlan.swift
//  Plango
//
//  Created by Douglas Hewitt on 7/29/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
import RealmSwift
//import Realm
//import ObjectMapper

class StoredPlan: PlangoStoredObject {
    dynamic var mapSize: String?
    dynamic var name: String?
    dynamic var avatar: String?
    dynamic var localAvatar: NSData?
    dynamic var planDescription: String?
    let isPublic = RealmOptional<Bool>()
    
    dynamic var authorID: String?
    
    let durationDays = RealmOptional<Int>()
    dynamic var startDate: NSDate?
    dynamic var endDate: NSDate?
    
    dynamic var lastViewedDate: NSDate?
    dynamic var lastUpdatedDate: NSDate?
    dynamic var createdDate: NSDate?
    
    let viewCount = RealmOptional<Int>()
    let usedCount = RealmOptional<Int>()
    
    let spamReported = List<PlangoString>()
    let members = List<StoredMember>()
    let tags = List<PlangoString>()
    let todos = List<StoredTodo>()
    let events = List<StoredEvent>()
    let places = List<StoredPlace>()
    let experiences = List<StoredExperience>()
    dynamic var plangoFavorite: String?
    
    class func unpackStoredPlan(plan: StoredPlan) -> Plan {
        let savedPlan = Plan()
        savedPlan.id = plan.id
        savedPlan.name = plan.name
        savedPlan.avatar = plan.avatar
        savedPlan.localAvatar = plan.localAvatar
        savedPlan.planDescription = plan.planDescription
        savedPlan.isPublic = plan.isPublic.value
        savedPlan.authorID = plan.authorID
        savedPlan.durationDays = plan.durationDays.value
        savedPlan.startDate = plan.startDate
        savedPlan.endDate = plan.endDate
        savedPlan.lastViewedDate = plan.lastViewedDate
        savedPlan.lastUpdatedDate = plan.lastUpdatedDate
        savedPlan.createdDate = plan.createdDate
        savedPlan.viewCount = plan.viewCount.value
        savedPlan.usedCount = plan.usedCount.value
        
        if plan.spamReported.count > 0 {
            savedPlan.spamReported = [String]()
            for item in plan.spamReported {
                savedPlan.spamReported?.append(item.stringValue)
            }
        }
        
        //TODO: clean up with generic approach
        
        if plan.members.count > 0 {
            savedPlan.members = [Member]()
            for item in plan.members {
                let aMember = Member(id: item.id)
                aMember.confirmed = item.confirmed.value
                
                savedPlan.members?.append(aMember)
            }
        }
        
        if plan.tags.count > 0 {
            savedPlan.tags = [String]()
            for item in plan.tags {
                savedPlan.tags?.append(item.stringValue)
            }
        }
        
        if plan.todos.count > 0 {
            savedPlan.todos = [Todo]()
            for item in plan.todos {
                let aTodo = Todo(id: item.id)
                aTodo.item = item.item
                aTodo.done = item.done
                
                savedPlan.todos?.append(aTodo)
            }
        }
        
        if plan.events.count > 0 {
            savedPlan.events = [Event]()
            for item in plan.events {
                
                let anEvent = Event(id: item.id)
                anEvent.experienceID = item.experienceID
                anEvent.duration = item.duration.value
                anEvent.startDate = item.startDate
                anEvent.allDay = item.allDay.value
                savedPlan.events?.append(anEvent)
            }
        }
        
        if plan.places.count > 0 {
            savedPlan.places = [Place]()
            for item in plan.places {
                
                let aPlace = Place(id: item.id)
                aPlace.city = item.city
                aPlace.state = item.state
                aPlace.country = item.country
                aPlace.notes = item.notes
                aPlace.startDate = item.startDate
                aPlace.endDate = item.endDate
                aPlace.durationDays = item.durationDays.value
                
                
                savedPlan.places?.append(aPlace)
            }
        }
        
        if plan.experiences.count > 0 {
            savedPlan.experiences = [Experience]()
            for item in plan.experiences {
                
                let anExperience = Experience(id: item.id)
                anExperience.placeID = item.placeID
                anExperience.authorID = item.authorID
                anExperience.name = item.name
                anExperience.avatar = item.avatar
                anExperience.address = item.address
                anExperience.city = item.city
                anExperience.state = item.state
                anExperience.country = item.country
                anExperience.url = item.url
                anExperience.rating = item.rating
                anExperience.experienceDescription = item.experienceDescription
                anExperience.notes = item.notes
                anExperience.phone = item.phone
                anExperience.tipCount = item.tipCount.value
                anExperience.price = item.price.value
                anExperience.likes = item.likes.value
                anExperience.locationType = item.locationType
                anExperience.isPublic = item.isPublic
                anExperience.isCustom = item.isCustom
                
                //not used by iOS yet
                //                anExperience.photos = item.photos
                //                anExperience.hours = item.hours
                
                if item.reviews.count > 0 {
                    anExperience.reviews = [Review]()
                    
                    for review in item.reviews {
                        
                        let aReview = Review(id: review.id)
                        aReview.name = review.name
                        aReview.author = review.author
                        aReview.authorAvatar = review.authorAvatar
                        aReview.likes = review.likes.value
                        aReview.date = review.date
                        anExperience.reviews?.append(aReview)
                    }
                }
                
                if let geo = item.geocode {
                    anExperience.geocode = [Double]()
                    anExperience.geocode?.append(geo.lattitude)
                    anExperience.geocode?.append(geo.longitude)
                }
                
                
                
                savedPlan.experiences?.append(anExperience)
            }
        }
        
        savedPlan.plangoFavorite = plan.plangoFavorite
        return savedPlan
    }
    
    class func savePlan(plan: Plan, mapSize: String) {
        let savedPlan = StoredPlan()
        savedPlan.id = plan.id
        savedPlan.name = plan.name
        savedPlan.mapSize = mapSize
        savedPlan.avatar = plan.avatar
        savedPlan.localAvatar = plan.localAvatar
        savedPlan.planDescription = plan.planDescription
        savedPlan.isPublic.value = plan.isPublic
        savedPlan.authorID = plan.authorID
        savedPlan.durationDays.value = plan.durationDays
        savedPlan.startDate = plan.startDate
        savedPlan.endDate = plan.endDate
        savedPlan.lastViewedDate = plan.lastViewedDate
        savedPlan.lastUpdatedDate = plan.lastUpdatedDate
        savedPlan.createdDate = plan.createdDate
        savedPlan.viewCount.value = plan.viewCount
        savedPlan.usedCount.value = plan.usedCount
        
        if let spams = plan.spamReported {
            for item in spams {
                let storedItem = PlangoString()
                storedItem.stringValue = item
                savedPlan.spamReported.append(storedItem)
            }
        }
        
        //TODO: try to use generic approach, clean up code
        
        
        if let members = plan.members {
            for item in members {
                let storedItem = StoredMember()
                storedItem.id = item.id
                storedItem.confirmed.value = item.confirmed
                savedPlan.members.append(storedItem)
            }
        }
        
        if let tags = plan.tags {
            for item in tags {
                let storedItem = PlangoString()
                storedItem.stringValue = item
                savedPlan.tags.append(storedItem)
            }
            
        }
        
        if let todos = plan.todos {
            for item in todos {
                let storedItem = StoredTodo()
                storedItem.id = item.id
                storedItem.item = item.item
                storedItem.done = item.done
                savedPlan.todos.append(storedItem)
            }
        }
        
        if let events = plan.events {
            for item in events {
                let storedItem = StoredEvent()
                storedItem.id = item.id
                storedItem.experienceID = item.experienceID
                storedItem.duration.value = item.duration
                storedItem.startDate = item.startDate
                storedItem.allDay.value = item.allDay
                savedPlan.events.append(storedItem)
            }
        }
        
        if let places = plan.places {
            for item in places {
                let storedItem = StoredPlace()
                storedItem.id = item.id
                storedItem.city = item.city
                storedItem.state = item.state
                storedItem.country = item.country
                storedItem.notes = item.notes
                storedItem.startDate = item.startDate
                storedItem.endDate = item.endDate
                storedItem.durationDays.value = item.durationDays
                savedPlan.places.append(storedItem)
            }
        }
        
        if let experiences = plan.experiences {
            for item in experiences {
                let storedItem = StoredExperience()
                storedItem.id = item.id
                storedItem.placeID = item.placeID
                storedItem.authorID = item.authorID
                storedItem.name = item.name
                storedItem.avatar = item.avatar
                storedItem.address = item.address
                storedItem.city = item.city
                storedItem.state = item.state
                storedItem.country = item.country
                storedItem.url = item.url
                storedItem.rating = item.rating
                storedItem.experienceDescription = item.experienceDescription
                storedItem.notes = item.notes
                storedItem.phone = item.phone
                storedItem.tipCount.value = item.tipCount
                storedItem.price.value = item.price
                storedItem.likes.value = item.likes
                storedItem.locationType = item.locationType
                storedItem.isPublic = item.isPublic
                storedItem.isCustom = item.isCustom
                
                //photos and hours not yet used in iOS, no need to save
                //                if let photos = item.photos {
                //                    for any in photos {
                //                        let storedItem = PlangoStoredObject()
                //                        storedItem.id = any.id //photos not typed, needs ID
                //                    }
                //                }
                //                if let hours = item.hours {
                //
                //                }
                
                if let reviews = item.reviews {
                    for review in reviews {
                        let stored = StoredReview()
                        stored.id = review.id
                        stored.name = review.name
                        stored.author = review.author
                        stored.authorAvatar = review.authorAvatar
                        stored.likes.value = review.likes
                        stored.date = review.date
                        storedItem.reviews.append(stored)
                    }
                }
                
                if let geocode = item.geocode {
                    let stored = StoredGeocode()
                    stored.lattitude = geocode.first!
                    stored.longitude = geocode.last!
                    storedItem.geocode = stored
                    print(item.geocode)
                    print(storedItem.geocode)
                }
                
                savedPlan.experiences.append(storedItem)
            }
        }
        savedPlan.plangoFavorite = plan.plangoFavorite
        
        
        
        
        let realm = try! Realm()
        try! realm.write({ 
            realm.add(savedPlan, update: true)
        })
        
    }
    
//    required init() { super.init() }
//    required init?(_ map: Map) { super.init() }
//    required init(value: AnyObject, schema: RLMSchema) { super.init(value: value, schema: schema) }
//    required init(realm: RLMRealm, schema: RLMObjectSchema) { super.init(realm: realm, schema: schema) }
//    
//    override func mapping(map: Map) {
//        super.mapping(map)
//        
//        name <- map["name"]
//    }

}

class StoredMember: PlangoStoredObject {
    let confirmed = RealmOptional<Bool>()
}

class StoredTodo: PlangoStoredObject {
    dynamic var item: String = ""
    dynamic var done: Bool = false
}

class StoredEvent: PlangoStoredObject {
    dynamic var experienceID: String? = nil
    let duration = RealmOptional<Int>()
    dynamic var startDate: NSDate? = nil
    let allDay = RealmOptional<Bool>()
}

class StoredPlace: PlangoStoredObject {
    dynamic var city: String?
    dynamic var state: String?
    dynamic var country: String?
    dynamic var notes: String?
    dynamic var startDate: NSDate?
    dynamic var endDate: NSDate?
    let durationDays = RealmOptional<Int>()

}

class StoredExperience: PlangoStoredObject {
    dynamic var placeID: String?
    dynamic var authorID: String?
    dynamic var name: String?
    dynamic var avatar: String?
    dynamic var address: String?
    dynamic var city: String?
    dynamic var state: String?
    dynamic var country: String?
    dynamic var url: String?
    dynamic var rating: String?
    dynamic var experienceDescription: String?
    dynamic var notes: String?
    dynamic var phone: String?
    let tipCount = RealmOptional<Int>()
    let price = RealmOptional<Int>()
    let likes = RealmOptional<Int>()
    dynamic var locationType: String?
    dynamic var isPublic: Bool = false
    dynamic var isCustom: Bool = false
    let photos = List<PlangoStoredObject>()
    let hours = List<PlangoStoredObject>()
    let reviews = List<StoredReview>()
    dynamic var geocode: StoredGeocode?

}

class StoredReview: PlangoStoredObject {
    dynamic var name: String?
    dynamic var author: String?
    dynamic var authorAvatar: String?
    let likes = RealmOptional<Int>()
    dynamic var date: NSDate?

}
//not a PlangoStoredObject because it has no mongoDB ID, and a blank Realm ID prevents it being retrieved
class StoredGeocode: Object {
    dynamic var lattitude: Double = 0.0
    dynamic var longitude: Double = 0.0
}
