//
//  FilledLocationTableViewCell.swift
//  ShowTracker
//
//  Created by Charmi Patel on 12/28/17.
//  Copyright © 2017 Charmi Patel. All rights reserved.
//

import UIKit

class FilledLocationTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
