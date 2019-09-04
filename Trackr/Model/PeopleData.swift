//
//  PeopleData.swift
//  Trackr
//
//  Created by Fauzi Rizal on 27/08/19.
//  Copyright © 2019 Fauzi Rizal. All rights reserved.
//

import Foundation


class People {
    
    var name: String!
    var longitude: Double
    var latitude: Double
    
    init(name: String, longitude: Double, latitude: Double) {
        self.name = name
        self.longitude = longitude
        self.latitude = latitude
    }
}
