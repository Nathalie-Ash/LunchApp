//
//  UserLunch.swift
//  LunchApp
//
//  Created by Nathalie on 27/07/2023.
//
import Foundation
import Firebase
import FirebaseFirestore

struct UserLunch {
    var userId: String
    var availability: Bool
    var restoName: String
    var lunchTime: Date // Store the lunch time as a Date
    var location: String
    var lunchDate: Date

    var dictionary: [String: Any] {
        return [
            "userId": userId,
            "availability": availability,
            "restoName": restoName,
            "lunchTime": UserLunch.getTimeFromDate(lunchTime), // Store only the time part of the date
            "location": location,
            "lunchDate": lunchDate
        ]
    }
}

extension UserLunch {
    
    
    init?(dictionary: [String : Any]) {

        guard let userId = dictionary["userId"] as? String,
              let availability = dictionary["availability"] as? Bool,
              let restoName = dictionary["restoName"] as? String,
              let lunchTimeString = dictionary["lunchTime"] as? String,
              let lunchTime = UserLunch.getTimeFromString(lunchTimeString),
              let location = dictionary["location"] as? String,
              let lunchDateTimeStamp = dictionary["lunchDate"] as? Timestamp
        else {
                  
            return nil
        }

        self.init(userId: userId,
                  availability: availability,
                  restoName: restoName,
                  lunchTime: lunchTime,
                  location:  location,
                  lunchDate: lunchDateTimeStamp.dateValue())
    
    }
}

// Helper functions to convert time to and from string representation
extension UserLunch {
    static private func getTimeFromDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        return dateFormatter.string(from: date)
    }

    static private func getTimeFromString(_ timeString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.date(from: timeString)
        
    }
}
