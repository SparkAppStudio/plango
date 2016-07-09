//
//  ExperienceTableViewCell.swift
//  Plango
//
//  Created by Douglas Hewitt on 7/6/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit

class ExperienceTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var experience: Experience!
    
    func configure() {
        avatarImageView.makeRoundCorners(6)
        guard let experience = experience else {return}
        
        if let avatar = experience.avatar {
            let avatarURL = NSURL(string: avatar)
            avatarImageView.af_setImageWithURL(avatarURL!)
        }
        
        titleLabel.text = experience.name
        ratingLabel.text = experience.rating
        descriptionLabel.text = experience.experienceDescription
        
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        avatarImageView.af_cancelImageRequest()
        avatarImageView.image = nil
    }
}
