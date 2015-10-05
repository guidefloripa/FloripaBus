//
//  Route.swift
//  FloripaBus
//
//  Created by Guilherme Steinmann on 10/4/15.
//  Copyright © 2015 Guilherme Steinmann. All rights reserved.
//

import Foundation

struct Route {
    var routeLongName: String?
    var routeId: Int
    
    init(longName: String?, routeId: Int) {
        self.routeLongName = longName
        self.routeId = routeId
    }
}