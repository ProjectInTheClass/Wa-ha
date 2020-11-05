//
//  ViewController.swift
//  CollectionViewTest02
//
//  Created by Teo Hwang on 2020/10/06.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext    
    var items: [Project]?
    var tempNewProject = CreateNewProjectViewController()
    

    @IBOutlet weak var createNewProjectButton: UIButton!
    @IBOutlet weak var DeleteModeButton: UIButton!
    @IBOutlet weak var introMenu: UIView!
    @IBOutlet weak var projectListCollectionView: UICollectionView!
    
    var thumbnail: [UIImage?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFlowLayout()
//        getThumbnail()
        projectListCollectionView.dataSource = self
        projectListCollectionView.delegate = self
        
        // 코어 데이터에서 아이템 가져오기
        fetchProject()
        
        //인트로 메뉴 UIView 디자인
        introMenu.layer.shadowColor = UIColor.black.cgColor
        introMenu.layer.shadowOffset = CGSize(width: 0, height: 0)
        introMenu.layer.shadowRadius = 20
        introMenu.layer.shadowOpacity = 0.3
        
        
    }
    
    
    @IBAction func deleteModeButtonTapped(_ sender: Any) {
        projectListCollectionView.indexPathsForVisibleItems.forEach { (indexPath) in
            let cell = projectListCollectionView.cellForItem(at: indexPath) as! ProjectCell
            
            cell.isEditing = !isEditing
        }

    }
    
    private func setupFlowLayout() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 20
        flowLayout.minimumLineSpacing = 20
        flowLayout.itemSize = CGSize(width: 150 , height: 180)
        flowLayout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        self.projectListCollectionView.collectionViewLayout = flowLayout
    }
    
    
    @IBAction func deleteProjectButtonTapped(_ sender: UIButton) {
        let deleteAlert = UIAlertController(title: "Delete Project", message: "Deletion is permanent and can't be reversed", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
           
            let projectToRemove = self.items?[sender.tag]

            // Remove the project
        
            self.context.delete(projectToRemove!)

            // Save the data
            do{
                try self.context.save()
            } catch {

            }

            // Re-fetch the data
            self.fetchProject()
        }
        
        let cancleAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        deleteAlert.addAction(cancleAction)
        deleteAlert.addAction(deleteAction)
        present(deleteAlert, animated: true, completion: nil)
        
        
    }
    
    
    
    
    func fetchProject(){
        // 코어데이터에서 데이터 가져와서 콜렉션뷰에 보이기
        do {
            self.items = try context.fetch(Project.fetchRequest())
            
            ///?? 뭔가 백그라운드에서 실행되고 그런 개념인것같은데..
            DispatchQueue.main.async {
                self.projectListCollectionView.reloadData()
            }
        } catch {
            
        }
    }
        
}



extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items?.count ?? 0
}

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = projectListCollectionView.dequeueReusableCell(withReuseIdentifier: ProjectCell.identifier, for: indexPath) as! ProjectCell
        
        let project = self.items![indexPath.row]
        
        cell.projectNameLabel?.text = project.projectName
        
        cell.projectThumbnailImage.image = UIImage(data: project.thumbnail!)
            
        cell.projectThumbnailImage.layer.cornerRadius = cell.projectThumbnailImage.frame.width/8
        
        //Delete Cell
        cell.deleteProjectButton.tag = indexPath.row
        cell.deleteProjectButton.addTarget(self, action: #selector(deleteProjectButtonTapped(_:)), for: .touchUpInside)
    
        return cell
}
    

    
    @IBAction func unwindToProjectList(segue: UIStoryboardSegue) {
        guard segue.identifier == "CreateProject" else { return }
        let sourceViewController = segue.source as! CreateNewProjectViewController
        
        if let tempNewProject = sourceViewController.tempNewProject {
            
            let newProject = Project(context: self.context)
            
            let imageData: Data = tempNewProject.thumbNail.pngData()! as Data
            
            // Create a New Project
            newProject.projectName = tempNewProject.projectName
            newProject.frameRate = Int64(tempNewProject.frameRate)
            newProject.thumbnail = imageData
            
            // Save the data
            do{
            try self.context.save()
            } catch {
                
            }
            
            // Refetch
            self.fetchProject()
        }
        
    }
    
}


