//
//  myTableObject.swift
//  Trekker
//
//  Created by Fauzi Rizal on 23/08/19.
//  Copyright © 2019 Fauzi Rizal. All rights reserved.
//

import WatchKit

class myTableObject: NSObject {
    @IBOutlet weak var nameLabel: WKInterfaceLabel!
    @IBOutlet weak var connectionLabel: WKInterfaceLabel!
    
    var data: [String]! {
            didSet{
                nameLabel.setText(data[0])
                connectionLabel.setText(data[1])
            }
        }
    

}
