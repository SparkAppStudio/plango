//
//  Plan.swift
//  Plango
//
//  Created by Douglas Hewitt on 4/8/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit

class Plan: NSObject {
    var id: String!
    var name: String!
    var avatarURL: String!
    var planDescription: String!
    var isPublic: Bool!

    var authorID: String!
    
    var startDate: NSDate!
    var endDate: NSDate!
    var durationDate: NSDate!
    
    var lastUpdatedDate: NSDate!
    var createdDate: NSDate!
    
    var members: NSArray!
    var tags: NSArray!
    var todos: NSArray!
    var events: NSArray!
    var places: NSArray!
    var experiences: NSArray!
}
