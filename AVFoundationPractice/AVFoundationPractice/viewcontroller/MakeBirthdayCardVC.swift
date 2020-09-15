//
//  MakeBirthdayCardVC.swift
//  AVFoundationPractice
//
//  Created by TaeHyeong Kim on 2020/09/02.
//  Copyright © 2020 TaeHyeong Kim. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVKit

class MakeBirthdayCardVC: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func recordVideo(_ sender: Any) {
        pickVideo(from: .camera)

    }
    
    @IBAction func pickVideo(_ sender: Any) {
        pickVideo(from: .savedPhotosAlbum)

    }
    
    private func pickVideo(from sourceType: UIImagePickerController.SourceType) {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = sourceType
        pickerController.mediaTypes = [kUTTypeMovie as String]
        pickerController.videoQuality = .typeIFrame1280x720
        if sourceType == .camera {
            pickerController.cameraDevice = .front
        }
        pickerController.delegate = self
        present(pickerController, animated: true)
    }
    
    private func showVideo(at url: URL) {
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        present(playerViewController, animated: true) {
            player.play()
        }
    }
    
}
extension MakeBirthdayCardVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard
            let url = info[.mediaURL] as? URL,
            let name = nameTextField.text
            else {
                print("Cannot get video URL")
                return
        }
        
        dismiss(animated: true) {
            VideoHelper.makeBirthdayCard(fromVideoAt: url, forName: name) { exportedURL in
                guard let exportedURL = exportedURL else {
                    return
                }
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(identifier: "VideoPlayerVC") as? VideoPlayerVC
                vc?.pickedURL = exportedURL
                self.navigationController?.pushViewController(vc!, animated: true)
                
            }
        }
    }
}
