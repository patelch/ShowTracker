//
//  ShowTableViewCell.swift
//  ShowTracker
//
//  Created by Charmi Patel on 12/25/17.
//  Copyright © 2017 Charmi Patel. All rights reserved.
//

import UIKit

class ShowTableViewCell: UITableViewCell {

    // MARK: Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var ratingControl: RatingControl!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
