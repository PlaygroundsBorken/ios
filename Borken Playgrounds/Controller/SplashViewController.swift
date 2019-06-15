//
//  SplashViewController.swift
//  Borken Playgrounds
//
//  Created by Thomas Buning on 11.06.19.
//  Copyright © 2019 Jugendwerk Borken. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

class SplashViewController: UIViewController {
    
    @IBOutlet var progressBar: UIProgressView!
    
    override func viewDidLoad() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        Auth.auth().signInAnonymously() { (authResult, error) in
            self.progressBar.progress = 10.0
            appDelegate.loadUser() {
                () -> () in
                self.progressBar.progress = 70.0
             
                appDelegate.fetchRemoteConfig()
                self.progressBar.progress = 100.0
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "Mapbox") as UIViewController
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
}
