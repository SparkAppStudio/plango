//
//  TopCollectionsTableViewCell.swift
//  Plango
//
//  Created by Douglas Hewitt on 4/14/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit

class TopCollectionsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var plansCountLabel: UILabel!
    
    func configure() {
        self.layoutIfNeeded()

    }

}
