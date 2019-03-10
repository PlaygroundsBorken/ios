//
//  File.swift
//  Borken Playgrounds
//
//  Created by Thomas Buning on 09.03.19.
//  Copyright © 2019 Jugendwerk Borken. All rights reserved.
//

import Foundation
import FirebaseFirestore

class User {
    
    var documentId: String
    let deviceId: String
    var avatarUrl: String
    var visitedPlaygrounds: [String] = []
    var downVotedPlaygrounds:[String] = []
    var upVotedPlaygrounds:[String] = []
    var userRemarks: [String] = []
    
    let defaultAvatarUrl = "https://avataaars.io/png/260?topType=NoHair&accessoriesType=Blank&clotheType=BlazerShirt&eyeType=Default&avatarStyle=Circle"
    
    init(deviceId: String) {
        self.documentId = ""
        self.deviceId = deviceId
        self.avatarUrl = defaultAvatarUrl
        let visitedPlaygrounds = [String:Bool]()
        let downVotedPlaygrounds = [String:Bool]()
        let upVotedPlaygrounds = [String:Bool]()
        let userRemarks = [String:Bool]()
        let db = Firestore.firestore()
        
        var userDocument: [String: Any] = [:]
        userDocument["deviceId"] = deviceId
        userDocument["visitedPlaygrounds"] = visitedPlaygrounds
        userDocument["downVotedPlaygrounds"] = downVotedPlaygrounds
        userDocument["upVotedPlaygrounds"] = upVotedPlaygrounds
        userDocument["userRemarks"] = userRemarks
        userDocument["avatarURL"] = avatarUrl
        
        db.collection("users").addDocument(data: userDocument).addSnapshotListener { (doc, err) in
            
            if let user = doc {
                
                let createdUser = User(user: user, deviceId: deviceId)
                self.documentId = createdUser.documentId
                self.avatarUrl = createdUser.avatarUrl
                self.downVotedPlaygrounds = createdUser.downVotedPlaygrounds
                self.upVotedPlaygrounds = createdUser.upVotedPlaygrounds
                self.userRemarks = createdUser.userRemarks
            }
        }
    }
    
    init(user: DocumentSnapshot, deviceId: String) {
        
        self.deviceId = deviceId
        
        if let visitedPlaygroundList = user.get("visitedPlayground") as? [Any] {
            
            self.visitedPlaygrounds = visitedPlaygroundList.toStringList()
        } else {
            visitedPlaygrounds = []
        }
        
        if let downVotedPlaygroundsList = user.get("downVotedPlaygrounds") as? [Any] {
            
            self.downVotedPlaygrounds = downVotedPlaygroundsList.toStringList()
        } else {
            self.downVotedPlaygrounds = []
        }
        
        if let upVotedPlaygroundsList = user.get("upVotedPlaygrounds") as? [Any] {
            
            self.upVotedPlaygrounds = upVotedPlaygroundsList.toStringList()
        } else {
            upVotedPlaygrounds = []
        }
        
        if let userRemarksList = user.get("userRemarks") as? [Any] {
            
            self.userRemarks = userRemarksList.toStringList()
        } else {
            userRemarks = []
        }
        
        if let avatarUrl = user.get("avatarURL") as? String {
            
            self.avatarUrl = avatarUrl
        } else {
            
            avatarUrl = defaultAvatarUrl
        }
        self.documentId = user.documentID
    }
    
    func getDefaultAvatarURL() -> String {
        var avatarURL = "https://avataaars.io/png/260?"
        avatarURL += "&topType=NoHair"
        avatarURL += "&accessoriesType=Blank"
        avatarURL += "&clotheType=BlazerShirt"
        avatarURL += "&eyeType=Default"
        avatarURL += "&avatarStyle=Circle"
        
        return avatarURL
    }
    
    func saveRemark(comment: String, playground: Playground?) {
        
        if let selectedPlayground = playground {
            
            let db = Firestore.firestore()
            
            var documentData: [String:Any] = [:]
            documentData["remarkedPlayground"] = selectedPlayground.id
            documentData["remarkee"] = documentId
            documentData["text"] = comment
            
            db.collection("userRemarks").addDocument(data: documentData)
        }
    }
    
    func save() {
        let db = Firestore.firestore()
        let document = db.collection("users").document(self.documentId)
        var documentData: [String:Any] = [:]
        
        documentData["visitedPlaygrounds"] = self.visitedPlaygrounds.map { (playgroundId) -> [String:Bool] in
            return [playgroundId:true]
        }
        documentData["downVotedPlaygrounds"] = self.downVotedPlaygrounds.map({ (playgroundId) -> [String:Bool] in
            return [playgroundId:true]
        })
        documentData["upVotedPlaygrounds"] = self.upVotedPlaygrounds.map({ (playgroundId) -> [String:Bool] in
            return [playgroundId:true]
        })
        documentData["userRemarks"] = self.userRemarks
        documentData["avatarURL"] = self.avatarUrl
        
        document.updateData(documentData)
    }
}

extension Array {
    
    func toStringList() -> [String] {
        
        let visitedPlaygroundList = self.filter { (element) -> Bool in
            
            if let castedElement = element as? (Bool, String) {
                return castedElement.0
            }
            return false
            }.compactMap { (element) -> String? in
                if let castedElement = element as? (Bool, String) {
                    return castedElement.1
                }
                return nil
        }
        
        return visitedPlaygroundList
    }
}
