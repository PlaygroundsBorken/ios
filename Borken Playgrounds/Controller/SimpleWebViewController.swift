//
//  SimpleWebViewController.swift
//  Borken Playgrounds
//
//  Created by Thomas Buning on 14.03.19.
//  Copyright © 2019 Jugendwerk Borken. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class SimpleWebViewController: UIViewController {
    
    var webViewKey: String?
    @IBOutlet var webView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadHTMLStringImage()
    }
    
    func loadHTMLStringImage() -> Void {
        
        if let key = webViewKey {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if let html = appDelegate.loadString(identifier: key) {
                
                let header = "<!DOCTYPE html><html><head><style type='text/css'>body {font-family: '.SF UI Text';font-size: 3em;}</style></head><body>"
                let footer = "</body></html>"
                webView.loadHTMLString(header + html + footer, baseURL: nil)
            }
        }
    }
}
