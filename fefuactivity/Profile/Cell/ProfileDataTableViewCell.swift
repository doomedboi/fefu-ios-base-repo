//
//  ProfileDataTableViewCell.swift
//  fefuactivity
//
//  Created by soFuckingHot on 21.01.2022.
//

import UIKit

struct profileTableStringModel {
    let type: String
    let value: String
}

class ProfileDataTableViewCell: UITableViewCell {

    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(_ model: profileTableStringModel) {
        self.typeLabel.text = model.type
        self.valueLabel.text = model.value
    }
    
}
