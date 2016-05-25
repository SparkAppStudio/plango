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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for item in 1...30 {
            minDays.append(item.description)
            maxDays.append(item.description)
        }

        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        
        self.view.addSubview(pickerView)
        
//        pickerView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
//        pickerView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
//        pickerView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        pickerView.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
        pickerView.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true

    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return minDays.count
        default:
            return maxDays.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return minDays[row]
        default:
            return maxDays[row]
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //TODO: Update Selected min max days
    }
}
