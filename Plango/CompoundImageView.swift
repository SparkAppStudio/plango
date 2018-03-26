//
//  CompoundImageView.swift
//  Plango
//
//  Created by Douglas Hewitt on 8/3/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit

class CompoundImageView: UIImageView {
    
    fileprivate let gradient: CAGradientLayer = CAGradientLayer()
    fileprivate let grayLayer: CALayer = CALayer()


    func gradientDarkToClear() {
        guard self.layer.sublayers?.last == nil else { return }
        
        let colorTop = UIColor.clear.cgColor
        let colorBottom = UIColor.plangoBlack().withAlphaComponent(0.8).cgColor
        
        
        gradient.colors = [colorTop, colorBottom]
        gradient.locations = [ 0.0, 1.0]
        gradient.frame = CGRect(x: 0, y: self.bounds.height / 2, width: self.bounds.width, height: self.bounds.height / 2)
        self.layer.addSublayer(gradient)
    }
    
    func lightGrayOverlay() {
        guard self.layer.sublayers?.last == nil else { return }
        grayLayer.backgroundColor = UIColor.transparentGray().cgColor
        grayLayer.frame = self.bounds
        self.layer.addSublayer(grayLayer)
    }

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        gradient.frame = CGRect(x: 0, y: self.bounds.height / 2, width: self.bounds.width, height: self.bounds.height / 2)
        grayLayer.frame = self.bounds
    }

}
