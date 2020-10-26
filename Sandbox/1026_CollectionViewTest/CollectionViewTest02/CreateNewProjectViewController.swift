//
//  CreateNewProjectViewController.swift
//  201012_Waha_ProjectList_v001
//
//  Created by Teo Hwang on 2020/10/24.
//

import UIKit
import CoreData



class CreateNewProjectViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var tempNewProject: TemporaryProject?

    @IBOutlet weak var createNewProjectView: UIView!
    @IBOutlet weak var createNewProjectLabel: UILabel!
    @IBOutlet weak var addVideoButton: UIButton!
    @IBOutlet weak var addVideoView: UIView!
    @IBOutlet weak var projectNameTextField: UITextField!
    @IBOutlet weak var frameRateTextField: UITextField!
    @IBOutlet weak var createNewProjectButton: UIButton!
    @IBOutlet weak var cancleNewProjectButton: UIButton!
    
    var frameRatePickerView = UIPickerView()
    
    let frameRatePickerViewData = ["12", "15", "30"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        frameRatePickerView.dataSource = self
        frameRatePickerView.delegate = self
        
        frameRateTextField.inputView = frameRatePickerView
        
        

        // Do any additional setup after loading the view.
        
    }
    
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        guard segue.identifier == "CreateProject",
              let projectName = projectNameTextField.text,
              let frameRate = frameRatePickerView.dataSource,
              let thumbnail = UIImage(named: "BasicThumbnail") else { return }
        tempNewProject = TemporaryProject(projectName: projectName, frameRate: frameRate as! Int, thumbNail: thumbnail)
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


