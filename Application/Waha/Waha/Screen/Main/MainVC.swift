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
import CoreData

class MainVC: UIViewController {
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var items: [Project]?
    var tempNewProject: TemporaryProject?
    var frameRatePickerView = UIPickerView()
    let frameRatePickerViewData = ["12", "15", "30"]
    let imagePicker: UIImagePickerController! = UIImagePickerController()
    var captureImage: UIImage!
    var videoURL: URL!
    var mediaType : NSString!
    

    @IBOutlet weak var createNewProjectView: UIView!
    @IBOutlet weak var createNewProjectLabel: UILabel!
    @IBOutlet weak var addVideoButton: UIButton!
    @IBOutlet weak var projectImageView: UIImageView!
    @IBOutlet weak var projectNameTextField: UITextField!
    @IBOutlet weak var frameRateTextField: UITextField!
    @IBOutlet weak var cancleCreateNewProjectButton: UIButton!
    @IBOutlet weak var NewProjectButton: UIButton!
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var createProjectView: UIView!
    
    var projectArray : [String] = ["프로젝트 추가","예시1","예시2"]
    var imageArray : [UIImage] = []
    var selectedProjName : String = "project"
    var convertedFPS : Int = 15
    let activityIndicator = UIActivityIndicatorView(style:.large)
    var videoSize : CGSize?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCreateProjectView()
        setupCollectionView()
        setupActivityIndicator()
        print(NSHomeDirectory())
    }

    private func setupCreateProjectView(){
        
        self.createProjectView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(createProjectView)
        self.createProjectView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.createProjectView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    
        createProjectView.isHidden = true
        frameRatePickerView.dataSource = self
        frameRatePickerView.delegate = self
        imagePicker.delegate = self
        frameRateTextField.isUserInteractionEnabled = false
    }
    
    @IBAction func choooseFrameRate(_ sender: Any){
        frameRatePickerView.isHidden = false
        frameRatePickerView.backgroundColor = UIColor.white
        frameRatePickerView.center = CGPoint.init(x: self.view.bounds.midX, y: self.view.bounds.maxY - frameRatePickerView.frame.height/2)
        frameRatePickerView.roundCorners(corners: .allCorners, radius: 20)
        projectNameTextField.isEnabled = false
        self.view.addSubview(frameRatePickerView)
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
//        layout.minimumLineSpacing = 5
//        layout.minimumInteritemSpacing = 5
        collectionView.collectionViewLayout = layout
        
        let projectCellNib = UINib(nibName: "ProjectCollectionCell", bundle: nil)
        self.collectionView.register(projectCellNib, forCellWithReuseIdentifier: "ProjectCollectionCell")
        
        // 코어 데이터에서 아이템 가져오기
        fetchProject()
        
    }
    

    
    private func fetchProject(){
        // 코어데이터에서 데이터 가져와서 콜렉션뷰에 보이기
        do {
            self.items = try context.fetch(Project.fetchRequest())
            
            ///?? 뭔가 백그라운드에서 실행되고 그런 개념인것같은데..
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        } catch {
            
        }
    }
    
    
    func myAlert(_ title: String, message: String) {
        
        let alert = UIAlertController(title: "Select Video", message: "message", preferredStyle: .actionSheet)
        
        let library =  UIAlertAction(title: "Photo Album", style: .default) { (action) in self.openLibrary()
        }
        
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.openCamera()
            }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(library)
        alert.addAction(camera)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func openLibrary(){
      imagePicker.sourceType = .photoLibrary
      present(imagePicker, animated: false, completion: nil)
    }

    func openCamera(){
      imagePicker.sourceType = .camera
      present(imagePicker, animated: false, completion: nil)
    }
    
    func extractFirstFrame() {
        let asset = AVAsset(url: videoURL)
        let generator = AVAssetImageGenerator.init(asset: asset)
        let cgImage = try! generator.copyCGImage(at: CMTime(seconds: 0, preferredTimescale: 1), actualTime: nil)
        captureImage = UIImage(cgImage: cgImage)
    }
    
    @IBAction func deleteModeButtonTapped(_ sender: Any) {
        collectionView.indexPathsForVisibleItems.forEach { (indexPath) in
            let cell = collectionView.cellForItem(at: indexPath) as! ProjectCollectionCell
            
            cell.isEditing = !isEditing
        }

    }
    
    @objc func deleteProjectButtonTapped(_ sender: UIButton) {
        let deleteAlert = UIAlertController(title: "Delete Project", message: "Deletion is permanent and can't be reversed", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
           
            let projectToRemove = self.items?[sender.tag]

            // Remove the project
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentsDirectory = paths[0]
            let docURL = URL(string: documentsDirectory)!
            let dataPath = docURL.appendingPathComponent("\(projectToRemove!.projectName!)")
            do {
                let fileManager = FileManager.default
                // Check if file exists
                if fileManager.fileExists(atPath: dataPath.relativeString) {
                    // Delete file
                    try fileManager.removeItem(atPath: dataPath.relativeString)
                } else {
                    print("File \(dataPath.relativeString) does not exist")
                }
                
                if fileManager.fileExists(atPath: projectToRemove!.videoURL!) {
                    // Delete file
                    try fileManager.removeItem(atPath: projectToRemove!.videoURL!)
                }else{
                    print("File \(projectToRemove!.videoURL!) does not exist")
                }
            } catch {
                print("An error took place: \(error)")
            }
                        
            self.context.delete(projectToRemove!)

            // Save the data
            do{
                try self.context.save()
            } catch {

            }

            // Re-fetch the data
            self.fetchProject()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        deleteAlert.addAction(cancelAction)
        deleteAlert.addAction(deleteAction)
        present(deleteAlert, animated: true, completion: nil)
    }
    
<<<<<<< Updated upstream
    override func viewDidAppear(_ animated: Bool) {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let docURL = URL(string: documentsDirectory)!
        
        for i in 0...items!.count-1{
            let projectName = items![i].projectName
            
            let dataPath = docURL.appendingPathComponent("\(projectName!)")
            do {
                let fileManager = FileManager.default
                // Check if file exists
                if !fileManager.fileExists(atPath: dataPath.relativeString) {
                    // Delete file
                    removeProjectAfterExport(projectName: projectName!)
                }
            } catch {
                print("An error took place: \(error)")
            }
        }
    }
    
    private func removeProjectAfterExport(projectName: String){
        var projectToRemove : Project?
        for i in 0...items!.count-1{
            if(projectName == items![i].projectName){
                projectToRemove = items![i]
                break
            }
        }
        self.context.delete(projectToRemove!)
        
        // Save the data
        do{
            try self.context.save()
        } catch{
            
        }
        
        // Re-fetch the data
        self.fetchProject()
=======
    @objc func loadProjectButtonTapped(_ sender: UIButton) {
        
>>>>>>> Stashed changes
    }
    
    @IBAction func actionCreateProject(_ sender: Any) {
        createProjectView.isHidden = false
    }
    @IBAction func loadVideoButtonTapped(_ sender: UIButton) {
        if (UIImagePickerController.isSourceTypeAvailable(.photoLibrary)) {

            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = [kUTTypeMovie as String]
            imagePicker.allowsEditing = true
            
            present(imagePicker, animated: true, completion: nil)
        } else{
            myAlert("Photo album inaccessable", message: "Application cannot access the photo album.")
        }
    }
    @IBAction func actionCreateProjectDone(_ sender: Any) {
       
        
        var errorOccurred : Bool = false
        let errorAlert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        errorAlert.popoverPresentationController?.sourceView = self.view
        errorAlert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        if videoURL == nil {
            errorOccurred = true
            errorAlert.title = "please select video"
        }
        else if projectNameTextField.text == ""{
            errorOccurred = true
            errorAlert.title = "please write project name"
        }
        else if frameRateTextField.text == "" {
            errorOccurred = true
            errorAlert.title = "please select frame rate"
        }
        
        // check project name whether overlapped
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let docURL = URL(string: documentsDirectory)!
        let dataPath = docURL.appendingPathComponent("\(projectNameTextField.text!)")

        if projectNameTextField.text != "" && FileManager.default.fileExists(atPath: dataPath.absoluteString) {
            errorOccurred = true
            errorAlert.title = "project name: [\(projectNameTextField.text!)] is already existed"
        }
        
        if(errorOccurred){
            let cancel = UIAlertAction(title: "cancel", style: .destructive)
            errorAlert.addAction(cancel)
            present(errorAlert, animated: true, completion: nil)
        }else{
            do {
                try FileManager.default.createDirectory(atPath: dataPath.absoluteString, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription);
            }
            extractFirstFrame()
            
            let projectName = projectNameTextField.text
            let frameRate = frameRateTextField.text
            let thumbnail = captureImage

            tempNewProject = TemporaryProject(projectName: projectName!, frameRate: Int(frameRate!)!, thumbNail: thumbnail!, videoURL: videoURL.path)
            
         
            
            let newProject = Project(context: self.context)
            
            let imageData: Data = tempNewProject!.thumbNail.pngData()! as Data
            
            // Create a New Project
            newProject.projectName = tempNewProject?.projectName
            newProject.frameRate = Int64(tempNewProject!.frameRate)
            newProject.thumbnail = imageData
            newProject.videoURL = videoURL.path
            
            // will be deprecated: until fetch from coredata is completed
            convertedFPS = Int(frameRate!)!
            selectedProjName = projectName!

            // Save the data
            do{
                try self.context.save()
                
            } catch {
                print("saving error")
            }
            
            // Refetch
            self.fetchProject()
            
            createProjectView.isHidden = true
            tempNewProject = nil
            projectNameTextField.text = ""
            frameRateTextField.text = ""
            captureImage = nil
            projectImageView.image = nil
            
            video2ImageGenerator(video_url: videoURL, mediaType: mediaType as String)
        }
        
    }
    @IBAction func actionCancelCreateProject(_ sender: Any) {
        createProjectView.isHidden = true
        tempNewProject = nil
        projectNameTextField.text = ""
        frameRateTextField.text = ""
        captureImage = nil
        projectImageView.image = nil
    }
    

    private func goProjectVC(){
        let storyboard = UIStoryboard(name: "Edit", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "EditVC") as? EditVC
        vc?.imageArray = imageArray
        vc?.projName = selectedProjName
        vc?.videourl = videoURL
        vc?.convertedFPS = convertedFPS
        vc?.videoSize = videoSize
        self.navigationController?.pushViewController(vc!, animated: true)
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
            generator.requestedTimeToleranceAfter = CMTimeMake(value: 1, timescale: Int32(self.convertedFPS))
            generator.requestedTimeToleranceBefore = CMTimeMake(value: 1, timescale: Int32(self.convertedFPS))
            let tracks = asset.tracks(withMediaType: .video)
            let fps = ceil((tracks.first?.nominalFrameRate)!)
            let totalFrameNum = Int(Double(fps) * duration)
            
            
            print("duration: \(duration)")
            print("total frame: \(totalFrameNum)")
            print("fps: \(fps)")
            var index = 0
            
            while(Int32(index) < Int32(duration * Double(self.convertedFPS))){
                let time:CMTime = CMTimeMake(value: Int64(index), timescale: Int32(self.convertedFPS))
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

extension MainVC : UICollectionViewDelegate, UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    //Number of collectionView Item
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    //Cell init
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProjectCollectionCell", for: indexPath) as? ProjectCollectionCell {
            let project = self.items![indexPath.row]
            cell.lbName.text = project.projectName
            //        cell.projectThumbnailImage.image = UIImage(named: "BasicThumbnail")
            
            cell.projectImageView.image = UIImage(data:project.thumbnail!)
            
            cell.projectImageView.layer.cornerRadius = 20
            
            cell.deleteProjectButton.tag = indexPath.row
            cell.loadProjectButton.tag = indexPath.row
            cell.deleteProjectButton.addTarget(self, action: #selector(deleteProjectButtonTapped(_:)), for: .touchUpInside)
            cell.loadProjectButton.addTarget(self, action: #selector(loadProjectButtonTapped(_:)), for: .touchUpInside)
            
            return cell
        }
        return UICollectionViewCell()
    }
    //clicklistener
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let project = self.items![indexPath.row]
        selectedProjName = project.projectName!
        videoURL = URL(string: project.videoURL!)
        convertedFPS = Int(project.frameRate)
        imageArray = []
        
        // count image num
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let docURL = URL(string: documentsDirectory)!
        let dataPath = docURL.appendingPathComponent("\(selectedProjName)")
        let fm = FileManager.default
        let dirContents = try! fm.contentsOfDirectory(atPath: dataPath.absoluteString)
        let count = dirContents.count
        
        var isSizeSet : Bool = false
        for i in 0...count-1{
            let imageFile = "\(selectedProjName)/original_\(i)"
            let image = ImageFileManager.shared.getSavedImage(named: imageFile)
            
            if(!isSizeSet) {
                self.videoSize = image!.size
                isSizeSet = true
            }
            let thumbnailSize = CGSize(width: 160.0, height: 90.0)
            let rect = CGRect(x: 0, y: 0, width: thumbnailSize.width, height: thumbnailSize.height)
            UIGraphicsBeginImageContextWithOptions(thumbnailSize, false, 1.0)
            image!.draw(in: rect)
            let thumbnailImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.imageArray.append(thumbnailImage!)
        }
        print("tap \(selectedProjName)")
        
        goProjectVC()
        // TODO load PKdrawing
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

extension MainVC: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return frameRatePickerViewData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return frameRatePickerViewData[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        frameRateTextField.text = frameRatePickerViewData[row]
        frameRateTextField.resignFirstResponder()
        frameRatePickerView.isHidden = true
        projectNameTextField.isEnabled = true

    }
}

extension MainVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        mediaType = info[UIImagePickerController.InfoKey.mediaType] as! NSString
        
        if mediaType.isEqual(to: kUTTypeMovie as NSString as String) {
                videoURL = (info[UIImagePickerController.InfoKey.mediaURL] as! URL)
                extractFirstFrame()
        }
        
        if let firstFrameImage = captureImage {
            projectImageView.image = firstFrameImage
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
