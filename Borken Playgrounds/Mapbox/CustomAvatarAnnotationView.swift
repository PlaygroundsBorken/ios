//
//  CustomAvatarAnnotationView.swift
//  Borken Playgrounds
//
//  Created by Thomas Buning on 09.03.19.
//  Copyright © 2019 Jugendwerk Borken. All rights reserved.
//

import Foundation
import Mapbox
import Kingfisher
import SparrowKit

class CustomAvatarAnnotationView: MGLAnnotationView {
    var imageView: UIImageView!
    
    required override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    init(reuseIdentifier: String?, avatarUrl: String) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        self.imageView = UIImageView(frame: CGRect(x: 0,y: 0,width: 60,height: 60))
        let url = URL(string: avatarUrl)
        // ToDo Fix
        //self.imageView.round()
        //self.imageView.addCornerRadiusAnimation(to: 10, duration: 0.3)
        self.imageView.kf.setImage(with: url)
        self.addSubview(self.imageView)
        self.frame = self.imageView.frame
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}
