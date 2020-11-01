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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: collectionview.frame.width/2-100, bottom: 0, right: collectionview.frame.width/2)
        collectionview.collectionViewLayout = layout
        
        //import Nib
        let projectCellNib = UINib(nibName: "FrameCollectionViewCell", bundle: nil)
        collectionview.register(projectCellNib, forCellWithReuseIdentifier: "FrameCollectionViewCell")
        collectionview.delegate = self
        collectionview.dataSource = self
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
        return CGSize(width: 100, height: collectionView.frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FrameCollectionViewCell", for: indexPath) as! FrameCollectionViewCell
        cell.imgview.image = imageArray[indexPath.row]
        cell.imgview.backgroundColor = .lightGray
        cell.imgview.layer.cornerRadius = 10
        
        if index == 0 {
            cell.roundCorners(corners: [.topLeft, .topRight], radius: 10)
        }else{
            cell.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 10)
        }
        
        if indexPath.row == selectedIndex {
            if index == 0 {
                cell.border_top.backgroundColor = .green
                cell.border_left.backgroundColor = .green
                cell.border_right.backgroundColor = .green
                cell.border_bottom.backgroundColor = .green
            }else{
                
                cell.border_top.backgroundColor = .green
                cell.border_bottom.backgroundColor = .green
                cell.border_left.backgroundColor = .green
                cell.border_right.backgroundColor = .green
            }
        }else{
            if index == 0 {
                cell.border_bottom.backgroundColor = .clear
                cell.border_top.backgroundColor = .clear
                cell.border_left.backgroundColor = .clear
                cell.border_right.backgroundColor = .clear
            }else{
                cell.border_top.backgroundColor = .clear
                cell.border_bottom.backgroundColor = .clear
                cell.border_left.backgroundColor = .clear
                cell.border_right.backgroundColor = .clear
            }
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
//        let point = convert(collectionview.center, to: collectionview)
//        let index : Int = Int(round((point.x - collectionview.frame.width/2.2)/CGFloat(imageArray.count)))
//        if index >= 0 && index < imageArray.count {
//            delegate.selectedIndex(index: index)
//        }
        
        
    }
}

//same scroll refer
//https://stackoverflow.com/questions/48461698/synchronised-scrolling-uicollectionviews-in-uitableviewcell-in-swift/48463426

//https://stackoverflow.com/questions/35045155/how-to-create-a-centered-uicollectionview-like-in-spotifys-player
