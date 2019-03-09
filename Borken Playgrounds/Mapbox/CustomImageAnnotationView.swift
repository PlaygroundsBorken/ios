//
//  CustomImageAnnotationView.swift
//  Borken Playgrounds
//
//  Created by Thomas Buning on 01.12.18.
//  Copyright © 2018 Jugendwerk Borken. All rights reserved.
//

import Foundation
import Mapbox
import Kingfisher

class CustomImageAnnotationView: MGLAnnotationView {
    var imageView: UIImageView!
    
    required override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        self.imageView = UIImageView(frame: CGRect(x: 0,y: 0,width: 60,height: 60))
        let url = URL(string: "https://res.cloudinary.com/tbuning/image/upload/c_fit,h_400,w_400/v1543067149/badges/Logo-Turmhaus.png")
        self.imageView.kf.setImage(with: url)
        self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2
        self.imageView.clipsToBounds = true
        self.imageView.layer.borderWidth = 1
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
