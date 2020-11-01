//
//  CreateNewProjectViewController.swift
//  201012_Waha_ProjectList_v001
//
//  Created by Teo Hwang on 2020/10/24.
//

import UIKit
import CoreData
import MobileCoreServices
import AVKit



class CreateNewProjectViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var tempNewProject: TemporaryProject?

    @IBOutlet weak var createNewProjectView: UIView!
    @IBOutlet weak var createNewProjectLabel: UILabel!
    @IBOutlet weak var addVideoButton: UIButton!
    @IBOutlet weak var projectImageView: UIImageView!
    @IBOutlet weak var projectNameTextField: UITextField!
    @IBOutlet weak var frameRateTextField: UITextField!
    @IBOutlet weak var cancleCreateNewProjectButton: UIButton!
    @IBOutlet weak var NewProjectButton: UIButton!
    
    
    var frameRatePickerView = UIPickerView()
    
    let frameRatePickerViewData = ["12", "15", "30"]
    
    let imagePicker: UIImagePickerController! = UIImagePickerController()
    var captureImage: UIImage!
    var videoURL: URL!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        frameRatePickerView.dataSource = self
        frameRatePickerView.delegate = self
        imagePicker.delegate = self
        
        frameRateTextField.inputView = frameRatePickerView
        
        

        // Do any additional setup after loading the view.
        
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
    
    
    @IBAction func loadVideoButtonTapped(_ sender: UIButton) {
        if (UIImagePickerController.isSourceTypeAvailable(.photoLibrary)) {

            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = [kUTTypeMovie as String]
            imagePicker.allowsEditing = false
            
            present(imagePicker, animated: true, completion: nil)
        } else{
            myAlert("Photo album inaccessable", message: "Application cannot access the photo album.")
        }
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        extractFirstFrame()
        
        guard segue.identifier == "CreateProject",
              let projectName = projectNameTextField.text,
              let frameRate = frameRateTextField.text,
              let thumbnail = captureImage else { return }
        tempNewProject = TemporaryProject(projectName: projectName, frameRate: Int(frameRate)!, thumbNail: thumbnail)
    }


}

extension CreateNewProjectViewController: UIPickerViewDataSource, UIPickerViewDelegate {
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
    }
}

extension CreateNewProjectViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! NSString
        
        if mediaType.isEqual(to: kUTTypeMovie as NSString as String) {
                videoURL = (info[UIImagePickerController.InfoKey.mediaURL] as! URL)
                extractFirstFrame()
                UISaveVideoAtPathToSavedPhotosAlbum(videoURL.relativePath, self, nil, nil)
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
