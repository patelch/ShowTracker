//
//  Show.swift
//  ShowTracker
//
//  Created by Charmi Patel on 12/16/17.
//  Copyright © 2017 Charmi Patel. All rights reserved.
//

import UIKit
import GooglePlaces
import os.log

class Show: NSObject, NSCoding {
    
    // MARK: Types
    struct PropertyKey {
        static let artists = "artists"
        static let startDate = "startDate"
        static let endDate = "endDate"
        static let location = "location"
        static let isFestival = "isFestival"
        static let festivalName = "festivalName"
        static let rating = "rating"
    }
    
    // MARK: Properties
    var artists: [String]
    var startDate: Date
    var endDate: Date
    var location: GMSPlace?
    var isFestival: Bool
    var festivalName: String?
    var rating: Int
    
    // MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("shows")
    
    init?(artists: [String], startDate: Date, endDate: Date, location: GMSPlace?, isFestival: Bool, festivalName: String?, rating: Int) {
        
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
        
        guard startDate < endDate else {
            return nil
        }
        
        guard isFestival && festivalName != nil || !isFestival else {
            return nil
        }
        
        guard (rating >= 0) && (rating <= 5) else {
            return nil
        }
        
        self.artists = artists
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
        self.isFestival = isFestival
        self.festivalName = festivalName
        self.rating = rating
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        // The artist list is required. If we cannot decode the artists, the initializer should fail.
        guard let artists = aDecoder.decodeObject(forKey: PropertyKey.artists) as? [String] else {
            os_log("Unable to decode the artists for a Show object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let startDate = aDecoder.decodeObject(forKey: PropertyKey.startDate) as? Date else {
            os_log("Unable to decode the start date for a Show object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let endDate = aDecoder.decodeObject(forKey: PropertyKey.endDate) as? Date else {
            os_log("Unable to decode the end date for a Show object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        // TODO: make location not optional
        let location = aDecoder.decodeObject(forKey: PropertyKey.location) as? GMSPlace
        let isFestival = aDecoder.decodeBool(forKey: PropertyKey.isFestival)
        let festivalName = aDecoder.decodeObject(forKey: PropertyKey.festivalName) as? String
        let rating = aDecoder.decodeInteger(forKey: PropertyKey.rating)
        
        self.init(artists: artists, startDate: startDate, endDate: endDate, location: location, isFestival: isFestival, festivalName: festivalName, rating: rating)
    }
    
    // MARK: NSCoding Protocol
    func encode(with aCoder: NSCoder) {
        aCoder.encode(artists, forKey: PropertyKey.artists)
        aCoder.encode(startDate, forKey: PropertyKey.startDate)
        aCoder.encode(endDate, forKey: PropertyKey.endDate)
        aCoder.encode(location, forKey: PropertyKey.location)
        aCoder.encode(isFestival, forKey: PropertyKey.isFestival)
        aCoder.encode(festivalName, forKey: PropertyKey.festivalName)
        aCoder.encode(rating, forKey: PropertyKey.rating)
    }
    
}
