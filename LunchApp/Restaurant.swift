//
//  Restaurant.swift
//  LunchApp
//
//  Created by Nathalie on 27/07/2023.
//

import Foundation
import Firebase
import FirebaseFirestore

struct Restaurant {
    
    var restoID: String
    var name: String
    static let restaurants = [
           "Roadster",
           "Zaatar w Zeit",
           "Kababji",
           "Deek Duke",
           "Roselane",
           "Al Abdullah",
           "Malak El Tawouk",
           "Anthony's",
           "Hammoudi",
           "Abou Jihad"
       ]

    var dictionary: [String: Any] {
        return [ "name": name
        ]
    }
}

extension Restaurant {
    

    init?(dictionary: [String : Any]) {
        guard let restoId = dictionary["restoId"] as? String,
              let name = dictionary["name"] as? String else { return nil }
        
        self.init( restoID: restoId,
                  name: name)
    }
    
}


/*
enum TestRestaurants : String {
    case zwz = "Zaatar w Zeit"
    case roadster = "Roadster"
    case dd = "Deek Duke"
    
}


struct allRestaurants {
    let allRestaurants : [TestRestaurants] = [.zwz, .roadster, .dd]
    
}


struct Restaurant {

let resto: TestRestaurant

var title: String { resto.rawValue }

}
*/
