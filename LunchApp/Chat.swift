//
//  Chat.swift
//  LunchApp
//
//  Created by Nathalie on 09/08/2023.
//

import Foundation


struct Chat {
    var users: [String]
    var dictionary: [String: Any] {
    return ["users": users]
       }
}


extension Chat {
    init?(dictionary: [String:Any]) {
    guard let chatUsers = dictionary["users"] as? [String] else { return nil }
    self.init(users: chatUsers)
    }
}
