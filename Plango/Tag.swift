//
//  Tag.swift
//  Plango
//
//  Created by Douglas Hewitt on 4/8/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire


class Tag: NSObject {
    var id: String!
    var name: String?
    var avatar: String?
    // for all plangoObjects need to check image url and see if it is AWS S3 or on plango.
    //if user uploaded image its on S3 can just use the url, if not its on server and need to add prefex "www.plango.us/"
    
    class func getTagsFromJSON(_ objectJSON: JSON) -> [Tag] {
        var tempTags = [Tag?]()
        
        guard let array = objectJSON["data"].arrayObject else {
            return [Tag]()
        }
        
        for item in array {
            let dictionary = item as! NSDictionary
            tempTags.append(createTag(dictionary))
        }
        
        return tempTags.compactMap { $0 }
    }
    
    class func createTag(_ dictionary: NSDictionary) -> Tag? {
        let newTag = Tag()
        newTag.id = dictionary["_id"] as! String
        newTag.name = dictionary["tag"] as? String
        newTag.avatar = dictionary["img"] as? String
        
        return newTag
    }
}

struct PlangoCollection {
    var id: String
    var name: String?
    var avatar: String?
    
    static func getPlangoCollectionsFromJSON(_ objectJSON: JSON) -> [PlangoCollection] {
        var tempTags = [PlangoCollection?]()
        
        guard let array = objectJSON["data"].arrayObject else {
            return [PlangoCollection]()
        }
        
        for item in array {
            let dictionary = item as! NSDictionary
            tempTags.append(createPlangoCollection(dictionary))
        }
        
        return tempTags.compactMap { $0 }
    }
    
    static func createPlangoCollection(_ dictionary: NSDictionary) -> PlangoCollection? {
        
        let id = dictionary["_id"] as! String
        let name = dictionary["name"] as? String
        let image = dictionary["image"] as? String
        
        let newCollection = PlangoCollection(id: id, name: name, avatar: image)

        return newCollection
    }

}
