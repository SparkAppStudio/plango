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
    var name: String!
    var avatar: String?
    // for all plangoObjects need to check image url and see if it is AWS S3 or on plango.
    //if user uploaded image its on S3 can just use the url, if not its on server and need to add prefex "www.plango.us/"
    
    class func getTagsFromJSON(objectJSON: JSON) -> [Tag] {
        var tempTags = [Tag?]()
        
        guard let dictionary = objectJSON["data"].dictionaryObject else {
            return [Tag]()
        }
        
        tempTags.append(createTag(dictionary))
        
        return tempTags.flatMap { $0 }
    }
    
    class func createTag(dictionary: NSDictionary) -> Tag? {
        let newTag = Tag()
        newTag.id = dictionary["_id"] as! String
        newTag.name = dictionary["tag"] as! String
        newTag.avatar = dictionary["img"] as? String
        
        return newTag
    }
}
