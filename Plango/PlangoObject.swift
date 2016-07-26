//
//  PlangoObject.swift
//  Plango
//
//  Created by Douglas Hewitt on 7/25/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit

class PlangoObject: NSObject, NSCoding {
    var id: String!
    
    func getPropertyNames() -> [String] {
        
        let swiftProperties = Mirror(reflecting: self).children.flatMap { $0.label }
        
        var count = UInt32()
        let classToInspect = NSURL.self
        let properties : UnsafeMutablePointer <objc_property_t> = class_copyPropertyList(classToInspect, &count)
        var propertyNames = [String]()
        let intCount = Int(count)
        for i in 0 ..< intCount {
            let property : objc_property_t = properties[i]
            guard let propertyName = NSString(UTF8String: property_getName(property)) as? String else {
                debugPrint("Couldn't unwrap property name for \(property)")
                break
            }
            
            propertyNames.append(propertyName)
        }
        
        free(properties)
        
        print(swiftProperties)
        print(propertyNames)
        
        return propertyNames
    }
    
    init(id: String) {
        self.id = id
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        let tempID = aDecoder.decodeObjectForKey("id") as! String
        self.init(id: tempID)

        for key in getPropertyNames() {
            let value = aDecoder.decodeObjectForKey(key)
            setValue(value, forKey: key)
        }
        
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        for key in getPropertyNames() {
            let value = valueForKey(key)
            aCoder.encodeObject(value, forKey: key)
        }
    }
    
}