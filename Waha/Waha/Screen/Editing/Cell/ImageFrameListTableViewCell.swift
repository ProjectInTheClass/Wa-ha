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


class ImageFrameListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var collectionview: UICollectionView!
    weak var scrollDelegate: collectionViewDidScrollDelegate?

    var imageArray : [UIImage] = []
    var delegate : frameSelectDelegate! = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: collectionview.frame.width/2, bottom: 0, right: collectionview.frame.width/2)
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
        print("collectionview count: \(imageArray.count)")
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FrameCollectionViewCell", for: indexPath) as! FrameCollectionViewCell
        cell.backgroundColor = .red
        cell.imgview.image = imageArray[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate.selectedIndex(index: indexPath.row)
    }
}
extension ImageFrameListTableViewCell : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.didScrolled(to: scrollView.contentOffset.x)
        
        let point = convert(collectionview.center, to: collectionview)
        let index : Int = Int(round((point.x - collectionview.frame.width/2)/110))
        print("계산된 index \(index)")
        if index >= 0 && index < imageArray.count {
            delegate.selectedIndex(index: index)
        }
    }
//    62프레임 0부터 6810.0 109로 나눔
}

//same scroll refer
//https://stackoverflow.com/questions/48461698/synchronised-scrolling-uicollectionviews-in-uitableviewcell-in-swift/48463426
