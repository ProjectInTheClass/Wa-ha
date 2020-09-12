//
//  Extensions.swift
//  TK
//
//  Created by TaeHyeong Kim on 2020/07/15.
//  Copyright © 2020 TaeHyeong Kim. All rights reserved.
//

import Foundation
import UIKit



class Utils {
    static func version() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "\(version) build \(build)"
    }
    static func BoolToString(_ bool : Bool) -> String{
        if bool{
            return "Y"
        }else{
            return ""
        }
    }
    //ALERT CONTROLLER
    static func showAlertMessage(vc: UIViewController, titleStr:String, messageStr:String) -> Void {
        let alert = UIAlertController(title: titleStr, message: messageStr, preferredStyle: UIAlertController.Style.alert);
        let action = UIAlertAction(title: "확인", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        vc.present(alert, animated: true, completion: nil)
    }
    static func showTextFieldAlertMessage(vc : UIViewController, titleStr: String, messageStr: String, placeHolder: String) -> String {
        var returnStr = ""
        let alertController = UIAlertController(title: titleStr, message: messageStr, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = placeHolder
        }
        let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak alertController] _ in
            guard let alertController = alertController, let textField = alertController.textFields?.first else { return }
            
            print("Current password \(String(describing: textField.text))")
            returnStr = textField.text ?? ""
            
        }
        alertController.addAction(confirmAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        vc.present(alertController, animated: true, completion: nil)
        return returnStr
    }
    //ROUNDING
    static func roundImageView(_ imgView : UIImageView){
        imgView.layer.cornerRadius = imgView.frame.height/2
        imgView.layer.borderWidth = 1
        imgView.layer.borderColor = UIColor.clear.cgColor
        imgView.clipsToBounds = true
    }
    static func roundImageViewWithBorder(_ imgView : UIImageView, _ border : Int){
        imgView.layer.cornerRadius = imgView.frame.height/2
        imgView.layer.borderWidth = CGFloat(border)
        imgView.layer.borderColor = UIColor.brown.cgColor
        imgView.clipsToBounds = true
    }
    static func roundUiView(_ v : UIView){
        v.layer.cornerRadius = v.frame.height/2
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.clear.cgColor
        v.clipsToBounds = true
    }
    //hot new label selector
    static func hotOrNew(_ hot : UIButton, _ new : UIButton, _ isHot : String?, _ isNew : String?){
        if isHot == "Y"{
            hot.isHidden = false
        }else{
            hot.isHidden = true
        }
        if isNew == "Y"{
            new.isHidden = false
        }else{
            new.isHidden = true
        }
    }
    //Star rating
    static func starRatingView(_ star_1 : UIImageView, _ star_2 : UIImageView, _ star_3 : UIImageView, _ star_4 : UIImageView, _ star_5 : UIImageView, _ score : Int){
        switch score {
        case 1:
            star_1.image = UIImage(named: "ic_star_yellow")
            star_2.image = UIImage(named: "ic_star_gray")
            star_3.image = UIImage(named: "ic_star_gray")
            star_4.image = UIImage(named: "ic_star_gray")
            star_5.image = UIImage(named: "ic_star_gray")
            break
        case 2:
            star_1.image = UIImage(named: "ic_star_yellow")
            star_2.image = UIImage(named: "ic_star_yellow")
            star_3.image = UIImage(named: "ic_star_gray")
            star_4.image = UIImage(named: "ic_star_gray")
            star_5.image = UIImage(named: "ic_star_gray")
            break
        case 3:
            star_1.image = UIImage(named: "ic_star_yellow")
            star_2.image = UIImage(named: "ic_star_yellow")
            star_3.image = UIImage(named: "ic_star_yellow")
            star_4.image = UIImage(named: "ic_star_gray")
            star_5.image = UIImage(named: "ic_star_gray")
            break
        case 4:
            star_1.image = UIImage(named: "ic_star_yellow")
            star_2.image = UIImage(named: "ic_star_yellow")
            star_3.image = UIImage(named: "ic_star_yellow")
            star_4.image = UIImage(named: "ic_star_yellow")
            star_5.image = UIImage(named: "ic_star_gray")
            break
        case 5:
            star_1.image = UIImage(named: "ic_star_yellow")
            star_2.image = UIImage(named: "ic_star_yellow")
            star_3.image = UIImage(named: "ic_star_yellow")
            star_4.image = UIImage(named: "ic_star_yellow")
            star_5.image = UIImage(named: "ic_star_yellow")
            break
        default:
            break
        }
        
    }
    static func starRatingButton(_ star_1 : UIButton,_ star_2 : UIButton,_ star_3 : UIButton,_ star_4 : UIButton,_ star_5 : UIButton, _ score : Int){
        switch score {
        case 1:
            star_1.setImage(UIImage(named: "ic_star_yellow"), for: .normal)
            star_2.setImage(UIImage(named: "ic_star_gray"), for: .normal)
            star_3.setImage(UIImage(named: "ic_star_gray"), for: .normal)
            star_4.setImage(UIImage(named: "ic_star_gray"), for: .normal)
            star_5.setImage(UIImage(named: "ic_star_gray"), for: .normal)
            break
        case 2:
            star_1.setImage(UIImage(named: "ic_star_yellow"), for: .normal)
            star_2.setImage(UIImage(named: "ic_star_yellow"), for: .normal)
            star_3.setImage(UIImage(named: "ic_star_gray"), for: .normal)
            star_4.setImage(UIImage(named: "ic_star_gray"), for: .normal)
            star_5.setImage(UIImage(named: "ic_star_gray"), for: .normal)
            break
        case 3:
            star_1.setImage(UIImage(named: "ic_star_yellow"), for: .normal)
            star_2.setImage(UIImage(named: "ic_star_yellow"), for: .normal)
            star_3.setImage(UIImage(named: "ic_star_yellow"), for: .normal)
            star_4.setImage(UIImage(named: "ic_star_gray"), for: .normal)
            star_5.setImage(UIImage(named: "ic_star_gray"), for: .normal)
            break
        case 4:
            star_1.setImage(UIImage(named: "ic_star_yellow"), for: .normal)
            star_2.setImage(UIImage(named: "ic_star_yellow"), for: .normal)
            star_3.setImage(UIImage(named: "ic_star_yellow"), for: .normal)
            star_4.setImage(UIImage(named: "ic_star_yellow"), for: .normal)
            star_5.setImage(UIImage(named: "ic_star_gray"), for: .normal)
            break
        case 5:
            star_1.setImage(UIImage(named: "ic_star_yellow"), for: .normal)
            star_2.setImage(UIImage(named: "ic_star_yellow"), for: .normal)
            star_3.setImage(UIImage(named: "ic_star_yellow"), for: .normal)
            star_4.setImage(UIImage(named: "ic_star_yellow"), for: .normal)
            star_5.setImage(UIImage(named: "ic_star_yellow"), for: .normal)
            break
        default:
            break
        }
    }
}

