//
//  ImageFrameListTableViewCell.swift
//  Waha
//
//  Created by TaeHyeong Kim on 2020/09/26.
//  Copyright © 2020 TaeHyeong Kim. All rights reserved.
//

import UIKit

class ImageFrameListTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var imageArray : [UIImage] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: collectionView.frame.width/2-100, bottom: 0, right: 0)
        collectionView.collectionViewLayout = layout
        
        
        let projectCellNib = UINib(nibName: "FrameCollectionViewCell", bundle: nil)
        collectionView.register(projectCellNib, forCellWithReuseIdentifier: "FrameCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
    
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
        
    }
    
    
}
