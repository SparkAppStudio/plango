//
//  PlansTableViewCell.swift
//  Plango
//
//  Created by Douglas Hewitt on 4/6/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
import Alamofire

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
    var request: Request?
    
    
    func configure() {
        self.layoutIfNeeded()
        if let cellUser = user {
            profileNameLabel.text = cellUser.userName
            guard let endPoint = cellUser.avatar else {return}
            let cleanURL = NSURL(string: Plango.sharedInstance.cleanEndPoint(endPoint))
            profileImageView.af_setImageWithURL(cleanURL!)
        }
        if let cellPlan = plan {
            planNameLabel.text = cellPlan.name
            
            guard let endPoint = cellPlan.avatar else {return}
            print(endPoint)
            let cleanURL = NSURL(string: Plango.sharedInstance.cleanEndPoint(endPoint))
            coverImageView.af_setImageWithURL(cleanURL!)
            
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
    
    func reset() {
        coverImageView.af_cancelImageRequest()
        profileImageView.af_cancelImageRequest()
//        self.request?.cancel() //for when using my own method and request manager
        
//        coverImageView.image = nil
//        profileImageView.image = nil
    }
    
    //my own method for image handling, currently just using alamofire extension method so this may be unneccesarry
    func loadImageForImageView(endPoint: String, imageView: UIImageView) {
        let cleanedEndPoint = Plango.sharedInstance.cleanEndPoint(endPoint)
        
        if let image = Plango.sharedInstance.photoCache.imageWithIdentifier(cleanedEndPoint) {
            imageView.image = image
            return
        }
        
        self.request = Plango.sharedInstance.fetchImage(cleanedEndPoint, onCompletion: { (image, error) in
            if let error = error {
                print(Helper.errorMessage(self, error: error, message: nil))
            } else if let image = image {
                //hypothetically check for new cell with tableView.cellForRowAtIndexPath, if its nill cell no longer on screen, dont set image, if its there ok to set downloaded image. however this requires me to either pass in the tableView to the method or type this method in the controller instead of the cell. Also i wonder if the alamofire method somehow addresses this anyway
                imageView.image = image
            }
        })
    }
    
    override func prepareForReuse() {
        reset()
        super.prepareForReuse()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
