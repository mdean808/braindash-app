//
//  VotesTableCell.swift
//  Balderdash
//
//  Created by Morgan Dean on 1/16/19.
//  Copyright © 2019 Morgan Dean. All rights reserved.
//

import UIKit

class VotesTableCell: UITableViewCell {

    @IBOutlet weak var response: UILabel!
    @IBOutlet weak var votes: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
