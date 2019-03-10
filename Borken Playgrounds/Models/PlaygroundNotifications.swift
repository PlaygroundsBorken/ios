//
//  PlaygroundNotifications.swift
//  Borken Playgrounds
//
//  Created by Thomas Buning on 10.03.19.
//  Copyright © 2019 Jugendwerk Borken. All rights reserved.
//

import Foundation

class PlaygroundNotification: Codable {
    var title: String
    var text: String
    var visitedPlaygrounds: Int
}

class PlaygroundNotifications: Codable {
    
    var visitedPlaygroundsNotifications: [PlaygroundNotification]
}

extension PlaygroundNotification {
    
    func toHashMap() -> [String: Any] {
        return [
            "title": title,
            "text": text,
            "visitedPlaygrounds": visitedPlaygrounds
        ]
    }
}

extension PlaygroundNotifications {
    
    static func tryParse(json: String) -> PlaygroundNotifications? {
        
        if let jsonData = json.data(using: String.Encoding.utf8) {
            do {
                return try JSONDecoder().decode(PlaygroundNotifications.self, from: jsonData)
            } catch _ {
                return nil
            }
        }
        return nil
    }
 }
