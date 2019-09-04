//
//  rowMessage.swift
//  Trekker
//
//  Created by Fauzi Rizal on 23/08/19.
//  Copyright © 2019 Fauzi Rizal. All rights reserved.
//

import WatchKit

class RowMessage: NSObject {
    
    @IBOutlet weak var messageLabel: WKInterfaceLabel!
    var data : String!{
        didSet{
         messageLabel.setText(data)
        }
    }
}
