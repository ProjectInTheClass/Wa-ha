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
import CoreData


protocol collectionViewDidScrollDelegate : EditVC{
    func didScrolled(to position: CGFloat)
}


class EditVC: UIViewController,UIGestureRecognizerDelegate {
    
    // coreData
    var context: NSManagedObjectContext?
    var item: Project?
    
    let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
    var initialCenter = CGPoint()
    var changedScale = CGFloat()
    var changedAngle = CGFloat()
    
    //pencilKt
    @IBOutlet weak var canvasView: PKCanvasView!
    let canvasWidth: CGFloat = 768
    let canvasOverscrollHeight: CGFloat = 500
    
    @IBOutlet weak var btnPlay_0: UIButton!
    @IBOutlet weak var btnPlay_1: UIButton!
    
    //View
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var videoFrameView: UIImageView!
    @IBOutlet weak var toolBar: UIView!
    @IBOutlet weak var toolBarBackView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet var playerView: UIView!
    @IBOutlet weak var playerImageView: UIImageView!
    @IBOutlet weak var topBar: UIView!
    
    var videoFrameArrayForTmpPlayingRemoveAfterPlay : [UIImage] = []
    var videoThumbnailArray : [UIImage] = []
    var canvasArray: [PKDrawing] = []
    var canvasThumbnailArray : [UIImage] = []
    var selectedIndex : Int = 0
    var projName : String = ""
    var isPencilUsing : Bool = false
    var videourl : URL?
    var outputURL : URL?
    var convertedFPS : Int?
    
    var cellInitialize1 : Bool = false
    var cellInitialize2 : Bool = false
    
    var selectedPlayOption : Int = 0
    var videoIsPlaying = false
  
    var videoSize : CGSize?
    
    var videoAlpha : CGFloat = 1.0
    var canvasAlpha : CGFloat = 1.0
        
