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
        print(review.name)
        reviewLabel.text = review.name
        authorLabel.text = review.author
        
        authorImageView.makeCircle()
        guard let endPoint = review.authorAvatar else {return}
        authorImageView.af_setImageWithURL(NSURL(string: endPoint)!)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        authorImageView.af_cancelImageRequest()
        review = nil
    }

}
