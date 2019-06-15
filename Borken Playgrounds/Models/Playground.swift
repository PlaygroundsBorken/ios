//
//  Playground.swift
//  Borken Playgrounds
//
//  Created by Thomas Buning on 01.12.18.
//  Copyright © 2018 Jugendwerk Borken. All rights reserved.
//

import Foundation
import Firebase

class Playground {
    
    let lat: Double?
    let lng: Double?
    let rating: Double?
    let name: String
    let id: String
    var images: [String]
    var items: [PlaygroundElement]
    let description: String?
    let description2: String?
    
    init?(documentId: String, dictionary: [String: Any], completion: @escaping (_ playgroundElement: PlaygroundElement) -> Void) {
        guard let name = dictionary["name"] as? String else { return nil }
        self.name = name
        self.id = documentId
        
        self.lat = Double(dictionary["lat"] as! String)
        self.lng = Double(dictionary["lng"] as! String)
        self.rating = dictionary["rating"] as? Double
        self.description = (dictionary["description"] as? [String: Any])?["html"] as? String
        self.description2 = (dictionary["description2"] as? [String: Any])?["html"] as? String
        
        self.images = []
        self.items = []
        if let image = dictionary["images"] as? NSArray {
            
            image.forEach { (value) in
                
                let i = value as? [String: Any]
                let inner = i?["image"] as? [String: Any]
                let imageUrl = inner?["url"] as! String
                self.images.append(imageUrl)
            }
        }
        
        if let items = dictionary["items"] as? [String: Bool] {
            
            let playgroundDocumentIds = items.filter({ (arg0) -> Bool in
                arg0.value
            }).map { arg0 -> String in
                arg0.key
            }
            let db = Firestore.firestore()
            
            playgroundDocumentIds.forEach { (documentId: String) in
                db.collection("playgroundelements").document(documentId).getDocument { (document, err) in
                    
                    if let document = document, document.exists {
                        let playgroundElement = PlaygroundElement(documentId: document.documentID, dictionary: document.data()!)
                        if (playgroundElement != nil) {
                            self.items.append(playgroundElement!)
                            completion(playgroundElement!)
                        }
                    } else {
                        print("Document does not exist")
                    }
                }
            }
        }
    }
}
