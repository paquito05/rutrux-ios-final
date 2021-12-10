//
//  Ruta.swift
//  Rutrux
//
//  Created by carlos pumayalla on 11/17/21.
//  Copyright © 2021 empresa. All rights reserved.
//

import Foundation
import MapKit
class Ruta {
    var lat: Double = 0
    var lon: Double = 0
    
    var coordinate : CLLocationCoordinate2D    {
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
}
