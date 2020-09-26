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
    
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var lbTitle: UILabel!
    
    var isNewVideo : Bool?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupProject()
        
    }
    private func setupProject(){
        switch isNewVideo {
        case true:
            //set up new project
            startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
            break
        case false:
            //bring existing project
            break
        default:
            break
        }
    }
    //pick video from gallery
    private func startMediaBrowser(
        delegate: UIViewController & UINavigationControllerDelegate & UIImagePickerControllerDelegate,
        sourceType: UIImagePickerController.SourceType
    ) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType)
        else { return }
        
        let mediaUI = UIImagePickerController()
        mediaUI.sourceType = sourceType
        mediaUI.mediaTypes = [kUTTypeMovie as String]
        mediaUI.allowsEditing = true
        mediaUI.delegate = delegate
        delegate.present(mediaUI, animated: true, completion: nil)
    }
    private func video2ImageGenerator(video_url url : String, mediaType type : String){
        let loadedVideo = Video2Image(resource_name: url, suffix_name: type)
        var imageArray : [UIImage] = []
        for frame in 0..<loadedVideo.total_frame_num {
            imageArray.append(loadedVideo.getSingleFrame(frame: frame)!)
        }
        
        
    
   
        
    }
    

    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    
}
extension EditVC : UINavigationControllerDelegate {
    
}
extension EditVC : UIImagePickerControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        switch picker.sourceType {
        case .savedPhotosAlbum:

            // 1
            guard
                let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
                mediaType == (kUTTypeMovie as String),
                let url = info[UIImagePickerController.InfoKey.mediaURL] as? String
            else { return }
            
            // 2
            dismiss(animated: true) { [self] in
                //3
                print("media type : \(mediaType)")
                print("url: \(url)")
                video2ImageGenerator(video_url: url, mediaType: mediaType)
                
//                let player = AVPlayer(url: url)
//                let vcPlayer = AVPlayerViewController()
//                vcPlayer.player = player
//                self.present(vcPlayer, animated: true, completion: nil)
            }
            
        default:
            break
        }
    }
}
