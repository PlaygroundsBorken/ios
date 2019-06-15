//
//  CollaborationController.swift
//  Borken Playgrounds
//
//  Created by Thomas Buning on 16.03.19.
//  Copyright © 2019 Jugendwerk Borken. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Kingfisher

class CollaborationController: UIViewController {
    
    @IBOutlet var jugendwerk: UIImageView!
    @IBOutlet var lwl: UIImageView!
    @IBOutlet var borken: UIImageView!
    @IBAction func backButtonClicked(_ sender: UIBarButtonItem) {
        let navigationController = self.presentingViewController as? UINavigationController
        
        self.dismiss(animated: true) {
            let _ = navigationController?.popToRootViewController(animated: true)
        }
    }
    
    override func viewDidLoad() {
        
        jugendwerk.snp.makeConstraints { (make) in
            
            make.top.equalTo(self.view.safeArea.top)
            make.width.lessThanOrEqualToSuperview().offset(-60)
            make.height.lessThanOrEqualTo(200)
            make.centerX.equalTo(self.view)
        }
        
        lwl.snp.makeConstraints { (make) in
            make.top.equalTo(jugendwerk.snp.bottom)
            make.bottom.equalTo(borken.snp.top)
            make.width.lessThanOrEqualToSuperview().offset(-60)
            make.height.lessThanOrEqualTo(200)
            make.centerX.equalTo(self.view)
        }
        
        borken.snp.makeConstraints { (make) in
            
            make.bottom.equalTo(self.view.safeArea.bottom).offset(-60)
            make.width.lessThanOrEqualToSuperview().offset(-60)
            make.height.lessThanOrEqualTo(200)
            make.centerX.equalTo(self.view)
        }
    }
}

extension UIView {
    
    var safeArea: ConstraintBasicAttributesDSL {
        
        #if swift(>=3.2)
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.snp
        }
        return self.snp
        #else
        return self.snp
        #endif
    }
}
