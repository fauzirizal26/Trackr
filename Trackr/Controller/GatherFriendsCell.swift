//
//  GatherFriendsCell.swift
//  Trackr
//
//  Created by Fauzi Rizal on 27/08/19.
//  Copyright © 2019 Fauzi Rizal. All rights reserved.
//

import UIKit

class GatherFriendsCell: UITableViewCell {
    
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var connectionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        circleView.layer.cornerRadius = (circleView.frame.size.width / 2)
        circleView.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
