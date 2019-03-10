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
    var selected: Bool = false
}

class AvatarSettings: Decodable {
    
    var avatarSetting: [AvatarSetting]
}

extension AvatarSettings {
    
    func selectAvatarSetting(body_part: String, option_value: String) {
        
        avatarSetting.filter { (avatarSetting) -> Bool in
            avatarSetting.body_part == body_part
            }.forEach { (avatarSetting) in
                avatarSetting.options.forEach({ (option) in
                    option.selected = option.value == option_value
                })
        }
    }
    
    func setFromAvatarUrl(avatarURL: String) {
        
        avatarSetting.forEach { (setting) in
            setting.options.forEach({ (body) in
                body.selected = avatarURL.contains(setting.body_part + "=" + body.id)
            })
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
