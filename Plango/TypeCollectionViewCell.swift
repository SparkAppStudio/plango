//
//  TypeCollectionViewCell.swift
//  Plango
//
//  Created by Douglas Hewitt on 4/14/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit

class TypeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var plangoTag: Tag!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        coverImageView.backgroundColor = UIColor.plangoTeal()
        coverImageView.makeRoundCorners(32)
    }
    
    func configure() {
        titleLabel.text = plangoTag.name
    }
}
