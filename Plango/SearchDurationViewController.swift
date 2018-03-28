//
//  SearchDurationViewController.swift
//  Plango
//
//  Created by Douglas Hewitt on 5/24/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit

class SearchDurationViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    lazy var minDays = [String](["Min Days"])
    lazy var maxDays = [String](["Max Days"])

    var selectedMin: String = "1"
    var selectedMax: String = "99"
    var didUpdateConstraints = false
    let pickerView = UIPickerView()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.plangoBackgroundGray()
        
        for item in 1...99 {
            minDays.append(item.description)
            maxDays.append(item.description)
        }

        pickerView.dataSource = self
        pickerView.delegate = self
//        pickerView.frame = UIScreen.mainScreen().bounds
        
        self.view.addSubview(pickerView)

        self.view.setNeedsUpdateConstraints()
    }
    
    override func updateViewConstraints() {
        if didUpdateConstraints == false {
//            guard let parent = parentViewController else {return}
            pickerView.snp.makeConstraints { (make) in
                make.width.equalTo(UIScreen.main.bounds.width)
                make.top.equalTo(self.topLayoutGuide.snp.top)
                make.height.equalTo(UIScreen.main.bounds.height - 260)
            }
            didUpdateConstraints = true
        }

        
        super.updateViewConstraints()
    }
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return minDays.count
        default:
            return maxDays.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var title = String()
        switch component {
        case 0:
            title = minDays[row]
        default:
            title = maxDays[row]
        }
        
        return NSAttributedString(string: title, attributes: [NSAttributedStringKey.foregroundColor : UIColor.plangoText(), NSAttributedStringKey.font : UIFont.plangoBodyBig()])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            if row == 0 {
                selectedMin = "1"
            } else {
                selectedMin = minDays[row]
            }
        default:
            if row == 0 {
                selectedMax = "99"
            } else {
                selectedMax = maxDays[row]
            }
        }
    }
}
