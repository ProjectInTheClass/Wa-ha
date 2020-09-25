//
//  EditVC.swift
//  Waha
//
//  Created by TaeHyeong Kim on 2020/09/12.
//  Copyright © 2020 TaeHyeong Kim. All rights reserved.
//

import UIKit
import AVKit
import MobileCoreServices
import Photos

class EditVC: UIViewController {
    

    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var lbTitle: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }


    
    
}
