//
//  PlansTableViewCell.swift
//  Plango
//
//  Created by Douglas Hewitt on 4/6/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class PlansTableViewCell: UITableViewCell {
    
    @IBOutlet weak var coverImageView: CompoundImageView!
    @IBOutlet weak var profileImageView: UIImageView!
//    @IBOutlet weak var viewsIconImageView: UIImageView!
//    @IBOutlet weak var copiesIconImageView: UIImageView!
    
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var planNameLabel: UILabel!
    @IBOutlet weak var planTagsLabel: UILabel!
    @IBOutlet weak var planLengthLabel: UILabel!
    @IBOutlet weak var viewsCountLabel: UILabel!
    @IBOutlet weak var usedCountLabel: UILabel!
    
    @IBOutlet weak var backdropView: UIView!
    
    var user: User?
    var plan: Plan?
    var request: Request?
    var userRequest: Request?
    
    
    func configure() {
        backdropView.layer.borderWidth = 1
        backdropView.layer.borderColor = UIColor.plangoCream().cgColor
        
        if let cellPlan = plan {
            fetchUserForPlan(cellPlan, endPoint: "\(Plango.EndPoint.UserByID.value)\(cellPlan.authorID)")

            planNameLabel.text = cellPlan.name
            
            coverImageView.plangoImage(cellPlan)
            
            var allTags = ""
            guard let planTags = cellPlan.tags else {
               return
            }
            for tagName in planTags {
                allTags = allTags + "\(tagName), "
            }
            let cleanedTags = String(allTags.characters.dropLast(2))
            planTagsLabel.text = cleanedTags
            
            guard let days = cellPlan.durationDays else {planLengthLabel.isHidden = true; return}
            planLengthLabel.isHidden = false
            if days == 1 {
                planLengthLabel.text = "\(days) Day"
            } else {
                planLengthLabel.text = "\(days) Days"
            }
            
            guard let views = cellPlan.viewCount else {return}
            guard let used = cellPlan.usedCount else {return}
            
            viewsCountLabel.text = "\(views)"
            usedCountLabel.text = "\(used)"
        }
    }
    
    func configureUser(_ user: User) {
        DispatchQueue.main.async(execute: {
            self.profileNameLabel.text = user.userName
            self.profileImageView.makeCircle()

            guard let endPoint = user.avatar else {
//                if let facebook = user.facebookAvatar {
//                    let cleanURL = NSURL(string: facebook)
//                    self.profileImageView.af_setImageWithURL(cleanURL!)
//                }
                return
            }
            let cleanURL = URL(string: Plango.sharedInstance.cleanEndPoint(endPoint))
            
            self.profileImageView.af_setImage(withURL: cleanURL!)
        })
    }
    
    func reset() {
        coverImageView.af_cancelImageRequest()
        coverImageView.layer.sublayers?.removeLast()
        profileImageView.af_cancelImageRequest()
//        self.request?.cancel() //for when using my own method and request manager
        
        coverImageView.image = nil
        profileImageView.image = nil

        userRequest?.cancel()
        self.profileImageView.hideSimpleLoading()
        profileNameLabel.text = nil
        
        user = nil
        plan = nil
    }
    
    func fetchUserForPlan(_ plan: Plan, endPoint: String) {
        
        if let user = user {
            configureUser(user)
            return
        }
        
        if let user = Plango.sharedInstance.userCache[plan.authorID] {
            self.user = user
            self.configureUser(user)
            return
        }
        
        
        self.profileImageView.showSimpleLoading()
        self.userRequest = Plango.sharedInstance.fetchUsers(endPoint) {
            (receivedUsers: [User]?, error: PlangoError?) in
            self.profileImageView.hideSimpleLoading()
            if let error = error {
                self.printPlangoError(error)
            } else if let users = receivedUsers {
                guard let user = users.first else {return}
                self.user = user
                Plango.sharedInstance.userCache[user.id] = user
                self.configureUser(user)
            }
        }
    }

    
    //my own method for image handling, currently just using alamofire extension method so this may be unneccesarry
    func loadImageForImageView(_ endPoint: String, imageView: UIImageView) {
        let cleanedEndPoint = Plango.sharedInstance.cleanEndPoint(endPoint)
        
        if let image = Plango.sharedInstance.photoCache.image(withIdentifier: cleanedEndPoint) {
            imageView.image = image
            return
        }
        
        self.request = Plango.sharedInstance.fetchImage(cleanedEndPoint, onCompletion: { (image, error) in
            if let error = error {
                self.printPlangoError(error)
            } else if let image = image {
                //hypothetically check for new cell with tableView.cellForRowAtIndexPath, if its nill cell no longer on screen, dont set image, if its there ok to set downloaded image. however this requires me to either pass in the tableView to the method or type this method in the controller instead of the cell. Also i wonder if the alamofire method somehow addresses this anyway
                imageView.image = image
            }
        })
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
