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
           "Crepaway",
           "Roselane",
           "Al Abdullah",
           "Malak El Tawouk",
           "Anthony's",
           "Hammoudi",
           "Abou Jihad",
           "Bar Tartine",
           "Mr Brown",
           "Glow",
           "Burger King",
           "Mc Donald's",
           "Pizza Hut",
           "Sandwich W Noss",
           "Poke Bol",
           "Divvy",
           "Furn Beaino",
           "Salata",
           "Falafel Arax & Snack",
           "Duo",
           "KFC",
           "Miniguette",
           "NIU",
           "SUD",
           "Pop City",
           "SiBon",
           "Dominos",
           "Dunkin Donuts",
           "Starbucks",
           "Tomatomatic"
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
