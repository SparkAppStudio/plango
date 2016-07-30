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
    dynamic var name: String?
    dynamic var avatar: String?
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

class StoredGeocode: PlangoStoredObject {
    dynamic var lattitude: Double = 0.0
    dynamic var longitude: Double = 0.0
}
