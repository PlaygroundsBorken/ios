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
import SnapKit

class SimplePlaygroundElementViewCell: UICollectionViewCell {
    
    @IBOutlet var playgroundElementImageView: UIImageView!
    
    func displayContent(playgroundElement: PlaygroundElement) {
        
        let url = URL(string: playgroundElement.image)
        if playgroundElementImageView != nil && url != nil {
            playgroundElementImageView.kf.setImage(with: url)
        }

        playgroundElementImageView.snp.makeConstraints { (make) in
            make.bottom.top.equalTo(self.contentView)
            make.width.equalTo(playgroundElementImageView.snp.height)
        }
    }
}
