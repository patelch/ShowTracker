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
    var artist: String
    var date: Date
    var location: String
    var rating: Int
    
    init?(artist: String, date: Date, location: String, rating: Int) {
        
        // Conditions to ensure safe data
        
        guard !artist.isEmpty else {
            return nil
        }
        
        guard !location.isEmpty else {
            return nil
        }
        
        guard (rating >= 0) && (rating <= 5) else {
            return nil
        }
        
        self.artist = artist
        self.date = date
        self.location = location
        self.rating = rating
    }
    
    
}
