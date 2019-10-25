//
//  PlayerTableViewCell.swift
//  Balderdash
//
//  Created by Morgan Dean on 1/10/19.
//  Copyright © 2019 Morgan Dean. All rights reserved.
//

import UIKit

class PlayerTableViewCell: UITableViewCell {

    @IBOutlet weak var nickLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
