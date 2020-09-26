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
import MediaPlayer

class EditVC: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var lbTitle: UILabel!
    
    var isNewVideo : Bool?
    var imageArray : [UIImage] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupProject()
        
    }
    private func setupProject(){
        
        setupTableView()
        switch isNewVideo {
        case true:
            //set up new project

            break
        case false:
            //bring existing project
            break
        default:
            break
        }
    }
    private func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
    }
   
    
    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
extension EditVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ImageFrameListTableViewCell", for: indexPath) as? ImageFrameListTableViewCell {
            cell.selectionStyle = .none
            cell.imageArray = imageArray
            cell.collectionView.reloadData()
            return cell
        }
        return UITableViewCell()
    }
    
}
