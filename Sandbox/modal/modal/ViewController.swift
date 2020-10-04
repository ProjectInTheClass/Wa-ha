//
//  ViewController.swift
//  modal
//
//  Created by TaeHyeong Kim on 2020/10/04.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var lb: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func actionpresentt(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "ModalVC") as? ModalVC
        vc?.delegate = self
        self.present(vc!, animated: true, completion: nil)
    }
    
}
extension ViewController : Modaldelegate {
    func sendtext(text: String?) {
        lb.text = text
    }
}

