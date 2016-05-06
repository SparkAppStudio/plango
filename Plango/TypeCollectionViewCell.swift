//
//  TypeCollectionViewCell.swift
//  Plango
//
//  Created by Douglas Hewitt on 4/14/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
import Alamofire

class TypeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var plangoTag: Tag!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        coverImageView.makeRoundCorners(32)

    }
    
    func configure() {
        layoutIfNeeded()
        
//        let borderLayer = CALayer(layer: titleLabel.layer)
//        borderLayer.frame = CGRect(x: titleLabel.layer.frame.origin.x - 3, y: titleLabel.layer.frame.origin.y - 3, width: titleLabel.layer.frame.size.width + 6, height: titleLabel.layer.frame.size.height + 6)
//        borderLayer.borderColor = UIColor.whiteColor().CGColor
//        borderLayer.borderWidth = 1
//        self.contentView.layer.addSublayer(borderLayer)
        
        if let plangoTag = plangoTag {
            titleLabel.text = plangoTag.name
            guard let endPoint = plangoTag.avatar else {
                coverImageView.backgroundColor = UIColor.plangoTeal()
                return
            }
            
            let cleanURL = NSURL(string: Plango.sharedInstance.cleanEndPoint(endPoint))
            coverImageView.af_setImageWithURL(cleanURL!)
 
        }
        
    }
    
    func reset() {
        coverImageView.af_cancelImageRequest()
        coverImageView.image = nil
    }
    
    override func prepareForReuse() {
        reset()
        super.prepareForReuse()
    }
}
