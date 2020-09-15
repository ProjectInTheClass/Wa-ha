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
    
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!

    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var lbTitle: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func actionImportVideo(_ sender: Any) {
        pickVideo(from: .savedPhotosAlbum)
        
    }
    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setupVideo(_ videoURL : URL?){
        
        player = AVPlayer(url: videoURL!)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoView.bounds
        videoView.layer.addSublayer(playerLayer)
        player.play()
        
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: nil,
            queue: nil) { [weak self] _ in self?.restart() }
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
    
    
    private func restart() {
        player.seek(to: .zero)
        player.play()
    }
    deinit {
           NotificationCenter.default.removeObserver(
               self,
               name: .AVPlayerItemDidPlayToEndTime,
               object: nil)
       }
    
    
}
extension EditVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard
            let url = info[.mediaURL] as? URL,
            let name = lbTitle.text
            else {
                print("Cannot get video URL")
                return
        }
        print()
    }
}
