//
//  VideoSelectVC.swift
//  Waha
//
//  Created by TaeHyeong Kim on 2020/09/20.
//  Copyright © 2020 TaeHyeong Kim. All rights reserved.
//

import UIKit
import AVKit
class VideoSelectVC: UIViewController {

    @IBOutlet weak var imgview: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        setupVideo()
    }
    
    private func setupVideo() {
        let assetURL = URL(fileURLWithPath: Bundle.main.path(forResource: "movie", ofType:"mov")!)
        let asset = AVAsset(url: assetURL)
        imgview.image = imageFromVideo(url: assetURL, at: 0)
        print(imageFromVideo(url: assetURL, at: 10))
    }
    
    
    func imageFromVideo(url: URL, at time: TimeInterval) -> UIImage? {
        let asset = AVURLAsset(url: url)
        let assetIG = AVAssetImageGenerator(asset: asset)
        assetIG.appliesPreferredTrackTransform = true
        assetIG.apertureMode = AVAssetImageGenerator.ApertureMode.encodedPixels

        let cmTime = CMTime(seconds: time, preferredTimescale: 60)
        let thumbnailImageRef: CGImage
        do {
            thumbnailImageRef = try assetIG.copyCGImage(at: cmTime, actualTime: nil)
        } catch let error {
            print("Error: \(error)")
            return nil
        }

        return UIImage(cgImage: thumbnailImageRef)
    }
    
    


}