extension CALayer {
    //전에 layout if needed 해야함
    func addBorder(_ arr_edge: [UIRectEdge], color: UIColor, width: CGFloat) {
        for edge in arr_edge {
            let border = CALayer()
            switch edge {
            case UIRectEdge.top:
                border.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: width)
                break
            case UIRectEdge.bottom:
                border.frame = CGRect.init(x: 0, y: frame.height - width, width: frame.width, height: width)
                break
            case UIRectEdge.left:
                border.frame = CGRect.init(x: 0, y: 0, width: width, height: frame.height)
                break
            case UIRectEdge.right:
                border.frame = CGRect.init(x: frame.width - width, y: 0, width: width, height: frame.height)
                break
            default:
                break
            }
            border.backgroundColor = color.cgColor;
            self.addSublayer(border)
        }
    }
}
extension UIView {
    func addBackground(imageName: String = "YOUR DEFAULT IMAGE NAME", contentMode: UIView.ContentMode = .scaleToFill) {
        // setup the UIImageView
        let backgroundImageView = UIImageView(frame: UIScreen.main.bounds)
        backgroundImageView.image = UIImage(named: imageName)
        backgroundImageView.contentMode = contentMode
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(backgroundImageView)
        sendSubviewToBack(backgroundImageView)
        
        // adding NSLayoutConstraints
        let leadingConstraint = NSLayoutConstraint(item: backgroundImageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0)
        let trailingConstraint = NSLayoutConstraint(item: backgroundImageView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0)
        let topConstraint = NSLayoutConstraint(item: backgroundImageView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0)
        let bottomConstraint = NSLayoutConstraint(item: backgroundImageView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        
        NSLayoutConstraint.activate([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
    }
}
extension UITextField {
    func addTextFieldIcon(_ image: UIImage) {
        let iconView = UIImageView(frame:
            CGRect(x: 12, y: 6, width: 13, height: 15))
        iconView.contentMode = .scaleAspectFit
        iconView.image = image
        let iconContainerView: UIView = UIView(frame:
            CGRect(x: 20, y: 0, width: 35, height: 30))
        iconContainerView.addSubview(iconView)
        leftView = iconContainerView
        leftViewMode = .always
    }
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
extension UIView {
    //animation like push
    func slidePush(duration: TimeInterval = 0.5, completionDelegate: AnyObject? = nil) {
        // Create a CATransition
        let slidePushTransition = CATransition()
        
        // Set its callback delegate to the completionDelegate
        if let delegate: AnyObject = completionDelegate {
            slidePushTransition.delegate = (delegate as! CAAnimationDelegate)
        }
        // animation's properties
        slidePushTransition.type = CATransitionType.push
        slidePushTransition.subtype = CATransitionSubtype.fromRight
        slidePushTransition.duration = duration
        slidePushTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        slidePushTransition.fillMode = CAMediaTimingFillMode.removed
        // Add it to the View's layer
        self.layer.add(slidePushTransition, forKey: "slidePushTransition")
    }
    //animation like pop
    func slidePop(duration : TimeInterval = 0.5, completionDelegate : AnyObject? = nil, completion : @escaping(_ result : Bool) -> Void){
        
        //Create a CATTransition
        let slidePopTransition = CATransition()
        
        //set its callback delegate to the completionDelegate
        if let delegate : AnyObject = completionDelegate {
            slidePopTransition.delegate = delegate as? CAAnimationDelegate
            
        }
        
        //Animation's properties
        slidePopTransition.type = CATransitionType.push
        slidePopTransition.subtype = CATransitionSubtype.fromLeft
        slidePopTransition.duration = duration
        slidePopTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        slidePopTransition.fillMode = CAMediaTimingFillMode.forwards
        
        self.layer.add(slidePopTransition, forKey: "slidePushTransition")
        
        completion(true)
    }
    //menu open
    func slideMenuOpen(duration : TimeInterval = 0.5, completionDelegate : AnyObject? = nil, completion : @escaping(_ result : Bool) -> Void){
        
        //Create a CATTransition
        let slidePopTransition = CATransition()
        
        //set its callback delegate to the completionDelegate
        if let delegate : AnyObject = completionDelegate {
            slidePopTransition.delegate = delegate as? CAAnimationDelegate
            
        }
        
        //Animation's properties
        slidePopTransition.type = CATransitionType.moveIn
        slidePopTransition.subtype = CATransitionSubtype.fromLeft
        slidePopTransition.duration = duration
        slidePopTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        slidePopTransition.fillMode = CAMediaTimingFillMode.forwards
        
        self.layer.add(slidePopTransition, forKey: "slidePushTransition")
        
        completion(true)
    }
    //menu close
    func slideMenuClose(duration : TimeInterval = 0.5, completionDelegate : AnyObject? = nil, completion : @escaping(_ result : Bool) -> Void){
        
        //Create a CATTransition
        let slidePopTransition = CATransition()
        
        //set its callback delegate to the completionDelegate
        if let delegate : AnyObject = completionDelegate {
            slidePopTransition.delegate = delegate as? CAAnimationDelegate
            
        }
        //Animation's properties
        slidePopTransition.type = CATransitionType.moveIn
        slidePopTransition.subtype = CATransitionSubtype.fromRight
        slidePopTransition.duration = duration
        slidePopTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        slidePopTransition.fillMode = CAMediaTimingFillMode.removed
        
        self.layer.add(slidePopTransition, forKey: "slidePushTransition")
        
        completion(true)
    }
    //round corner
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
}
extension UISearchBar {
    func getTextField() -> UITextField? { return value(forKey: "searchField") as? UITextField }
    func setTextField(color: UIColor) {
        guard let textField = getTextField() else { return }
        switch searchBarStyle {
        case .minimal:
            textField.layer.backgroundColor = color.cgColor
            textField.layer.cornerRadius = 6
        case .prominent, .default: textField.backgroundColor = color
        @unknown default: break
        }
    }
}
extension UIViewController {
    var activityIndicatorTag: Int { return 999999 }
    var loadingTag: Int{return 1234321}
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    func startActivityIndicator(style: UIActivityIndicatorView.Style = .large, location: CGPoint? = nil) {
        //Set the position - defaults to `center` if no`location`
        //argument is provided
        let loc = location ?? self.view.center
        //Ensure the UI is updated from the main thread
        //in case this method is called from a closure
        DispatchQueue.main.async {
            //            //Create the activity indicator
            //            let activityIndicator = UIActivityIndicatorView(style: style)
            //            //Add the tag so we can find the view in order to remove it later
            //
            //            activityIndicator.tag = self.activityIndicatorTag
            //            //Set the location
            //
            //            activityIndicator.center = loc
            //            activityIndicator.hidesWhenStopped = true
            //            //Start animating and add the view
            //
            //            activityIndicator.startAnimating()
            //            self.view.addSubview(activityIndicator)
            
            let imageView = UIImageView(image: UIImage(named: "new_ic_loading"))
            let animation = CABasicAnimation(keyPath: "transform.rotation")
            animation.fromValue = 0
            animation.toValue =  Double.pi * 2.0
            animation.duration = 1.5
            animation.repeatCount = .infinity
            animation.isRemovedOnCompletion = false
            
            imageView.layer.add(animation, forKey: "spin")
            imageView.tag = self.loadingTag
            imageView.center = loc
            self.view.addSubview(imageView)
            
        }
    }
    func stopActivityIndicator() {
        //Again, we need to ensure the UI is updated from the main thread!
        DispatchQueue.main.async {
            //Here we find the `UIActivityIndicatorView` and remove it from the view
            //            if let activityIndicator = self.view.subviews.filter(
            //                { $0.tag == self.activityIndicatorTag}).first as? UIActivityIndicatorView {
            //                activityIndicator.stopAnimating()
            //                activityIndicator.removeFromSuperview()
            //            }
            if let loadingIndicator = self.view.subviews.filter(
                { $0.tag == self.loadingTag}).first as? UIImageView {
                loadingIndicator.stopAnimating()
                loadingIndicator.removeFromSuperview()
            }
        }
    }
    
    typealias AlertActionHandler = ((UIAlertAction) -> Void)
    
    /// only 'title' is required parameter. you can ignore rest of them
    ///
    /// - Parameters:
    ///   - title: Title string. required.
    ///   - message: Message for alert.
    ///   - okTitle: Title for confirmation action. If you don't probide 'okHandler', this will be ignored.
    ///   - okHandler: Closure for confirmation action. If it's implemented, alertController will have two alertAction.
    ///   - cancelTitle: Title for cancel/dissmis action.
    ///   - cancelHandler: Closure for cancel/dissmis action.
    ///   - completion: Closure will be called right after the alertController presented.
    func alert(title: String,
               message: String? = nil,
               okTitle: String = "OK",
               okHandler: AlertActionHandler? = nil,
               cancelTitle: String? = nil,
               cancelHandler: AlertActionHandler? = nil,
               completion: (() -> Void)? = nil) {
        
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let okClosure = okHandler {
            let okAction: UIAlertAction = UIAlertAction(title: okTitle, style: UIAlertAction.Style.default, handler: okClosure)
            alert.addAction(okAction)
            let cancelAction: UIAlertAction = UIAlertAction(title: cancelTitle, style: UIAlertAction.Style.cancel, handler: cancelHandler)
            alert.addAction(cancelAction)
        } else {
            if cancelTitle != nil {
                
                let cancelAction: UIAlertAction = UIAlertAction(title: okTitle, style: UIAlertAction.Style.cancel, handler: cancelHandler)
                alert.addAction(cancelAction)
            } else {
                let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: cancelHandler)
                alert.addAction(cancelAction)
            }
            
        }
        self.present(alert, animated: true, completion: completion)
        
    }
//    https://draupnir45.github.io/i.jongchan.park/Swift_learning/UIAlertController_made_easy.html
}

extension Int {
    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        return numberFormatter.string(from: NSNumber(value:self))!
    }
}
extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
extension NSObject {
    static var reusableIdentifier: String {
        return String(describing: self)
    }
}
extension UIPageViewController {
    func goToNextPage() {
        guard let currentViewController = self.viewControllers?.first else { return }
        guard let nextViewController = dataSource?.pageViewController( self, viewControllerAfter: currentViewController ) else { return }
        setViewControllers([nextViewController], direction: .forward, animated: false, completion: nil)
    }
    func goToPreviousPage() {
        guard let currentViewController = self.viewControllers?.first else { return }
        guard let previousViewController = dataSource?.pageViewController( self, viewControllerBefore: currentViewController ) else { return }
        setViewControllers([previousViewController], direction: .reverse, animated: false, completion: nil)
    }
}

extension UIImageView {
    func applyshadowWithCorner(containerView : UIView, cornerRadious : CGFloat){
        containerView.clipsToBounds = false
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.16
        containerView.layer.shadowOffset = CGSize.zero
        containerView.layer.shadowRadius = 5
        containerView.layer.cornerRadius = cornerRadious
        containerView.layer.shadowPath = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: cornerRadious).cgPath
        self.clipsToBounds = true
        self.layer.cornerRadius = cornerRadious
    }
}
