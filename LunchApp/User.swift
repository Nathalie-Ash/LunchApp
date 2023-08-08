//
//  user.swift
//  LunchApp
//
//  Created by Nathalie on 25/07/2023.
//

//
//  Copyright (c) 2016 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import Firebase
import FirebaseFirestore

struct User {
    
    var userId: String
    var name: String
    var birthday: String
    var office: String
    var food: [String]
    var restaurant: [String]
    var isPublic: Bool
    var profilePictureURL: String
    
    
    var dictionary: [String: Any] {
        return [
            "userId": userId,
            "name": name,
            "birthday": birthday,
            "office": office,
            "food": food,
            "restaurant": restaurant,
            "isPublic": isPublic,
            "profilePictureURL": profilePictureURL
        ]
    }
}

extension User {
    
    static let restaurants = [
        "Roadster",
        "Zaatar w Zeit",
        "Kabaji",
        "Deek Duke",
        "Roselane",
        "Al Abdullah",
        "Malak El Tawouk"
    ]
    
    static let food = [
        "Brunch", "Burgers", "Coffee", "Deli", "Dim Sum", "Indian", "Italian",
        "Mediterranean", "Mexican", "Pizza", "Ramen", "Sushi"
    ]
    
    init?(dictionary: [String : Any]) {
        guard let userId = dictionary["userId"] as? String,
              let name = dictionary["name"] as? String,
              let birthday = dictionary["birthday"] as? String,
              let office = dictionary["office"] as? String,
              let food = dictionary["food"] as? [String],
              let restaurant = dictionary["restaurant"] as? [String],
              let isPublic = dictionary["isPublic"] as? Bool,
              let profilePictureURL = dictionary["profilePictureURL"] as? String else { return nil }
        
        self.init(userId: userId,
                  name: name,
                  birthday: birthday,
                  office: office,
                  food: food,
                  restaurant: restaurant,
                  isPublic: isPublic,
                  profilePictureURL: profilePictureURL)
    }
    
}




