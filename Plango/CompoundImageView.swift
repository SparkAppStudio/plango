//
//  CompoundImageView.swift
//  Plango
//
//  Created by Douglas Hewitt on 8/3/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit

class CompoundImageView: UIImageView {
    
    private let gradient: CAGradientLayer = CAGradientLayer()
    private let grayLayer: CALayer = CALayer()


    func gradientDarkToClear() {
        guard self.layer.sublayers?.last == nil else { return }
        
        let colorTop = UIColor.clearColor().CGColor
        let colorBottom = UIColor.plangoBlack().colorWithAlphaComponent(0.8).CGColor
        
        
        gradient.colors = [colorTop, colorBottom]
        gradient.locations = [ 0.0, 1.0]
        gradient.frame = CGRect(x: 0, y: self.bounds.height / 2, width: self.bounds.width, height: self.bounds.height / 2)
        self.layer.addSublayer(gradient)
    }
    
    func lightGrayOverlay() {
        guard self.layer.sublayers?.last == nil else { return }
        grayLayer.backgroundColor = UIColor.transparentGray().CGColor
        grayLayer.frame = self.bounds
        self.layer.addSublayer(grayLayer)
    }
    
    override func layoutSublayersOfLayer(layer: CALayer) {
        super.layoutSublayersOfLayer(layer)
        gradient.frame = CGRect(x: 0, y: self.bounds.height / 2, width: self.bounds.width, height: self.bounds.height / 2)
        grayLayer.frame = self.bounds
    }

}
