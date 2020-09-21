//
// 
//
//
//  Created by 서동성 on 2020/09/22.
//  Copyright © 2020 Arthur Hammer. All rights reserved.
//

import UIKit

import AVFoundation
import AVKit
import Photos
import Combine


class VideoLoader{
    
    private let assetIG: AVAssetImageGenerator
    private let fps: Int
    private let running_time: Double
    private let total_frame_num: Int
    
    init(
        resource_name: String,
        suffix_name: String
    ){
        let video_url = Bundle.main.url(forResource: resource_name, withExtension: suffix_name)!
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

// write video file name on resource_name & video file extension on suffix_name
let vl = VideoLoader(resource_name: "IMG_0079", suffix_name: ".MOV")

var desired_fps = 15
var frame_idx = 5000
let image = vl.getSingleFrame(frame: frame_idx)

UIImageView.init(image: image)

var str = "Done!"

print(str)
