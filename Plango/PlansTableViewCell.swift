//
//  PlansTableViewCell.swift
//  Plango
//
//  Created by Douglas Hewitt on 4/6/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit

class PlansTableViewCell: UITableViewCell {
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var viewsIconImageView: UIImageView!
    @IBOutlet weak var copiesIconImageView: UIImageView!
    
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var planNameLabel: UILabel!
    @IBOutlet weak var planTagsLabel: UILabel!
    @IBOutlet weak var planLengthLabel: UILabel!
    @IBOutlet weak var viewsCountLabel: UILabel!
    @IBOutlet weak var copiesCountLabel: UILabel!
    
    
    var user: User?
    var plan: Plan?
    
    
    func configure() {
        self.layoutIfNeeded()
        if let cellUser = user {
            profileNameLabel.text = cellUser.userName
        }
        if let cellPlan = plan {
            planNameLabel.text = cellPlan.name
            
            var allTags = ""
            guard let planTags = cellPlan.tags else {
               return
            }
            for tagName in planTags {
                allTags = allTags.stringByAppendingString("\(tagName), ")
            }
            let cleanedTags = String(allTags.characters.dropLast(2))
            planTagsLabel.text = cleanedTags
            
            //TODO: - plan length, views count and copies count
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
