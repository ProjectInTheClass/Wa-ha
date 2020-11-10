//
//  ProjectCollectionCell.swift
//  Waha
//
//  Created by TaeHyeong Kim on 2020/09/12.
//  Copyright © 2020 TaeHyeong Kim. All rights reserved.
//

import UIKit

class ProjectCollectionCell: UICollectionViewCell {

    @IBOutlet weak var projectImageView: UIImageView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var fpsLabel: UILabel!
    @IBOutlet weak var deleteProjectButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var isEditing: Bool = false {
        didSet {
            deleteProjectButton.isHidden = !deleteProjectButton.isHidden
        }
    }
    
    var delete = false
    
    @IBAction func deleteButtonTapped(_ sender: UIButton!) {
        delete = true
    }
    
    
}
