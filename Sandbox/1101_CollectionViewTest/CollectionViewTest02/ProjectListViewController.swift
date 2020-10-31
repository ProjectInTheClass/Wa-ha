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
    @IBOutlet weak var introMenu: UIView!
    @IBOutlet weak var projectListCollectionView: UICollectionView!
    
    var thumbnail: [UIImage?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
//        getThumbnail()
        projectListCollectionView.dataSource = self
        projectListCollectionView.delegate = self
        
        // 코어 데이터에서 아이템 가져오기
        fetchProject()
        

    }
    
    @IBAction func deleteProjectButtonTapped(_ sender: UIButton) {
        let projectToRemove = items?[sender.tag]

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
        cell.projectThumbnailImage.image = UIImage(named: "BasicThumbnail")
        cell.projectThumbnailImage.layer.cornerRadius = cell.projectThumbnailImage.frame.width/8
        
        //Delete Cell
        cell.deleteProjectButton.tag = indexPath.row
        cell.deleteProjectButton.addTarget(self, action: #selector(deleteProjectButtonTapped(_:)), for: .touchUpInside)
        

        
        
//        cell.layer.cornerRadius = cell.frame.height / 2
    
        return cell
}
    

    
    @IBAction func unwindToProjectList(segue: UIStoryboardSegue) {
        guard segue.identifier == "CreateProject" else { return }
        let sourceViewController = segue.source as! CreateNewProjectViewController
        
        if let tempNewProject = sourceViewController.tempNewProject {
            
            let newProject = Project(context: self.context)
            // Create a New Project
            newProject.projectName = tempNewProject.projectName
            newProject.frameRate = Int64(tempNewProject.frameRate)
            // newProject.thumbnail = UIImage(named: "BasicThumbnail")
            
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


