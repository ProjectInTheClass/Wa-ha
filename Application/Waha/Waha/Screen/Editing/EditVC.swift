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
import MediaPlayer
import PencilKit
import PhotosUI


protocol collectionViewDidScrollDelegate : EditVC{
    func didScrolled(to position: CGFloat)
}


class EditVC: UIViewController,UIGestureRecognizerDelegate {
    
    let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
    var initialCenter = CGPoint()
    var changedScale = CGFloat()
    var changedAngle = CGFloat()
    
    //pencilKt
    @IBOutlet weak var canvasView: PKCanvasView!
    let canvasWidth: CGFloat = 768
    let canvasOverscrollHeight: CGFloat = 500
    
    
    //View
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var videoFrameView: UIImageView!
    @IBOutlet weak var toolBar: UIView!
    @IBOutlet weak var containerView: UIView!
    
    var isNewVideo : Bool?
    var imageArray : [UIImage] = []
    var canvasArray: [PKDrawing] = []
    var thumbnailArray : [UIImage] = []
    var selectedIndex : Int = 0
    var projName : String = ""
    var isPencilUsing : Bool = false
    var videourl : URL?
    var convertedFPS : Int?
    var videoSize : CGSize?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        lbTitle.text = projName
        setupProject()
        setupCanvasView()
        print("tableView image count : \(imageArray.count)")
        setupGesture()
        
        
        initialCenter = self.containerView.center
        
    }
    private func setupProject(){
        for _ in 0..<imageArray.count {
            canvasArray.append(PKDrawing())
            thumbnailArray.append(UIImage())
        }
        let fileName = "\(self.projName)_original_\(0)"
        self.videoFrameView.image = ImageFileManager.shared.getSavedImage(named: fileName)
        setupTableView()
    }
    private func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        
        let cornerRadidus : CGFloat = 20
        let opacity : Float = 1.0
        toolBar.layer.cornerRadius = cornerRadidus
        tableView.layer.cornerRadius = cornerRadidus
        toolBar.layer.opacity = opacity
        tableView.layer.opacity = opacity
    }
    private func setupCanvasView(){
        
        // TODO: canvas도 thumnail과 original image 분리
        canvasView.delegate = self
        canvasView.drawing = canvasArray[0]
        canvasView.isScrollEnabled = false
        canvasView.allowsFingerDrawing = false
        if let window = parent?.view.window,
           let toolPicker = PKToolPicker.shared(for: window) {
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            toolPicker.addObserver(canvasView)
            
            canvasView.becomeFirstResponder()
        }
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
    }
    private func setupGesture(){
        //        https://stackoverflow.com/questions/45402639/pinch-pan-and-rotate-text-simultaneously-like-snapchat-swift-3
        //https://developer.apple.com/documentation/uikit/touches_presses_and_gestures/leveraging_touch_input_for_drawing_apps
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        gestureRecognizer.delegate = self
        containerView.addGestureRecognizer(gestureRecognizer)
        containerView.isUserInteractionEnabled = true
        containerView.isMultipleTouchEnabled = true
        
        
        
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchRecognized(pinch:)))
        pinchGesture.delegate = self
        containerView.addGestureRecognizer(pinchGesture)
        
        let rotate = UIRotationGestureRecognizer.init(target: self, action: #selector(handleRotate(recognizer:)))
        rotate.delegate = self
        containerView.addGestureRecognizer(rotate)
    }
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        if isPencilUsing == false {
            
            if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
                
                let translation = gestureRecognizer.translation(in: self.view)
                // note: 'view' is optional and need to be unwrapped
                gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
                gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
            }
        }
        
        
    }
    @objc func pinchRecognized(pinch: UIPinchGestureRecognizer) {
        changedScale = pinch.scale
        if let view = pinch.view {
            view.transform = view.transform.scaledBy(x: pinch.scale, y: pinch.scale)
//            view.transform = view.transform.inverted()
            pinch.scale = 1
        }
    }
    @objc func handleRotate(recognizer : UIRotationGestureRecognizer) {
        changedAngle = recognizer.rotation
        if let view = recognizer.view {
            view.transform = view.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0
        }
    }
    
    //MARK:- UIGestureRecognizerDelegate Methods
    func gestureRecognizer(_: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func actionExport(_ sender: Any) {
        //        saveDrawingToCameraRoll()
        selectSaveMode()
    }
    
    @IBAction func actionRestoreScreen(_ sender: Any) {
        restoreScreen()
    }
    //hide home indicator for better performance
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    private func restoreScreen(){
        containerView.transform = containerView.transform.inverted()
        containerView.center = initialCenter
//        containerView.transform = containerView.transform.scaledBy(x: -changedScale, y: -changedScale)
        containerView.transform = CGAffineTransform(rotationAngle: changedAngle * CGFloat(Double.pi)/180)
            
    }
    private func selectSaveMode(){
        // alert view for select save mode
        let alert = UIAlertController(title: "Save Video With", message: "", preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "cancel", style: .destructive, handler: nil)
        
        let drawingOnly = UIAlertAction(title: "Drawing Only", style: .default){(drawingOnly) in
            self.writeSaveFileName(useOriginalImage: false)
        }
        
        let drawingOnImage = UIAlertAction(title: "Drawing + Original", style: .default){(drawingOnImage) in
            self.writeSaveFileName(useOriginalImage: true)
        }
        
        alert.addAction(drawingOnly)
        alert.addAction(drawingOnImage)
        alert.addAction(cancel)
        
        if UIDevice.current.userInterfaceIdiom == .pad { // if device is iPad
            if let popoverController = alert.popoverPresentationController {
                // set present position of action sheet
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
                self.present(alert, animated: true, completion: nil)
            }
        }else{
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    private func writeSaveFileName(useOriginalImage: Bool){
        // alert view for
        let alert = UIAlertController(title: "Save Video With", message: "", preferredStyle: .alert)
        
        alert.addTextField{(myTextField) in
            myTextField.placeholder = "e.g. Wa-ha_project"
        }
        
        var fileName : String?
        
        let ok = UIAlertAction(title:"OK", style: .default){(ok) in
            if ((alert.textFields?[0].text)! != ""){
                fileName = (alert.textFields?[0].text)!
            }else{
                fileName = "Wa-ha_project"
            }
            print((alert.textFields?[0].text)!)
            print(fileName!)
            self.convertImages2Video(useOriginalImage: useOriginalImage, fileName: fileName!)
        }
        
        let cancel = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    private func convertImages2Video(useOriginalImage: Bool, fileName: String){
        print("start save video")
        print(videourl!.absoluteString)
        videourl!.deleteLastPathComponent()
        let fileURL = videourl!.absoluteString + "\(fileName).MOV"
        let outputURL : URL? = URL(string: fileURL)
        var assetWriter : AVAssetWriter? = nil
        do{
            assetWriter = try AVAssetWriter(outputURL: outputURL!, fileType: AVFileType.mov)
        } catch let asseterror{
            print("Error: \(asseterror)")
        }
        
        // set output video properties
        let videoSettings: [String : Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoHeightKey: videoSize!.height,
            AVVideoWidthKey: videoSize!.width
        ]
        let assetWriterInput : AVAssetWriterInput? = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoSettings)
        
        if(assetWriter!.canAdd(assetWriterInput!)){
            assetWriter!.add(assetWriterInput!)
        }else{
            // show error message
        }
        
        let attributes: [String : Any] = [
            String(kCVPixelBufferPixelFormatTypeKey): kCVPixelFormatType_32BGRA,
            String(kCVPixelBufferWidthKey): videoSize!.width,
            String(kCVPixelBufferHeightKey): videoSize!.height,
            String(kCVPixelBufferCGImageCompatibilityKey): kCFBooleanTrue as Any,
            String(kCVPixelBufferCGBitmapContextCompatibilityKey): kCFBooleanTrue as Any
        ]
        
        let writerAdaptor : AVAssetWriterInputPixelBufferAdaptor? = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: assetWriterInput!, sourcePixelBufferAttributes: attributes)

        assetWriter!.startWriting()
        assetWriter!.startSession(atSourceTime: CMTime.zero)
        
        var backgroundImage : UIImage?
        
        UIGraphicsBeginImageContextWithOptions(videoSize!, true, 0.0)
        if let context = UIGraphicsGetCurrentContext(){
            context.setFillColor(UIColor.white.cgColor)
            context.fill(CGRect(origin: .zero, size: videoSize!))
            backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndPDFContext()
        
        let mediaInputQueue = DispatchQueue(label: "mediaInputQueue")
        assetWriterInput!.requestMediaDataWhenReady(on: mediaInputQueue){
            for i in 0...self.canvasArray.count - 1{
                if(assetWriterInput!.isReadyForMoreMediaData){
                    let areaSize = CGRect(x: 0, y: 0, width: self.videoSize!.width, height: self.videoSize!.height)

                    let image = self.canvasArray[i].image(from: areaSize, scale: 1.0)
                    
                    let newImage : UIImage
                    
                    if(useOriginalImage){
                        UIGraphicsBeginImageContext(self.videoSize!)
                        let originalImage = ImageFileManager.shared.getSavedImage(named: "\(self.projName)_original_\(i)")
                        originalImage!.draw(in: areaSize)
                        image.draw(in: areaSize, blendMode: .normal, alpha: 1)
                        newImage = UIGraphicsGetImageFromCurrentImageContext()!
                        UIGraphicsEndImageContext()
                    }else{
                        UIGraphicsBeginImageContext(self.videoSize!)
                        backgroundImage!.draw(in: areaSize)
                        image.draw(in: areaSize, blendMode: .normal, alpha: 1)
                        newImage = UIGraphicsGetImageFromCurrentImageContext()!
                        UIGraphicsEndImageContext()
                    }
                    
                    
                    let pixelBuffer = self.newPixelBufferFrom(cgImage: newImage.cgImage!)
                    
                    let time : CMTime
                    if(i == 0){
                        time = CMTime.zero
                    }else{
                        time = CMTimeMake(value: Int64(i), timescale: Int32(self.convertedFPS!))
                    }
                    
                    
                    writerAdaptor?.append(pixelBuffer!, withPresentationTime: time)
                }
            }
            assetWriterInput!.markAsFinished()
            assetWriter!.finishWriting(completionHandler: {
                Thread.sleep(forTimeInterval: 0.5)
                DispatchQueue.main.sync {
                    print("Completed?", assetWriter!.status == AVAssetWriter.Status.completed)
                    UISaveVideoAtPathToSavedPhotosAlbum(outputURL!.relativePath, self, nil, nil)
                }
            })
        }
        
        // TODO
//        UISaveVideoAtPathToSavedPhotosAlbum(self.videourl!.relativePath, self, nil, nil)
        print("output URL: \(outputURL!.absoluteString)")
        self.navigationController?.popViewController(animated: true)
    }
    
    private func newPixelBufferFrom(cgImage:CGImage) -> CVPixelBuffer?{
        let options:[String: Any] = [kCVPixelBufferCGImageCompatibilityKey as String: true, kCVPixelBufferCGBitmapContextCompatibilityKey as String: true]
        var pxbuffer:CVPixelBuffer?
        let frameWidth = Int(self.videoSize!.width) //CANVAS_SIZE
        let frameHeight = Int(self.videoSize!.height) //CANVAS_SIZE
        
        let status = CVPixelBufferCreate(kCFAllocatorDefault, frameWidth, frameHeight, kCVPixelFormatType_32ARGB, options as CFDictionary?, &pxbuffer)
        // TODO: throw exception in case of error, don't use assert
        assert(status == kCVReturnSuccess && pxbuffer != nil, "newPixelBuffer failed")

        CVPixelBufferLockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pxdata = CVPixelBufferGetBaseAddress(pxbuffer!)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pxdata, width: frameWidth, height: frameHeight, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pxbuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        // TODO: throw exception in case of error, don't use assert
        assert(context != nil, "context is nil")

        context!.concatenate(CGAffineTransform.identity)
        context!.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
        CVPixelBufferUnlockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: 0))
        return pxbuffer
    }
    private func saveDrawingToCameraRoll(){
        UIGraphicsBeginImageContextWithOptions(canvasView.bounds.size, false, UIScreen.main.scale)
        canvasView.drawHierarchy(in: canvasView.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if image != nil {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image!)
            }, completionHandler: {success, error in
                //deal with success
                self.alert(title: "앨범에 저장되었습니다.")
            })
        }
    }
    private func saveToCanvasArray(canvas : PKCanvasView){
        canvasArray[selectedIndex] = canvas.drawing
    }
    //for thumbnail
    private func drawingToImage(from canvas: PKCanvasView, index : Int) {
        DispatchQueue.main.async {
            let drawing = canvas.drawing
            let visibleRect = canvas.bounds
            let image = drawing.image(from: visibleRect, scale: UIScreen.main.scale)
            self.thumbnailArray[index] = image
            self.tableView.reloadData()
        }
    }
    
    //이미지 합치기
    private func combineLayersAndConvertVideo(){
        //add two image
        // TODO: - 나중에 image + image가 아니라 drawing + image로 해야함
        let size = CGSize(width: videoFrameView.frame.size.width, height: videoFrameView.frame.size.height)
        let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        var mergedImage : [UIImage] = []
        
        for index in 0..<imageArray.count {
            
            let bottomImage = imageArray[index]
            let topImage = imageArray[index]
            
            UIGraphicsBeginImageContext(size)
            bottomImage.draw(in: areaSize)
            topImage.draw(in: areaSize, blendMode: .normal, alpha: 1)
            let newImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            mergedImage.append(newImage)
        }
        
        
        
    }
    
    
}
extension EditVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            //for drawing layer thumbnail

            if let cell = tableView.dequeueReusableCell(withIdentifier: "ImageFrameListTableViewCell", for: indexPath) as? ImageFrameListTableViewCell {
                cell.selectionStyle = .none
                cell.imageArray = thumbnailArray
                cell.collectionview.reloadData()
                cell.delegate = self
                cell.scrollDelegate = self
                cell.selectedIndex = selectedIndex
                cell.index = indexPath.row
                cell.sliderDelegate = self
                return cell
            }
        }else{
            //for video frame thumbnail

            if let cell = tableView.dequeueReusableCell(withIdentifier: "ImageFrameListTableViewCell", for: indexPath) as? ImageFrameListTableViewCell {
                cell.selectionStyle = .none
                cell.imageArray = imageArray
                cell.collectionview.reloadData()
                cell.delegate = self
                cell.scrollDelegate = self
                cell.selectedIndex = selectedIndex
                cell.index = indexPath.row
                cell.sliderDelegate = self
                return cell
            }
        }
        return UITableViewCell()
    }
}
extension EditVC : PKCanvasViewDelegate, PKToolPickerObserver {
    func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
        //펜을 쓸때는 panning gesture disable
        isPencilUsing = true
    }
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        saveToCanvasArray(canvas: canvasView)
        //make thumbnail image at background
        DispatchQueue.global(qos: .background).async {
            //selectedIndex가 바뀔수 있어서 call된 시점의 selectedIndex를 넣어줌
            self.drawingToImage(from: canvasView, index: self.selectedIndex)
        }
    }
    func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
        isPencilUsing = false
    }
}
extension EditVC : collectionViewDidScrollDelegate {
    //sync scroll
    func didScrolled(to position: CGFloat) {
        //        print(position)
        for cell in tableView.visibleCells as! [ImageFrameListTableViewCell] {
            (cell.collectionview as UIScrollView).contentOffset.x = position
        }
    }
    //select center
}
extension EditVC : frameSelectDelegate {
    func selectedIndex(index: Int) {
        print("selectedIndexDelegate \(index)")
        DispatchQueue.main.async {
            let fileName = "\(self.projName)_original_\(index)"
            self.videoFrameView.image = ImageFileManager.shared.getSavedImage(named: fileName)
            //            self.tmpImageView.image = self.imageArray[index]
            self.canvasView.drawing = self.canvasArray[index]
        }
        selectedIndex = index
    }
}
extension EditVC : sliderDelegate {
    func sliderDidMoved(value: Float, layer: Int) {
        switch layer {
        case 1:
            videoFrameView.alpha = CGFloat(value)
        case 0:
            canvasView.alpha = CGFloat(value)
        default:
            break
        }
    }
}


//drawing reference
//https://www.youtube.com/watch?v=3d1HNBpqvuM&t=1007s
//replaykit
//https://codershigh.dscloud.biz/techblogs/tb_002_replykit/tb002_script.html

