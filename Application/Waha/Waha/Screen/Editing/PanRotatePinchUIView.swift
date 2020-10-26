//https://medium.com/swlh/add-pinch-to-zoom-to-uiimageview-classes-da390f6905d5


import UIKit

class PanRotatePinchUIView: UIView, UIGestureRecognizerDelegate {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        let standardPan = UIPanGestureRecognizer(target: self, action: #selector(standardHandlePan(_:)))
        standardPan.delegate = self
        self.addGestureRecognizer(standardPan)
        
        let standardPinch = UIPinchGestureRecognizer(target: self, action: #selector(standardHandlePinch(_:)))
        standardPinch.delegate = self
        self.addGestureRecognizer(standardPinch)
        
        let standardRotate = UIRotationGestureRecognizer(target: self, action: #selector(standardHandleRotation(_:)))
        standardRotate.delegate = self
        self.addGestureRecognizer(standardRotate)
    }
    
    @objc func standardHandlePan(_ sender: UIPanGestureRecognizer) {
        guard let targetView = sender.view else {return}
        let translation = sender.translation(in: self.superview)
        targetView.center = CGPoint(x: targetView.center.x + translation.x
            ,y: targetView.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.superview)
    }
    
    @objc func standardHandlePinch(_ sender: UIPinchGestureRecognizer) {
        guard let targetView = sender.view else {return}
        targetView.transform = targetView.transform.scaledBy(x: sender.scale, y: sender.scale)
        sender.scale = 1
    }
    
    @objc func standardHandleRotation(_ sender: UIRotationGestureRecognizer) {
        guard let targetView = sender.view else {return}
        targetView.transform = targetView.transform.rotated(by: sender.rotation)
        sender.rotation = 0
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
