//
//  PlaygroundElementViewCell.swift
//  Borken Playgrounds
//
//  Created by Thomas Buning on 01.12.18.
//  Copyright © 2018 Jugendwerk Borken. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class PlaygroundElementViewCell: UICollectionViewCell {

    @IBOutlet var playgroundElementImageView: UIImageView!
    
    func displayContent(playgroundElement: PlaygroundElement) {
        
        let url = URL(string: playgroundElement.image)
        if self.playgroundElementImageView != nil && url != nil {
            self.playgroundElementImageView.kf.setImage(with: url)
        }
    }
    
    override var isSelected: Bool{
        didSet{
            if self.isSelected
            {
                if self.playgroundElementImageView != nil {
                    self.playgroundElementImageView.layer.cornerRadius = self.playgroundElementImageView.frame.size.width / 2
                    self.playgroundElementImageView.clipsToBounds = true
                    self.playgroundElementImageView.layer.borderWidth = 1
                }
                
            }
            else
            {
                if self.playgroundElementImageView != nil {
                    self.playgroundElementImageView.layer.cornerRadius = self.playgroundElementImageView.frame.size.width / 2
                    self.playgroundElementImageView.clipsToBounds = true
                    self.playgroundElementImageView.layer.borderWidth = 0
                }
            }
        }
    }
}
