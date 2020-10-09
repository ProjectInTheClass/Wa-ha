//
//  ViewController.swift
//  Waha
//
//  Created by TaeHyeong Kim on 2020/09/11.
//  Copyright © 2020 TaeHyeong Kim. All rights reserved.
//

import UIKit
import AVKit
import MobileCoreServices
import Photos
import MediaPlayer

class MainVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var projectArray : [String] = ["프로젝트 추가","예시1","예시2"]
    var imageArray : [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        collectionView.collectionViewLayout = layout
        
        let projectCellNib = UINib(nibName: "ProjectCollectionCell", bundle: nil)
        self.collectionView.register(projectCellNib, forCellWithReuseIdentifier: "ProjectCollectionCell")
        
    }
    private func goProjectVC(){
        let storyboard = UIStoryboard(name: "Edit", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "EditVC") as? EditVC
        vc?.imageArray = imageArray
        self.navigationController?.pushViewController(vc!, animated: true)
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
    private func video2ImageGenerator(video_url url : URL, mediaType type : String){
        let convertedFps = 5
        
        showActivityIndicator()
        
        //https://stackoverflow.com/questions/42665271/swift-get-all-frames-from-video
        let videoURL : URL = url
        var generator : AVAssetImageGenerator!
        
        let asset : AVAsset = AVAsset(url: videoURL)
        let duration: Float64 = CMTimeGetSeconds(asset.duration)
        generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceAfter = CMTimeMake(value: 1, timescale: Int32(convertedFps))
        generator.requestedTimeToleranceBefore = CMTimeMake(value: 1, timescale: Int32(convertedFps))
        
        let tracks = asset.tracks(withMediaType: .video)
        let fps = ceil((tracks.first?.nominalFrameRate)!)
        let totalFrameNum = Int(Double(fps) * duration)
        
        print("duration: \(duration)")
        print("total frame: \(totalFrameNum)")
        print("fps: \(fps)")
        
        var index = 0
        
        while(Int32(index) < Int32(duration * Double(convertedFps))){
            let time:CMTime = CMTimeMake(value: Int64(index), timescale: Int32(convertedFps))
            print("time: \(time)")
            let image:CGImage
            do {
                try image = generator.copyCGImage(at: time, actualTime: nil)
            }catch {
                print("pass")
                return
            }
            imageArray.append(UIImage(cgImage: image))
            index = index + 1
        }
        print("image num: \(imageArray.count)")
        //동성님 방법인데 fps 에 관련해서 잘 모르겠어서 일단 위 코드 작성
//        let loadedVideo = Video2Image(video_url: url)
//        print("fps : \(loadedVideo.fps)")
//        print("total frame : \(loadedVideo.total_frame_num)")
//        print("running time: \(loadedVideo.running_time)")
//
//        for frame in 0..<loadedVideo.total_frame_num {
//            self.imageArray.append(loadedVideo.getSingleFrame(frame: frame)!)
//        }
        print("image frame count : \(self.imageArray.count)")
        hideActivityIndicator()
        goProjectVC()
    }
}
extension MainVC : UINavigationControllerDelegate {
    
}
extension MainVC : UIImagePickerControllerDelegate {
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
                let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL
            else { return }
            
            // 2
            dismiss(animated: true) { [self] in
                //3
                print("media type : \(mediaType)")
                print("url: \(url)")
                video2ImageGenerator(video_url: url, mediaType: mediaType)
            }
            
        default:
            break
        }
    }
}
extension MainVC : UICollectionViewDelegate, UICollectionViewDataSource{
    //Number of collectionView Item
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return projectArray.count
    }
    //Cell init
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProjectCollectionCell", for: indexPath) as? ProjectCollectionCell {
            if indexPath == [0,0]{
                cell.lbName.text = "새 프로젝트 시작"
                cell.btnInfo.isHidden = true
            }
            return cell
        }
        return UICollectionViewCell()
    }
    //clicklistener
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath == [0,0] {
            //select video and convert to image
            startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
        }else{
            if let cell = collectionView.cellForItem(at: indexPath) as? ProjectCollectionCell {
                goProjectVC()
            }
        }
        
    }
}
extension MainVC : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let rowItemCount : CGFloat = 5
        let spaceBetweenCell : CGFloat = 5
        let spacing : CGFloat = 5
        let totalSpacing = (2 * spacing) + ((rowItemCount - 1) * spaceBetweenCell)
        if let collection = self.collectionView {
            let width = (collection.bounds.width - totalSpacing)/rowItemCount - 60
            return CGSize(width: width, height: width+57)
        }else{
            return CGSize(width: 100, height: 100)
        }
    }
}
