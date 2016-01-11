//
//  TimeLineCollectionViewCell.swift
//  PinterestLike
//
//  Created by 今村翔一 on 2016/01/10.
//  Copyright © 2016年 今村翔一. All rights reserved.
//

import UIKit

class TimeLineCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var postIV: UIImageView!
    @IBOutlet weak var postTextLabel: UILabel!
    @IBOutlet weak var imageViewHeightLayoutConstraint: NSLayoutConstraint!
    
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        super.applyLayoutAttributes(layoutAttributes)
        if let attributes = layoutAttributes as? TimeLineLayoutAttributes {
            imageViewHeightLayoutConstraint.constant = attributes.photoHeight
        }
    }
    
}
