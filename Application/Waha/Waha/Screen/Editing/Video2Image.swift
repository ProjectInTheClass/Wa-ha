//
//  Video2Image.swift
//  Waha
//
//  Created by TaeHyeong Kim on 2020/09/26.
//  Copyright © 2020 TaeHyeong Kim. All rights reserved.
//

import UIKit

import AVFoundation
import AVKit
import Photos
import Combine

class Video2Image{
    
    
    
    let assetIG: AVAssetImageGenerator
    let fps: Int
    let running_time: Double
    let total_frame_num: Int
    
    init(
        video_url: URL
    ){
//        let video_url = Bundle.main.url(forResource: resource_name, withExtension: suffix_name)!
        let video_url = video_url
        let asset = AVAsset(url: video_url)
        self.assetIG = AVAssetImageGenerator(asset: asset)
        assetIG.appliesPreferredTrackTransform = true
        assetIG.apertureMode = AVAssetImageGenerator.ApertureMode.encodedPixels
        let tracks = asset.tracks(withMediaType: .video)
        self.fps = Int(ceil((tracks.first?.nominalFrameRate)!))
        self.running_time = Double(asset.duration.value) / 600.0
        self.total_frame_num = Int(Double(fps) * running_time)
    }
    
    func getSingleFrame(frame: Int) -> UIImage? {
        let timestamp = Double(frame) / Double(fps)
        let cm_time = CMTime(seconds: timestamp, preferredTimescale: 60)
        let image_ref: CGImage
        do {
            image_ref = try self.assetIG.copyCGImage(at: cm_time, actualTime: nil)
        } catch let error{
            print("Error: \(error)")
            return nil
        }
        return UIImage(cgImage: image_ref)
    }
    
}
