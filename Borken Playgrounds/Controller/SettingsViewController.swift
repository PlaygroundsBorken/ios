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

class SettingsViewController: QuickTableViewController {
    
    var webViewKey = "privacy_policy"
    var webViewTitle = "Datenschutz"
    
    @IBAction func backButtonClicked(_ sender: Any) {
        let navigationController = self.presentingViewController as? UINavigationController
        
        self.dismiss(animated: true) {
            let _ = navigationController?.popToRootViewController(animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerSettingsBundle()
        defaultsChanged()
        tableContents = [
            
            Section(title: "Avatar ändern", rows: [
                TapActionRow(text: "Jetzt ändern", action: { [weak self] in self?.showAlert($0) })
                ]),
            
            Section(title: "Allgemein", rows: [
                TapActionRow(text: "In Zusammenarbeit mit", action: { [weak self] in self?.showAlert($0) }),
                TapActionRow(text: "Du hast eine Beschwerde?", action: { [weak self] in self?.showAlert($0) }),
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
        
        if sender.text == "Du hast eine Beschwerde?" {
            if let url = URL(string: "https://www.borken.de/buergerservice/ideen-und-beschwerdemanagement/ideen-u-beschwerdemanagement.html") {
                UIApplication.shared.open(url)
            }
        }
        
        if sender.text == "Impressum" {
            webViewKey = "impressum"
            webViewTitle = "Impressum"
            performSegue(withIdentifier: "showWebView", sender: nil)
        }
        
        if sender.text == "Datenschutz" {
            webViewKey = "privacy_policy"
            webViewTitle = "Datenschutz"
            performSegue(withIdentifier: "showWebView", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let navVC = segue.destination as? UINavigationController {
            
            if let destinationVC = navVC.rootViewController as? SimpleWebViewController {
                destinationVC.webViewKey = webViewKey
                navVC.rootViewController?.navigationItem.title = webViewTitle
            }
        }
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
}
