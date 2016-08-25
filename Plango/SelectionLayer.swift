//
//  Selection.swift
//  DoItLive
//
//  Created by Douglas Hewitt on 3/2/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit

class SelectionLayer: CALayer {
    override init() {
        super.init()
        self.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.4).CGColor
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addBadge() {
        let badgeLayer = CALayer()
        badgeLayer.frame = CGRectMake(self.bounds.width - 30, self.bounds.height - 30, 25, 25)
        badgeLayer.contents = UIImage(named: "check_icon")?.CGImage
        
        self.addSublayer(badgeLayer)
    }
}
