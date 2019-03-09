//
//  PlaygroundElement.swift
//  Borken Playgrounds
//
//  Created by Thomas Buning on 01.12.18.
//  Copyright © 2018 Jugendwerk Borken. All rights reserved.
//

import Foundation

class PlaygroundElement: Hashable, Equatable {
    
    static func == (lhs: PlaygroundElement, rhs: PlaygroundElement) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(id)
        hasher.combine(image)
    }
    
    let name: String
    let id: String
    var image: String
    
    init?(documentId: String, dictionary: [String: Any]) {
        guard let name = dictionary["name"] as? String else { return nil }
        self.name = name
        self.id = documentId
        
        guard let image = dictionary["image"] as? String else { return nil }
        self.image = image
    }
    
}
