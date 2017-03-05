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
    fileprivate static var internalJsonDateTimeFormatter: DateFormatter?
    
    static var jsonDateTimeFormatter: DateFormatter {
        if (internalJsonDateTimeFormatter == nil) {
            internalJsonDateTimeFormatter = DateFormatter()
            internalJsonDateTimeFormatter!.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSSZZ"
        }
        return internalJsonDateTimeFormatter!
    }
}
