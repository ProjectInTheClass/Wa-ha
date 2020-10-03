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


class EditVC: UIViewController {
    
    //pencilKt
    @IBOutlet weak var canvasView: PKCanvasView!
    let canvasWidth: CGFloat = 768
    let canvasOverscrollHight: CGFloat = 500
    
    
    //View
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var tmpImageView: UIImageView!
    
    var isNewVideo : Bool?
    var imageArray : [UIImage] = []
    var canvasArray: [PKDrawing] = []
    var thumbnailArray : [UIImage] = []
    var selectedIndex : Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupProject()
        setupCanvasView()
        print("tableView image count : \(imageArray.count)")
        
    }
    private func setupProject(){
        for _ in 0..<imageArray.count {
            canvasArray.append(PKDrawing())
            thumbnailArray.append(UIImage())
        }
        tmpImageView.image = imageArray[0]
        setupTableView()
    }
    private func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
    }
    private func setupCanvasView(){
        canvasView.delegate = self
        canvasView.drawing = canvasArray[0]
        canvasView.isScrollEnabled = false
        canvasView.allowsFingerDrawing = true
        if let window = parent?.view.window,
           let toolPicker = PKToolPicker.shared(for: window) {
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            toolPicker.addObserver(canvasView)
            
            canvasView.becomeFirstResponder()
        }
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
    }
   
    
    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func actionExport(_ sender: Any) {
        saveDrawingToCameraRoll()
    }
    
    //hide home indicator for better performance
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    //rotating view
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let canvasScale = canvasView.bounds.width/canvasWidth
        canvasView.minimumZoomScale = canvasScale
        canvasView.maximumZoomScale = canvasScale
        canvasView.zoomScale = canvasScale
        canvasView.contentOffset = CGPoint(x: 0, y: -canvasView.adjustedContentInset.top)
    }
    private func updateContentSizeForDrawing(){
        let drawing = canvasView.drawing
        let contentHeight: CGFloat
        if drawing.bounds.isNull {
            contentHeight = max(canvasView.bounds.height, (drawing.bounds.maxY + self.canvasOverscrollHight) * canvasView.zoomScale)
        }else {
            contentHeight = canvasView.bounds.height
        }
        canvasView.contentSize = CGSize(width: canvasWidth * canvasView.zoomScale, height: contentHeight)
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
        let size = CGSize(width: tmpImageView.frame.size.width, height: tmpImageView.frame.size.height)
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
            //for video frame thumbnail
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ImageFrameListTableViewCell", for: indexPath) as? ImageFrameListTableViewCell {
                cell.selectionStyle = .none
                cell.imageArray = imageArray
                cell.collectionview.reloadData()
                cell.delegate = self
                cell.scrollDelegate = self
                return cell
            }
        }else{
            //for drawing layer thumbnail
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ImageFrameListTableViewCell", for: indexPath) as? ImageFrameListTableViewCell {
                cell.selectionStyle = .none
                cell.imageArray = thumbnailArray
                cell.collectionview.reloadData()
                cell.delegate = self
                cell.scrollDelegate = self
                return cell
            }
        }
        return UITableViewCell()
    }
}
extension EditVC : PKCanvasViewDelegate, PKToolPickerObserver {
    //문제가 칠하지 않고 그냥 스크롤만 해도 호출되서 성능이 떨어짐
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
//        print("canvasViewDrawingDidChange called")
        saveToCanvasArray(canvas: canvasView)
        //make thumbnail image at background
        DispatchQueue.global(qos: .background).async {
            //selectedIndex가 바뀔수 있어서 call된 시점의 selectedIndex를 넣어줌
            self.drawingToImage(from: canvasView, index: self.selectedIndex)
        }
//        updateContentSizeForDrawing()
    }
    func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
        print("canvasViewDidEndUsingTool called")

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
            self.tmpImageView.image = self.imageArray[index]
            self.canvasView.drawing = self.canvasArray[index]
        }
        selectedIndex = index
    }
}


//drawing reference
//https://www.youtube.com/watch?v=3d1HNBpqvuM&t=1007s
//replaykit
//https://codershigh.dscloud.biz/techblogs/tb_002_replykit/tb002_script.html