    let activityIndicator = UIActivityIndicatorView(style:.large)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        lbTitle.text = projName
        setupProject()
        loadProject()
        setupTableView()
        setupCanvasView()
        print("tableView image count : \(videoThumbnailArray.count)")
        setupGesture()
        setupPlaytmp()
        initialCenter = self.containerView.center
        setupPlayView()
        self.activityIndicator.center = self.view.center
        self.view.addSubview(self.activityIndicator)
    }
    
    private func loadProject(){
        do {
            let items : [Project] = try context!.fetch(Project.fetchRequest())

            if(items.count > 0){
                for i in 0...items.count-1{
                    if(items[i].projectName! == self.projName){
                        item = items[i]
                        break
                    }
                }
            }
        } catch {

        }

        if(item!.drawingData != nil){
            canvasArray = item!.drawingData!
        }
    }
    
    func saveDrawingsToCoreData() {
        let drawingArray: [PKDrawing] = canvasArray
        
        item!.drawingData = drawingArray
        do{
        try self.context!.save()
        } catch {

        }
    }
    
    private func setupProject(){
        for _ in 0..<videoThumbnailArray.count {
            canvasArray.append(PKDrawing())
        }
        print("")
        let fileName = "\(self.projName)/original_\(0)"
        self.videoFrameView.image = ImageFileManager.shared.getSavedImage(named: fileName)
    }
    private func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self

        let cornerRadidus : CGFloat = 20
        let opacity : Float = 1.0
        toolBar.layer.cornerRadius = 30
        tableView.layer.cornerRadius = cornerRadidus
        toolBar.layer.opacity = 1.0
        tableView.layer.opacity = opacity
        
        //toolBar, topBar에 그림자
        toolBar.clipsToBounds = false
        toolBar.layer.shadowColor = UIColor.black.cgColor
        toolBar.layer.shadowOpacity = 0.3
        toolBar.layer.shadowOffset = CGSize.zero
        toolBar.layer.shadowRadius = 30
        toolBar.layer.shadowPath = UIBezierPath(roundedRect: toolBar.bounds, cornerRadius: 10).cgPath
        
        let toolBarShadow = UIImageView(frame: toolBar.bounds)
        toolBarShadow.clipsToBounds = true
        toolBarShadow.layer.cornerRadius = 30
        
        toolBar.addSubview(toolBarShadow)
        
        topBar.layer.shadowColor = UIColor.black.cgColor
        topBar.layer.shadowOpacity = 0.1
        topBar.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        topBar.layer.shadowRadius = 0        
        
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
    private func setupPlayView(){
        playerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(playerView)
        playerView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        playerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        playerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        playerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        playerView.isHidden = true
        playerView.backgroundColor = UIColor.black.withAlphaComponent(0.8)

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
    private func setupPlaytmp(){
        // initialize play tmp
        btnPlay_0.setImage(UIImage(named: "replay_click"), for: .normal)
        btnPlay_1.setImage(UIImage(named: "pingpong"), for: .normal)
        selectedPlayOption = 1
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
            let transform = view.transform.inverted()
            var currAngle = atan(Double(transform.c/transform.a))/Double.pi*180.0
            print(currAngle)
            for i in -1...1{
                if abs(currAngle - Double(i) * 90.0) < 2{
                    recognizer.rotation = CGFloat((Double(i) * 90.0 - currAngle) / 180.0 * Double.pi)
                    view.transform = view.transform.rotated(by: recognizer.rotation)
                    recognizer.rotation = 0
                    break
                }
            }
        }
    }
    
    //MARK:- UIGestureRecognizerDelegate Methods
    func gestureRecognizer(_: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    @IBAction func actionBack(_ sender: Any) {
        if(undoManager != nil){
            undoManager!.removeAllActions()
        }
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func actionExport(_ sender: Any) {
        //        saveDrawingToCameraRoll()
        writeSaveFileName()
    }
    @IBAction func actionRestoreScreen(_ sender: Any) {
        restoreScreen()
    }
    
    
    
    // MARK: 비디오 재생 관련 메소드
    @IBAction func actionCloseVideoPlayView(_ sender: Any) {
        playerView.isHidden = true
        videoIsPlaying = false
        videoPlayHelper()

    }
    @IBAction func actionPlay(_ sender: Any) {
        videoIsPlaying.toggle()
        videoPlayHelper()
    }

    @IBAction func actionPlayoptionMultiple(_ sender: Any) {
        btnPlay_0.setImage(UIImage(named: "replay"), for: .normal)
        btnPlay_1.setImage(UIImage(named: "pingpong_click"), for: .normal)
        selectedPlayOption = 0
        videoIsPlaying = false
        videoPlayHelper()
    }
    @IBAction func actionPlayoptionLoop(_ sender: Any) {
        btnPlay_0.setImage(UIImage(named: "replay_click"), for: .normal)
        btnPlay_1.setImage(UIImage(named: "pingpong"), for: .normal)
        selectedPlayOption = 1
        videoIsPlaying = false
        videoPlayHelper()
    }
    
    func videoPlayHelper(){
        if videoIsPlaying {
            //play video
            playVideoWithOptions(selectedPlayOption)
        }else{
            //stop video
            playerView.isHidden = true
            playerImageView.stopAnimating()
            playerImageView.animationImages = nil
        }
    }
    func playVideoWithOptions(_ options: Int){
        var source : [UIImage] = []
        let thumbnailSize = CGSize(width: 720.0, height: 480.0)
        let size = thumbnailSize
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
       
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        
        DispatchQueue.background {
            for index in 0..<self.videoThumbnailArray.count {
                let fileName = "\(self.projName)/original_\(index)"
                var image = ImageFileManager.shared.getSavedImage(named: fileName)
                
                UIGraphicsBeginImageContextWithOptions(thumbnailSize, false, 1.0)
                let tmpImg = image!
                tmpImg.draw(in: rect)
                image = nil
                let thumbnailImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                //add two image
                
                var bottomImage = thumbnailImage
                let topImage = self.canvasThumbnailArray[index]
                
                UIGraphicsBeginImageContext(size)
                bottomImage!.draw(in: rect)
                topImage.draw(in: rect, blendMode: .normal, alpha: 1)
                let newImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
                source.append(newImage)
                
            }
            
            if options == 0 {
                let reversed = source.reversed()
                for item in reversed {
                    source.append(item)
                }
            }
            DispatchQueue.main.async {
                self.playerView.isHidden = false
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.view.isUserInteractionEnabled = true
                if options == 1 {
                    self.playerImageView.animationRepeatCount = .max
                    self.playerImageView.animationImages = source
                    self.playerImageView.startAnimating()
                }else{
                    self.playerImageView.animationRepeatCount = .max
                    self.playerImageView.animationImages = source
                    self.playerImageView.startAnimating()
                }
            }
        }
        
        
        
    }
    
    
    
    

    
    //hide home indicator for better performance
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    private func restoreScreen(){
        containerView.transform = containerView.transform.inverted()
        containerView.center = initialCenter
        containerView.transform = CGAffineTransform(rotationAngle: changedAngle * CGFloat(Double.pi)/180)
//        containerView.transform = containerView.transform.scaledBy(x: -changedScale, y: -changedScale)
        
    }

    private func writeSaveFileName(){
        // alert view for
        let alert = UIAlertController(title: "Save Video As", message: "", preferredStyle: .alert)
        
        alert.addTextField{(myTextField) in
            myTextField.placeholder = "e.g. Wa-ha_project"
        }
        
        var fileName : String?
        var errorOccurred : Bool = false
        
        let errorAlert = UIAlertController(title: "", message: "", preferredStyle: .alert)

        let ok = UIAlertAction(title:"OK", style: .default){(ok) in
            if ((alert.textFields?[0].text)! == ""){
                errorOccurred = true
                errorAlert.title = "please write video name"
            }
            
            if ((alert.textFields?[0].text)! != ""){
                let legalText : String? = "^[a-zA-Z0-9-_//s]{0,15}$"
                do{
                    let regex = try NSRegularExpression(pattern: legalText!, options: .caseInsensitive)
                    for letter in (alert.textFields?[0].text)!{
                        let numberOfMatches = regex.numberOfMatches(in: String(letter), options: NSRegularExpression.MatchingOptions.init(), range: NSMakeRange(0, String(letter).count))
                        if(numberOfMatches == 0){
                            errorOccurred = true
                            errorAlert.title = "numbers, english letters, '-' and '_' are only allowed for video name"
                        }
                    }
                }catch{
                    print("error: \(error)")
                }
                if (alert.textFields?[0].text)!.count > 15{
                    errorOccurred = true
                    errorAlert.title = "maximum length of video name is 15"
                }
            }
            
            if(errorOccurred){
                let errorcancel = UIAlertAction(title: "cancel", style: .destructive)
                errorAlert.addAction(errorcancel)
                self.present(errorAlert, animated: true, completion: nil)
            }else{
                fileName = (alert.textFields?[0].text)!
                self.activityIndicator.startAnimating()
                self.activityIndicator.isHidden = false
                self.view.isUserInteractionEnabled = false

                DispatchQueue.background {
                    self.convertImages2Video(fileName: fileName!)
                }
            }
        }
        
        let cancel = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func convertImages2Video(fileName: String){
        print("start save video")
        print(videourl!.absoluteString)
        var tmpurl = videourl
        tmpurl!.deleteLastPathComponent()
        let fileURL = tmpurl!.path + "/\(fileName).MOV"
        outputURL = NSURL.fileURL(withPath: fileURL)
        print(outputURL!.absoluteString)
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
                    
                    UIGraphicsBeginImageContext(self.videoSize!)
                    let originalImage = ImageFileManager.shared.getSavedImage(named: "\(self.projName)/original_\(i)")
                    backgroundImage!.draw(in: areaSize, blendMode: .normal, alpha: 1)
                    originalImage!.draw(in: areaSize, blendMode: .normal, alpha: self.videoAlpha)
                    image.draw(in: areaSize, blendMode: .normal, alpha: self.canvasAlpha)
                    
                    newImage = UIGraphicsGetImageFromCurrentImageContext()!
                    UIGraphicsEndImageContext()
                    
                
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
                    UISaveVideoAtPathToSavedPhotosAlbum(self.outputURL!.relativePath, self, #selector(self.videoSaved(_:didFinishSavingWithError:contextInfo:)), nil)
                }
            })
        }
}
    
    @objc func videoSaved(_ videoPath: NSString, didFinishSavingWithError error:NSError?, contextInfo: UnsafeRawPointer){
        if let error = error {
                // we got back an error!
                let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
            } else {
                activityIndicator.isHidden = true
                activityIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
                
                let ac = UIAlertController(title: "Saved!", message: "Your animation has been saved to your photos.", preferredStyle: .alert)
                
                let ok = UIAlertAction(title: "OK", style: .default){(ok) in
                    self.navigationController?.popViewController(animated: true)
                }
                ac.addAction(ok)
                present(ac, animated: true)
            }
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
            self.canvasThumbnailArray[index] = image
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
        
        for index in 0..<videoThumbnailArray.count {
            
            let bottomImage = videoThumbnailArray[index]
            let topImage = videoThumbnailArray[index]
                        
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
        return 50
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            // for drawing layer thumbnail
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ImageFrameListTableViewCell", for: indexPath) as? ImageFrameListTableViewCell {
                cell.selectionStyle = .none
                if(!cellInitialize1){
                    cell.imageArray = canvasThumbnailArray
                    cellInitialize1 = true
                }else{
                    cell.imageArray[selectedIndex] = canvasThumbnailArray[selectedIndex]
                }
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
                if(!cellInitialize2){
                    cell.imageArray = videoThumbnailArray
                    cellInitialize2 = true
                }
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
        saveDrawingsToCoreData()
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
//            CGFloat(round(min(max(floor(Double(position)/70.0), 0),Double(canvasThumbnailArray.count-1))) * 70.0)
        }
    }
    func didDeceleratingEnded(to position: CGFloat) {
        for cell in tableView.visibleCells as! [ImageFrameListTableViewCell] {
            (cell.collectionview as UIScrollView).contentOffset.x = CGFloat(round(min(max(floor(Double(position)/70.0), 0),Double(canvasThumbnailArray.count-1))) * 70.0)
        }
    }
    func didFrameSelected(index: Int) {
        for cell in self.tableView.visibleCells as! [ImageFrameListTableViewCell] {
            (cell.collectionview as UIScrollView).contentOffset.x = CGFloat(Double(index) * 70.0)
        }
    }
    //select center
}
extension EditVC : frameSelectDelegate {
    func selectedIndex(index: Int) {
        print("selectedIndexDelegate \(index)")
        if(self.undoManager != nil){
            self.undoManager!.removeAllActions()
        }
        DispatchQueue.main.async {
            let fileName = "\(self.projName)/original_\(index)"
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
            videoAlpha = CGFloat(value)
        case 0:
            canvasView.alpha = CGFloat(value)
            canvasAlpha = CGFloat(value)
        default:
            break
        }
    }
}

extension UIView {
    
    func addShadow(shadowColor: UIColor, offSet: CGSize, opacity: Float, shadowRadius: CGFloat, cornerRadius: CGFloat, corners: UIRectCorner, fillColor: UIColor = .white) {
        
        let shadowLayer = CAShapeLayer()
        let size = CGSize(width: cornerRadius, height: cornerRadius)
        let cgPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: size).cgPath //1
        shadowLayer.path = cgPath //2
        shadowLayer.fillColor = fillColor.cgColor //3
        shadowLayer.shadowColor = shadowColor.cgColor //4
        shadowLayer.shadowPath = cgPath
        shadowLayer.shadowOffset = offSet //5
        shadowLayer.shadowOpacity = opacity
        shadowLayer.shadowRadius = shadowRadius
        self.layer.addSublayer(shadowLayer)
    }
}




//drawing reference
//https://www.youtube.com/watch?v=3d1HNBpqvuM&t=1007s
//replaykit
//https://codershigh.dscloud.biz/techblogs/tb_002_replykit/tb002_script.html

