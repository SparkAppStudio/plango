//
//  EventTableViewCell.swift
//  Plango
//
//  Created by Douglas Hewitt on 6/20/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit

protocol EventTableViewCellDelegate: class {
    func displayMapForExperience(experience: Experience)
}

class EventTableViewCell: UITableViewCell {
    
    //IBOutlets
    
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var directionsButton: UIButton!
    @IBOutlet weak var coverView: UIView!
    
    //IBActions
    @IBAction func didTapDirections(sender: UIButton) {
        //pass info back to controller to open apple or google maps with experience location
        delegate?.displayMapForExperience(experience)
    }
    
    
    weak var delegate: EventTableViewCellDelegate?
    
    var experience: Experience!
    var event: Event!

    func configure() {
        self.contentView.backgroundColor = UIColor.plangoBackgroundGray()
        
        coverView.layer.borderColor = UIColor.plangoBrown().CGColor
        coverView.layer.borderWidth = 1
        coverView.makeRoundCorners(64)
        
        directionsButton.layer.borderColor = UIColor.plangoBrown().CGColor
        directionsButton.layer.borderWidth = 2
        directionsButton.makeRoundCorners(32)
        
        guard let experience = experience, event = event else {return}
        
        let calendar = NSCalendar.currentCalendar()
        calendar.timeZone = NSTimeZone.defaultTimeZone()
        
        
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale.systemLocale()
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .ShortStyle
        formatter.dateFormat = "h:mm a"
        
        
        let components = calendar.components([.Day, .Hour, .Minute], fromDate: event.startDate!)
        let todayComponents = calendar.components([.Day, .Hour], fromDate: NSDate())
        
        if components.hour == todayComponents.hour && components.day == todayComponents.day {
            startTimeLabel.textColor = UIColor.plangoOrange()
        } else {
            startTimeLabel.textColor = UIColor.plangoBrown()
        }
        startTimeLabel.text = formatter.stringFromDate(event.startDate!)
//        print(event.startDate)
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
