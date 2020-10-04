//
//  ViewController.swift
//  AVFoundationPractice
//
//  Created by TaeHyeong Kim on 2020/08/30.
//  Copyright © 2020 TaeHyeong Kim. All rights reserved.
//

import UIKit
import AVKit
import MobileCoreServices
import MediaPlayer
import Photos


class ViewController: UIViewController {
    var firstAsset: AVAsset?
    var secondAsset: AVAsset?
    var audioAsset: AVAsset?
    var loadingAssetOne = false
    var mergingVideo = false
    
    @IBOutlet weak var activityMonitor: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func actionSelectAndPlay(_ sender: Any) {
        VideoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
        mergingVideo = false
    }
    @IBAction func actionRecordAndSave(_ sender: Any) {
        VideoHelper.startMediaBrowser(delegate: self, sourceType: .camera)
    }
    @IBAction func actionMerge(_ sender: Any) {
        merge()
    }
    
    @IBAction func actionLoadVid1(_ sender: Any) {
        loadingAssetOne = true
        mergingVideo = true
        VideoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
        
    }
    @IBAction func actionLoadVid2(_ sender: Any) {
        loadingAssetOne = false
        mergingVideo = true
        VideoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
        
    }
    @IBAction func actionLoadMusic(_ sender: Any) {
        let mediaPickerController = MPMediaPickerController(mediaTypes: .any)
        mediaPickerController.delegate = self
        mediaPickerController.prompt = "Select Audio"
        present(mediaPickerController, animated: true, completion: nil)
    }
    
    
    @IBAction func actionPresentBirthdayVC(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "MakeBirthdayCardVC") as? MakeBirthdayCardVC
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @objc func video(
        _ videoPath: String,
        didFinishSavingWithError error: Error?,
        contextInfo info: AnyObject
    ) {
        let title = (error == nil) ? "Success" : "Error"
        let message = (error == nil) ? "Video was saved" : "Video failed to save"
        
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(
            title: "OK",
            style: UIAlertAction.Style.cancel,
            handler: nil))
        present(alert, animated: true, completion: nil)
    }
    func exportDidFinish(_ session: AVAssetExportSession) {
        // 1
        activityMonitor.stopAnimating()
        firstAsset = nil
        secondAsset = nil
        audioAsset = nil
        
        // 2
        guard
            session.status == AVAssetExportSession.Status.completed,
            let outputURL = session.outputURL
            else { return }
        
        // 3
        let saveVideoToPhotos = {
            // 4
            let changes: () -> Void = {
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL)
            }
            PHPhotoLibrary.shared().performChanges(changes) { saved, error in
                DispatchQueue.main.async {
                    let success = saved && (error == nil)
                    let title = success ? "Success" : "Error"
                    let message = success ? "Video saved" : "Failed to save video"
                    
                    let alert = UIAlertController(
                        title: title,
                        message: message,
                        preferredStyle: .alert)
                    alert.addAction(UIAlertAction(
                        title: "OK",
                        style: UIAlertAction.Style.cancel,
                        handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
        // 5
        if PHPhotoLibrary.authorizationStatus() != .authorized {
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    saveVideoToPhotos()
                }
            }
        } else {
            saveVideoToPhotos()
        }
    }
    func merge(){
        guard
            let firstAsset = firstAsset,
            let secondAsset = secondAsset
            else { return }
        
        activityMonitor.startAnimating()
        
        // 1
        let mixComposition = AVMutableComposition()
        
        // 2
        guard
            let firstTrack = mixComposition.addMutableTrack(
                withMediaType: .video,
                preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
            else { return }
        
        // 3
        do {
            try firstTrack.insertTimeRange(
                CMTimeRangeMake(start: .zero, duration: firstAsset.duration),
                of: firstAsset.tracks(withMediaType: .video)[0],
                at: .zero)
        } catch {
            print("Failed to load first track")
            return
        }
        
        // 4
        guard
            let secondTrack = mixComposition.addMutableTrack(
                withMediaType: .video,
                preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
            else { return }
        
        do {
            try secondTrack.insertTimeRange(
                CMTimeRangeMake(start: .zero, duration: secondAsset.duration),
                of: secondAsset.tracks(withMediaType: .video)[0],
                at: firstAsset.duration)
        } catch {
            print("Failed to load second track")
            return
        }
        
        // 5
        // 6
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(
            start: .zero,
            duration: CMTimeAdd(firstAsset.duration, secondAsset.duration))
        
        // 7
        
        let firstInstruction = VideoHelper.videoCompositionInstruction(firstTrack, asset: firstAsset)
        firstInstruction.setOpacity(0.0, at: firstAsset.duration)
        let secondInstruction = VideoHelper.videoCompositionInstruction(secondTrack, asset: secondAsset)
        // 8
        mainInstruction.layerInstructions = [firstInstruction, secondInstruction]
        let mainComposition = AVMutableVideoComposition()
        mainComposition.instructions = [mainInstruction]
        mainComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        mainComposition.renderSize = CGSize(
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.height)
        
        // 9
        // 10
        if let loadedAudioAsset = audioAsset {
            let audioTrack = mixComposition.addMutableTrack(
                withMediaType: .audio,
                preferredTrackID: 0)
            do {
                try audioTrack?.insertTimeRange(
                    CMTimeRangeMake(
                        start: .zero,
                        duration: CMTimeAdd(
                            firstAsset.duration,
                            secondAsset.duration)),
                    of: loadedAudioAsset.tracks(withMediaType: .audio)[0],
                    at: .zero)
            } catch {
                print("Failed to load Audio track")
            }
        }
        
        // 11
        guard
            let documentDirectory = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask).first
            else { return }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let date = dateFormatter.string(from: Date())
        let url = documentDirectory.appendingPathComponent("mergeVideo-\(date).mov")
        
        // 12
        guard let exporter = AVAssetExportSession(
            asset: mixComposition,
            presetName: AVAssetExportPresetHighestQuality)
            else { return }
        exporter.outputURL = url
        exporter.outputFileType = AVFileType.mov
        exporter.shouldOptimizeForNetworkUse = true
        exporter.videoComposition = mainComposition
        
        // 13
        exporter.exportAsynchronously {
            DispatchQueue.main.async {
                self.exportDidFinish(exporter)
            }
        }
    }
}
extension ViewController : UIImagePickerControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        switch picker.sourceType {
        case .savedPhotosAlbum:
            if mergingVideo {
                dismiss(animated: true, completion: nil)
                
                guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
                    mediaType == (kUTTypeMovie as String),
                    let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL
                    else { return }
                
                let avAsset = AVAsset(url: url)
                var message = ""
                if loadingAssetOne {
                    message = "Video one loaded"
                    firstAsset = avAsset
                } else {
                    message = "Video two loaded"
                    secondAsset = avAsset
                }
                let alert = UIAlertController(
                    title: "Asset Loaded",
                    message: message,
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction(
                    title: "OK",
                    style: UIAlertAction.Style.cancel,
                    handler: nil))
                present(alert, animated: true, completion: nil)
            }else{
                // 1
                guard
                    let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
                    mediaType == (kUTTypeMovie as String),
                    let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL
                    else { return }
                
                // 2
                dismiss(animated: true) {
                    //3
                    let player = AVPlayer(url: url)
                    let vcPlayer = AVPlayerViewController()
                    vcPlayer.player = player
                    self.present(vcPlayer, animated: true, completion: nil)
                }
            }
            
        case .camera:
            dismiss(animated: true, completion: nil)
            
            guard
                let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
                mediaType == (kUTTypeMovie as String),
                // 1
                let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL,
                // 2
                UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path)
                else { return }
            
            // 3
            UISaveVideoAtPathToSavedPhotosAlbum(
                url.path,
                self,
                #selector(video(_:didFinishSavingWithError:contextInfo:)),
                nil)
        default:
            break
        }
    }
}
extension ViewController : UINavigationControllerDelegate {
    
}
extension ViewController: MPMediaPickerControllerDelegate {
    func mediaPicker(
        _ mediaPicker: MPMediaPickerController,
        didPickMediaItems mediaItemCollection: MPMediaItemCollection
    ) {
        // 1
        dismiss(animated: true) {
            // 2
            let selectedSongs = mediaItemCollection.items
            guard let song = selectedSongs.first else { return }
            
            // 3
            let title: String
            let message: String
            if let url = song.value(forProperty: MPMediaItemPropertyAssetURL) as? URL {
                self.audioAsset = AVAsset(url: url)
                title = "Asset Loaded"
                message = "Audio Loaded"
            } else {
                self.audioAsset = nil
                title = "Asset Not Available"
                message = "Audio Not Loaded"
            }
            
            // 4
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        // 5
        dismiss(animated: true, completion: nil)
    }
    
}
