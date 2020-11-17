//
//  ImageFrameListTableViewCell.swift
//  Waha
//
//  Created by TaeHyeong Kim on 2020/09/26.
//  Copyright © 2020 TaeHyeong Kim. All rights reserved.
//

import UIKit

protocol frameSelectDelegate {
    func selectedIndex(index : Int)
}
protocol sliderDelegate {
    func sliderDidMoved(value : Float, layer : Int)
}

class ImageFrameListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var collectionview: UICollectionView!
    weak var scrollDelegate: collectionViewDidScrollDelegate?
    
    var imageArray : [UIImage] = []
    var delegate : frameSelectDelegate! = nil
    var sliderDelegate : sliderDelegate! = nil
    var selectedIndex : Int = 0
    var index : Int = 0
    var frameLastCallTime : Double?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: collectionview.frame.width/2-70, bottom: 0, right: collectionview.frame.width/2)
        collectionview.collectionViewLayout = layout
        
        //import Nib
        let projectCellNib = UINib(nibName: "FrameCollectionViewCell", bundle: nil)
        collectionview.register(projectCellNib, forCellWithReuseIdentifier: "FrameCollectionViewCell")
        collectionview.delegate = self
        collectionview.dataSource = self
        collectionview.backgroundColor = .clear
        collectionview.showsHorizontalScrollIndicator = false
        //Scroll Sync
        (collectionview as UIScrollView).delegate = self
        //select center item
        
    }
    
    
    @IBAction func actionSlider(_ sender: UISlider) {
        sliderDelegate.sliderDidMoved(value: sender.value, layer: index)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
}
extension ImageFrameListTableViewCell : UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 70, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FrameCollectionViewCell", for: indexPath) as! FrameCollectionViewCell
        cell.imgview.image = imageArray[indexPath.row]
        cell.imgview.backgroundColor = .white
        cell.imgview.layer.cornerRadius = 5.7
        
        if index == 0 {
            cell.roundCorners(corners: [.topLeft, .topRight], radius: 6)
        }else{
            cell.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 6)
        }

        if indexPath.row == selectedIndex {
            cell.border_top.backgroundColor = #colorLiteral(red: 0.3529411765, green: 1, blue: 0.4117647059, alpha: 1)
            cell.border_left.backgroundColor = #colorLiteral(red: 0.3529411765, green: 1, blue: 0.4117647059, alpha: 1)
            cell.border_right.backgroundColor = #colorLiteral(red: 0.3529411765, green: 1, blue: 0.4117647059, alpha: 1)
            cell.border_bottom.backgroundColor = #colorLiteral(red: 0.3529411765, green: 1, blue: 0.4117647059, alpha: 1)
        }else{
            cell.border_bottom.backgroundColor = .clear
            cell.border_top.backgroundColor = .clear
            cell.border_left.backgroundColor = .clear
            cell.border_right.backgroundColor = .clear
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate.selectedIndex(index: indexPath.row)
    }
}
extension ImageFrameListTableViewCell : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.didScrolled(to: scrollView.contentOffset.x)
        if(frameLastCallTime != nil && Date().timeIntervalSinceReferenceDate - frameLastCallTime! < 0.1){
            return
        }else{
            frameLastCallTime = Date().timeIntervalSinceReferenceDate
        }
        let point = convert(collectionview.center, to: collectionview)
        let index : Int = Int(round((point.x - collectionview.frame.width/2)/70))
        if index >= 0 && index < imageArray.count {
            delegate.selectedIndex(index: index)
        }
    }
}

//same scroll refer
//https://stackoverflow.com/questions/48461698/synchronised-scrolling-uicollectionviews-in-uitableviewcell-in-swift/48463426

//https://stackoverflow.com/questions/35045155/how-to-create-a-centered-uicollectionview-like-in-spotifys-player
