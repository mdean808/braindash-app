//
//  PointsTableCell.swift
//  Balderdash
//
//  Created by Morgan Dean on 1/16/19.
//  Copyright © 2019 Morgan Dean. All rights reserved.
//

import UIKit

class PointsTableCell: UITableViewCell {

    @IBOutlet weak var playerName: UILabel!
    @IBOutlet weak var points: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
