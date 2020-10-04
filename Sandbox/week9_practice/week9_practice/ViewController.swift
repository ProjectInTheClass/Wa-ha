//
//  ViewController.swift
//  week9_practice
//
//  Created by TaeHyeong Kim on 2020/10/04.
//

import UIKit

//테이블뷰 표시할 모델
struct CellModel {
    let name : String?
    let image : UIImage?
}

class ViewController: UIViewController {
    
    @IBOutlet weak var tbView: UITableView!
    
    var array : [CellModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //더미 데이터 추가
        for index in 0..<20 {
            array.append(CellModel(name: "\(index) 번째", image: UIImage(named: "ic_mypage_unselected")))
        }
        //tableView 세팅
        tbView.delegate = self
        tbView.dataSource = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DetailViewController {
            guard let cell = sender as? UITableViewCell else { return }
            if let index = tbView.indexPath(for: cell){
                vc.data = array[index.row]
            }
        }
    }
    
    
}
extension ViewController : UITableViewDelegate, UITableViewDataSource{
    //테이블 뷰 높이
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    //cell 갯수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    //cell init
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TableCellTableViewCell") as? TableCellTableViewCell {
            let item = array[indexPath.row]
            cell.lbName.text = item.name
            cell.imgView.image = item.image
            cell.selectionStyle = .none
            return cell
        }
        return UITableViewCell()
    }
    //click listener
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "셀클릭", message: "\(indexPath.row) index selected", preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "확인", style: .default)
        alert.dismiss(animated: true, completion: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        
    }
}

