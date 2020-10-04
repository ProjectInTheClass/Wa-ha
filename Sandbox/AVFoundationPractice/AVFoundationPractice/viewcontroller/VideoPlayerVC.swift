//
//  VideoPlayerVC.swift
//  AVFoundationPractice
//
//  Created by TaeHyeong Kim on 2020/09/02.
//  Copyright © 2020 TaeHyeong Kim. All rights reserved.
//

import UIKit
import AVKit
import Photos

class VideoPlayerVC: UIViewController {
    
    var pickedURL : URL?
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    
    @IBOutlet weak var videoView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        player = AVPlayer(url: pickedURL!)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoView.bounds
        videoView.layer.addSublayer(playerLayer)
        player.play()
        
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: nil,
            queue: nil) { [weak self] _ in self?.restart() }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        playerLayer.frame = videoView.bounds
    }
    
    @IBAction func saveVideo(_ sender: Any) {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            switch status {
            case .authorized:
                self?.saveVideoToPhotos()
            default:
                print("Photos permissions not granted.")
                return
            }
        }
    }
    private func saveVideoToPhotos() {
        PHPhotoLibrary.shared().performChanges( {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.pickedURL!)
        }) { [weak self] (isSaved, error) in
            if isSaved {
                print("Video saved.")
            } else {
                print("Cannot save video.")
                print(error ?? "unknown error")
            }
            DispatchQueue.main.async {
                self?.navigationController?.popViewController(animated: true)
            }
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
