//
//  HelpViewController.swift
//  Borken Playgrounds
//
//  Created by Thomas Buning on 08.06.19.
//  Copyright © 2019 Jugendwerk Borken. All rights reserved.
//

import Foundation
import UIKit
import ImageSlideshow

class HelpViewController: UIViewController {
    
    @IBOutlet var slider: ImageSlideshow!
    
    @IBAction func backButtonClicked(_ sender: Any) {
        let navigationController = self.presentingViewController as? UINavigationController
        
        self.dismiss(animated: true) {
            let _ = navigationController?.popToRootViewController(animated: true)
        }
    }
    
    override func viewDidLoad() {
        self.slider.slideshowInterval = 5.0
        self.slider.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
        self.slider.contentScaleMode = UIView.ContentMode.scaleAspectFit
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = UIColor.lightGray
        pageControl.pageIndicatorTintColor = UIColor.black
        self.slider.pageIndicator = pageControl
        
        let imagesUrls = ["https://res.cloudinary.com/tbuning/image/upload/c_thumb,w_1200,g_face/slides/Slider-01-Karte.png", "https://res.cloudinary.com/tbuning/image/upload/c_thumb,w_1200,g_face/slides/Slider-02-Suche.png","https://res.cloudinary.com/tbuning/image/upload/c_thumb,w_1200,g_face/slides/Slider-03-Beschreibung.png","https://res.cloudinary.com/tbuning/image/upload/c_thumb,w_1200,g_face/slides/Slider-04-Bewertung.png"]
        let images = imagesUrls.map { (String) -> KingfisherSource in
            KingfisherSource(urlString: String)!
        }
        self.slider.setImageInputs(images)
    }
}
