//
//  MemberTableViewCell.swift
//  Plango
//
//  Created by Douglas Hewitt on 6/30/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit

class MemberTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var user: User!
    
    func configure() {
        profileImageView.makeCircle()
        if let cellUser = user {
            nameLabel.text = cellUser.userName
            guard let endPoint = cellUser.avatar else {return}
            let cleanURL = NSURL(string: Plango.sharedInstance.cleanEndPoint(endPoint))
            profileImageView.af_setImageWithURL(cleanURL!)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        profileImageView.af_cancelImageRequest()
        profileImageView.image = nil
        nameLabel.text = nil
        user = nil
    }


}
