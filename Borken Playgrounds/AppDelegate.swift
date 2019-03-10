//
//  AppDelegate.swift
//  Borken Playgrounds
//
//  Created by Thomas Buning on 22.10.18.
//  Copyright © 2018 Jugendwerk Borken. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import KingfisherWebP
import CoreLocation
import NotificationCenter

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let avatarSettings = "avatar_settings"
    let playgroundNotifications = "playground_notifications"
    
    var window: UIWindow?
    var user: User? = nil
    var selectedPlaygroundElements: [PlaygroundElement] = []
    var remoteConfig: RemoteConfig? = nil
    var notifications: PlaygroundNotifications? = nil
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        self.remoteConfig = RemoteConfig.remoteConfig()
        self.remoteConfig?.configSettings = RemoteConfigSettings(developerModeEnabled: true)
        self.remoteConfig?.setDefaults(fromPlist: "RemoteConfigDefaults")
        
        KingfisherManager.shared.defaultOptions = [.processor(WebPProcessor.default), .cacheSerializer(WebPSerializer.default)]
        
        loadUser()
        fetchRemoteConfig()
        
        return true
    }
    
    private func loadUser() {
        
        let db = Firestore.firestore()
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            
            db.collection("users").whereField("deviceId", isEqualTo: uuid).getDocuments(completion: { (snapshot, error) in
                if let snap = snapshot {
                    if (snap.documents.count > 0) {
                        if let firstUserDocument = snap.documents.first {
                            self.user = User(user: firstUserDocument, deviceId: uuid)
                        }
                    } else {
                        self.user = User(deviceId: uuid)
                    }
                }
            })
        }
    }
    
    private func fetchRemoteConfig() {
        
        var expirationDuration = 3600
        // If your app is using developer mode, expirationDuration is set to 0, so each fetch will
        // retrieve values from the service.
        if let developerMode = self.remoteConfig?.configSettings.isDeveloperModeEnabled {
            if (developerMode) {
                expirationDuration = 0
            }
        }
        self.remoteConfig?.fetch(withExpirationDuration: TimeInterval(expirationDuration)) { (status, error) -> Void in
            if status == .success {
                print("Config fetched!")
                self.remoteConfig?.activateFetched()
                
                if let texts = self.loadNotificationTexts() {
                    
                    self.notifications = PlaygroundNotifications.tryParse(json: texts)
                }
                
            } else {
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
            }
        }
    }
    
    func loadNotificationTexts() -> String? {
        
        return self.remoteConfig?[self.playgroundNotifications].stringValue
    }
    
    func loadAvatarSettings() -> String? {
        
        return self.remoteConfig?[self.avatarSettings].stringValue
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}

