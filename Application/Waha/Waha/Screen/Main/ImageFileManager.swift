//
//  ImageFileManager.swift
//  Waha
//
//  Created by 서동성 on 2020/10/20.
//  Copyright © 2020 TaeHyeong Kim. All rights reserved.
//

import UIKit
import Foundation

class ImageFileManager {
    static let shared: ImageFileManager = ImageFileManager ()
    
    // Save Image
    // name: ImageName
    func saveImage(image: UIImage, name: String, onSuccess: @escaping ((Bool) -> Void)){
        
        guard let data: Data = image.jpegData(compressionQuality: 1) ?? image.pngData() else { return }
        
        if let directory: NSURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL {
            
            do{
                try data.write(to: URL(string: directory.relativeString + name)!)
                onSuccess(true)
            } catch let error as NSError {
                print("Couldn't saveImage: \(error), \(error.userInfo)")
                onSuccess(false)
            }
        }
    }
    
    func getSavedImage(named: String) -> UIImage? {
        if let dir: URL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false){
            let path: String = URL(string: dir.relativeString + named)!.path
            
            let image: UIImage? = UIImage(contentsOfFile: path)
            
            return image
        }
        return nil
    }
}
