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
    
    override func viewDidLoad() {
        
        jugendwerk.snp.makeConstraints { (make) in
            make.top.equalTo(self.safeArea.top).offset(navigationBarHeight + UIApplication.shared.statusBarFrame.size.height)
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
            make.bottom.equalTo(self.safeArea.bottom).offset(-60)
            make.width.lessThanOrEqualToSuperview().offset(-60)
            make.height.lessThanOrEqualTo(200)
            make.centerX.equalTo(self.view)
        }
    }
}
