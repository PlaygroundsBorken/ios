//
//  SettingsViewController.swift
//  Borken Playgrounds
//
//  Created by Thomas Buning on 10.03.19.
//  Copyright © 2019 Jugendwerk Borken. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import QuickTableViewController
import Carte

class SettingsViewController: QuickTableViewController {
    
    var webViewKey = "privacy_policy"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerSettingsBundle()
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
        defaultsChanged()
        tableContents = [
            
            Section(title: "Avatar ändern", rows: [
                TapActionRow(text: "Jetzt ändern", action: { [weak self] in self?.showAlert($0) })
                ]),
            
            Section(title: "Allgemein", rows: [
                TapActionRow(text: "In Zusammenarbeit mit", action: { [weak self] in self?.showAlert($0) }),
                TapActionRow(text: "OpenSource Lizenzen", action: { [weak self] in self?.showAlert($0) }),
                TapActionRow(text: "Impressum", action: { [weak self] in self?.showAlert($0) }),
                TapActionRow(text: "Datenschutz", action: { [weak self] in self?.showAlert($0) })
                ]),
        
        ]
    }
    
    func showAlert(_ sender: Row) {
        if sender.text == "Jetzt ändern" {
            performSegue(withIdentifier: "ShowAvatarView", sender: nil)
        }
        
        if sender.text == "In Zusammenarbeit mit" {
            performSegue(withIdentifier: "madeWith", sender: nil)
        }
        
        if sender.text == "Impressum" {
            webViewKey = "impressum"
            performSegue(withIdentifier: "showWebView", sender: nil)
        }
        
        if sender.text == "Datenschutz" {
            webViewKey = "privacy_policy"
            performSegue(withIdentifier: "showWebView", sender: nil)
        }
        
        if sender.text == "OpenSource Lizenzen" {
            let carteViewController = CarteViewController()
            self.navigationController?.pushViewController(carteViewController, animated:true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let backItem = UIBarButtonItem()
        backItem.title = "Zurück"
        if let destinationVC = segue.destination as? SimpleWebViewController {
            destinationVC.webViewKey = webViewKey
        }
        
        navigationItem.backBarButtonItem = backItem
        navigationItem.title = "Zurück"
    }
    
    func registerSettingsBundle(){
        let appDefaults = [String:AnyObject]()
        UserDefaults.standard.register(defaults: appDefaults)
    }

    @objc func defaultsChanged(){
        if UserDefaults.standard.bool(forKey: "RedThemeKey") {
            self.view.backgroundColor = UIColor.red
            
        }
        else {
            self.view.backgroundColor = UIColor.green
        }
    }
    
    deinit { //Not needed for iOS9 and above. ARC deals with the observer in higher versions.
        NotificationCenter.default.removeObserver(self)
    }
}
