//
//  EventTableViewCell.swift
//  Plango
//
//  Created by Douglas Hewitt on 6/20/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    
    //IBOutlets
    
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var directionsButton: UIButton!
    
    //IBActions
    @IBAction func didTapDirections(sender: UIButton) {
        //open apple or google maps with experience location
    }
    
    
    
    
    var experience: Experience!
    var event: Event!

    func configure() {
        self.contentView.backgroundColor = UIColor.plangoCream()
        directionsButton.setTitleColor(UIColor.plangoBrown(), forState: .Normal)
        guard let experience = experience, event = event else {return}
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Hour, .Minute], fromDate: event.startDate!)
        
//        startTimeLabel.text = formatter.stringFromDate(event.startDate!)
        startTimeLabel.text = "\(components.hour):\(components.minute)"
        
        titleLabel.text = experience.name
        
        guard let endPoint = experience.avatar else {return}
        let theURL = NSURL(string: endPoint) //no need to clean for experiences
        coverImageView.af_setImageWithURL(theURL!)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        coverImageView.af_cancelImageRequest()
        event = nil
        experience = nil
        
    }

}
