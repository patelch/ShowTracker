//
//  FestivalTableViewCell.swift
//  ShowTracker
//
//  Created by Charmi Patel on 12/27/17.
//  Copyright © 2017 Charmi Patel. All rights reserved.
//

import UIKit

class FestivalTableViewCell: UITableViewCell {

    @IBOutlet weak var festivalNameField: UITextField!
    @IBOutlet weak var isFestivalSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
