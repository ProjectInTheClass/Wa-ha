//
//  ViewController.swift
//  Waha
//
//  Created by TaeHyeong Kim on 2020/09/11.
//  Copyright © 2020 TaeHyeong Kim. All rights reserved.
//

import UIKit

class MainVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var projectArray : [String] = ["프로젝트 추가"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        collectionView.collectionViewLayout = layout
        
        let projectCellNib = UINib(nibName: "ProjectCollectionCell", bundle: nil)
        self.collectionView.register(projectCellNib, forCellWithReuseIdentifier: "ProjectCollectionCell")
        
    }
    private func goProjectVC(){
        let storyboard = UIStoryboard(name: "Edit", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "EditVC") as? EditVC
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    private func importvideo(){
        let storyboard = UIStoryboard(name: "VideoSelect", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "VideoSelectVC") as? VideoSelectVC
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
}
extension MainVC : UICollectionViewDelegate, UICollectionViewDataSource{
    //Number of collectionView Item
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return projectArray.count
    }
    //Cell init
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProjectCollectionCell", for: indexPath) as? ProjectCollectionCell {
            if indexPath == [0,0]{
                cell.lbName.text = "새 프로젝트 시작"
                cell.btnInfo.isHidden = true
            }
            return cell
        }
        return UICollectionViewCell()
    }
    //clicklistener
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath == [0,0] {
            importvideo()
        }else{
            if let cell = collectionView.cellForItem(at: indexPath) as? ProjectCollectionCell {
                goProjectVC()
            }
        }
        
    }
}
extension MainVC : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let rowItemCount : CGFloat = 5
        let spaceBetweenCell : CGFloat = 5
        let spacing : CGFloat = 5
        let totalSpacing = (2 * spacing) + ((rowItemCount - 1) * spaceBetweenCell)
        if let collection = self.collectionView {
            let width = (collection.bounds.width - totalSpacing)/rowItemCount - 60
            return CGSize(width: width, height: width+57)
        }else{
            return CGSize(width: 100, height: 100)
        }
    }
}
