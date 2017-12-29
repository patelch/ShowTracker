//
//  Show.swift
//  ShowTracker
//
//  Created by Charmi Patel on 12/16/17.
//  Copyright © 2017 Charmi Patel. All rights reserved.
//

import Foundation

class Show {
    
    // MARK: Properties
    var artists: [String]
    var date: Date
    var location: String
    var rating: Int
    
    init?(artists: [String], date: Date, location: String, rating: Int) {
        
        // Conditions to ensure safe data
        
        var validString = true
        for artist in artists {
            if artist.isEmpty {
                validString = false
            }
        }

        guard artists.count > 0 && validString else {
            return nil
        }
        
        guard !location.isEmpty else {
            return nil
        }
        
        guard (rating >= 0) && (rating <= 5) else {
            return nil
        }
        
        self.artists = artists
        self.date = date
        self.location = location
        self.rating = rating
    }
    
}
