//
//  NotesTableViewCell.swift
//  Plango
//
//  Created by Douglas Hewitt on 6/22/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit

class NotesTableViewCell: UITableViewCell {

    @IBOutlet weak var notesLabel: UILabel!
    
    var experience: Experience!
    
    func configure() {
        notesLabel.text = experience.notes
    }

}
