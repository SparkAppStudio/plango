//
//  ReviewTableViewCell.swift
//  Plango
//
//  Created by Douglas Hewitt on 6/22/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {

    @IBOutlet weak var authorImageView: UIImageView!
    
    @IBOutlet weak var reviewLabel: UILabel!
    
    @IBOutlet weak var authorLabel: UILabel!
    
    var review: Review!
    
    func configure() {
        reviewLabel.text = review.name
        authorLabel.text = review.author
        
        authorImageView.makeCircle()
        authorImageView.plangoImage(review)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        authorImageView.af_cancelImageRequest()
        review = nil
    }

}
