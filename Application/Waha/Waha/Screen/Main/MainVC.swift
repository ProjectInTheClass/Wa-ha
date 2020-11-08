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
    var selectedProjName : String = "project"
    var convertedFPS : Int? = 15
    let activityIndicator = UIActivityIndicatorView(style:.large)
    var videourl : URL?
    var videoSize : CGSize?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupActivityIndicator()
        print(NSHomeDirectory())
    }
    private func setupActivityIndicator(){
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
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
        vc?.projName = selectedProjName
        vc?.videourl = videourl
        vc?.convertedFPS = convertedFPS
        vc?.videoSize = videoSize
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

        imageArray.removeAll()
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        
        DispatchQueue.background {
            
            //https://stackoverflow.com/questions/42665271/swift-get-all-frames-from-video
            let videoURL : URL = url
            var generator : AVAssetImageGenerator!
            let asset : AVAsset = AVAsset(url: videoURL)
            let duration: Float64 = CMTimeGetSeconds(asset.duration)
            generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            generator.requestedTimeToleranceAfter = CMTimeMake(value: 1, timescale: Int32(self.convertedFPS!))
            generator.requestedTimeToleranceBefore = CMTimeMake(value: 1, timescale: Int32(self.convertedFPS!))
            let tracks = asset.tracks(withMediaType: .video)
            let fps = ceil((tracks.first?.nominalFrameRate)!)
            let totalFrameNum = Int(Double(fps) * duration)
            
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentsDirectory = paths[0]
            let docURL = URL(string: documentsDirectory)!
            let dataPath = docURL.appendingPathComponent("\(self.selectedProjName)")
            if !FileManager.default.fileExists(atPath: dataPath.absoluteString) {
                do {
                    try FileManager.default.createDirectory(atPath: dataPath.absoluteString, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print(error.localizedDescription);
                }
            }
            
            print("duration: \(duration)")
            print("total frame: \(totalFrameNum)")
            print("fps: \(fps)")
            var index = 0
            
            while(Int32(index) < Int32(duration * Double(self.convertedFPS!))){
                let time:CMTime = CMTimeMake(value: Int64(index), timescale: Int32(self.convertedFPS!))
                //            print("time: \(time)")
                var image: CGImage?
                do {
                    try image = generator.copyCGImage(at: time, actualTime: nil)
                }catch {
                    print("pass")
                    return
                }
                let pngImage: UIImage = UIImage(cgImage: image!)
                if(self.videoSize == nil) {self.videoSize = pngImage.size}
                let imageName: String = "\(self.selectedProjName)/original_\(index).png"
                ImageFileManager.shared.saveImage(image: pngImage, name: imageName){
                    [weak self] onSuccess in
                    //                print("saveImage onSuccess: \(onSuccess), \(imageName)")
                }
                
                let thumbnailSize = CGSize(width: 160.0, height: 90.0)
                let rect = CGRect(x: 0, y: 0, width: thumbnailSize.width, height: thumbnailSize.height)
                UIGraphicsBeginImageContextWithOptions(thumbnailSize, false, 1.0)
                let tmpImg = UIImage(cgImage: image!)
                tmpImg.draw(in: rect)
                image = nil
                let thumbnailImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                self.imageArray.append(thumbnailImage!)
                index = index + 1
            }
            print("image frame count : \(self.imageArray.count)")
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.view.isUserInteractionEnabled = true
                self.goProjectVC()

            }
        }
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
                videourl = url
                // alert view for initialize project name
                let alert = UIAlertController(title: "Write Project Name", message: "", preferredStyle: .alert)
                
                alert.addTextField{(myTextField) in
                    myTextField.placeholder = "e.g. Wa-ha_project"
                }
                
                let ok = UIAlertAction(title:"OK", style: .default){(ok) in
                    if ((alert.textFields?[0].text)! != ""){
                        self.selectedProjName = (alert.textFields?[0].text)!
                    }else{
                        self.selectedProjName = "Wa-ha_project_\(self.projectArray.count)"
                    }
                    print((alert.textFields?[0].text)!)
                    print(self.selectedProjName)
                    video2ImageGenerator(video_url: url, mediaType: mediaType)
                }
                
                let cancel = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
                
                alert.addAction(ok)
                alert.addAction(cancel)
                
                self.present(alert, animated: true, completion: nil)
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

extension DispatchQueue {

    static func background(_ task: @escaping () -> ()) {
        DispatchQueue.global(qos: .background).async {
            task()
        }
    }

    static func main(_ task: @escaping () -> ()) {
        DispatchQueue.main.async {
            task()
        }
    }
}
