//
//  Formatter.swift
//  Plango
//
//  Created by Douglas Hewitt on 4/10/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
import SwiftyJSON

class Formatter: NSObject {
    private static var internalJsonDateTimeFormatter: NSDateFormatter?
    
    static var jsonDateTimeFormatter: NSDateFormatter {
        if (internalJsonDateTimeFormatter == nil) {
            internalJsonDateTimeFormatter = NSDateFormatter()
            internalJsonDateTimeFormatter!.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSSZZ"
        }
        return internalJsonDateTimeFormatter!
    }
}
