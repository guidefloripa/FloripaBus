//
//  RouteDetais.swift
//  FloripaBus
//
//  Created by Guilherme Steinmann on 10/4/15.
//  Copyright © 2015 Guilherme Steinmann. All rights reserved.
//

import Foundation

struct RouteStop {
    var stopId: Int
    var stopName: String?
    var stopSequence: Int
    
    init(stopId: Int, stopName: String, stopSequence: Int) {
        self.stopId = stopId
        self.stopName = stopName
        self.stopSequence = stopSequence
    }
}

struct RouteDeparture {
    var departureId: Int
    var departureCalendar: String?
    var departureTime: String?
    
    init(departureId: Int, departureCalendar: String?, departureTime: String?) {
        self.departureId = departureId
        self.departureCalendar = departureCalendar
        self.departureTime = departureTime
    }
}