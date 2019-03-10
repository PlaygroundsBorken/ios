//
//  AvatarSettings.swift
//  Borken Playgrounds
//
//  Created by Thomas Buning on 10.03.19.
//  Copyright © 2019 Jugendwerk Borken. All rights reserved.
//

import Foundation

class AvatarSetting: Decodable {
    var body_part: String
    var options: [BodyPart]
}

class BodyPart: Decodable {
    var id: String
    var value: String
    var selected: Bool?
}

class AvatarSettings: Decodable {
    
    var avatarSetting: [AvatarSetting]
}

extension AvatarSettings {
    
    
    func createAvatarUrl() -> String {
        
        var avatarURL = "https://avataaars.io/png/260?"
        
        avatarSetting.forEach { (avatarSetting) in
            
            if let selectedOption = avatarSetting.options.first(where: { (body) -> Bool in
                return body.selected != nil && body.selected!
            })?.id {
                avatarURL += "&"
                avatarURL += avatarSetting.body_part
                avatarURL += "="
                avatarURL += selectedOption
            }
        }
        
        avatarURL += "&avatarStyle=Circle"
        
        return avatarURL
    }
    
    func fromAvatarUrl(avatarUrl: String) {
        
        avatarSetting.forEach { (setting) in
            
            setting.options.forEach({ (part) in
                part.selected = avatarUrl.contains(setting.body_part + "=" + part.id)
            })
        }
    }
    
    func selectBodyPartOption(bodyPart: String?, option: String?) {
        
        if let selectedBodyPart = bodyPart {
            if let selectedOption = option {
                
                avatarSetting.first { (setting) -> Bool in
                    setting.body_part == selectedBodyPart
                    }?.options.forEach({ (part) in
                        part.selected = part.id == selectedOption
                    })
            }
        }
    }
    
    
    static func tryParse(json: String) -> AvatarSettings? {
        
        if let jsonData = json.data(using: String.Encoding.utf8) {
            do {
                return try JSONDecoder().decode(AvatarSettings.self, from: jsonData)
            } catch _ {
                return nil
            }
        }
        return nil
    }
}
