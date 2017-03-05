//
//  EventTableViewCell.swift
//  Plango
//
//  Created by Douglas Hewitt on 6/20/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


protocol EventTableViewCellDelegate: class {
    func didSendExperience(_ experience: Experience)
}

class EventTableViewCell: UITableViewCell {
    
    //IBOutlets
    
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var directionsButton: UIButton!
    @IBOutlet weak var coverView: UIView!
    
    //IBActions
    @IBAction func didTapDirections(_ sender: UIButton) {
        //pass info back to controller to open apple or google maps with experience location
        delegate?.didSendExperience(experience)
    }
    
    
    weak var delegate: EventTableViewCellDelegate?
    
    var experience: Experience!
    var event: Event!

    func configure() {
        self.contentView.backgroundColor = UIColor.plangoBackgroundGray()
        
        coverView.makeRoundCorners(64)
        
        directionsButton.makeCircle()
        
        guard let experience = experience, let event = event else {return}
        
        if experience.geocode?.count < 2 {
            directionsButton.isHidden = true
        } else {
            directionsButton.isHidden = false
        }
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        
        
        let formatter = DateFormatter()
        formatter.locale = Locale.system
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.dateFormat = "h:mm a"
        
        
        let components = (calendar as NSCalendar).components([.day, .hour, .minute], from: event.startDate! as Date)
        let todayComponents = (calendar as NSCalendar).components([.day, .hour], from: Date())
        
        if components.hour == todayComponents.hour && components.day == todayComponents.day {
            startTimeLabel.textColor = UIColor.plangoOrange()
        } else {
            startTimeLabel.textColor = UIColor.plangoTextLight()
        }
        startTimeLabel.text = formatter.string(from: event.startDate! as Date)
        titleLabel.text = experience.name
        
        coverImageView.plangoImage(experience)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        coverImageView.af_cancelImageRequest()
        event = nil
        experience = nil
        
    }

}
