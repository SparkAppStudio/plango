//
//  Tag.swift
//  Plango
//
//  Created by Douglas Hewitt on 4/8/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit

class Tag: NSObject {
    var id: String!
    var name: String!
    var avatar: String!
    // for all plangoObjects need to check image url and see if it is AWS S3 or on plango.
    //if user uploaded image its on S3 can just use the url, if not its on server and need to add prefex "www.plango.us/"
}
