//
//  ChatUser.swift
//  LunchApp
//
//  Created by Nathalie on 09/08/2023.
//

import Foundation
import MessageKit


struct ChatUser: SenderType, Equatable {
    var senderId: String
    var displayName: String
}
