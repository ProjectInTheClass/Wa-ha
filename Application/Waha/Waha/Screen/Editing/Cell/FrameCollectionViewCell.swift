//
//  FrameCollectionViewCell.swift
//  Waha
//
//  Created by TaeHyeong Kim on 2020/09/26.
//  Copyright © 2020 TaeHyeong Kim. All rights reserved.
//

import UIKit

class FrameCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var border_bottom: UIView!
    @IBOutlet weak var border_left: UIView!
    
    @IBOutlet weak var border_right: UIView!
    @IBOutlet weak var border_top: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imgview: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


}
