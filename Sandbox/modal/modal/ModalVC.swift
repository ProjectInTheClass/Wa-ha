//
//  ModalVC.swift
//  modal
//
//  Created by TaeHyeong Kim on 2020/10/04.
//

import UIKit

protocol Modaldelegate {
    func sendtext(text : String?)
}

class ModalVC: UIViewController {
    @IBOutlet weak var tf: UITextField!
    
    var delegate : Modaldelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func actionOK(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.sendtext(text: self.tf.text)
        }
    }
}
