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
        titleLabel.layer.frame = CGRect(x: titleLabel.layer.frame.origin.x - 10, y: titleLabel.layer.frame.origin.y - 3, width: titleLabel.layer.frame.size.width + 6, height: titleLabel.layer.frame.size.height + 6)
        titleLabel.layer.borderColor = UIColor.whiteColor().CGColor
        titleLabel.layer.borderWidth = 1
    }
    
    func configure() {
        layoutIfNeeded()
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
    }
    
    override func prepareForReuse() {
        reset()
        super.prepareForReuse()
    }
}
