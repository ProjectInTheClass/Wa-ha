//
//  TemporaryProjectFile.swift
//  201012_Waha_ProjectList_v001
//
//  Created by Teo Hwang on 2020/10/26.
//

import Foundation
import UIKit

struct TemporaryProject {
    
    var projectName: String
    var frameRate: Int
    var thumbNail: UIImage
    var videoURL : String
    
    init(projectName: String, frameRate: Int, thumbNail: UIImage, videoURL : String) {
        self.projectName = projectName
        self.frameRate = frameRate
        self.thumbNail = thumbNail
        self.videoURL = videoURL
    }
    
}
