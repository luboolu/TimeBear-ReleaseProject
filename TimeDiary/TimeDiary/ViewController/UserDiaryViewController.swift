//
//  UserDiaryViewController.swift
//  TimeDiary
//
//  Created by 김진영 on 2021/11/22.
//
import UIKit

import RealmSwift
import CloudKit
import Toast

final class UserDiaryViewController: UIViewController {
    
    static let identifier = "UserDiaryViewController"
    
    let localRealm = try! Realm()
    
    var tasksTag: Results<UserTag>!
    var tasksDiary: Results<UserDiary>!
    
    @IBOutlet weak var diaryTagTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTableView()
        setRealmTask()
        setNavigation()
        setTapBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        diaryTagTableView.reloadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
        
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    private func setTableView() {
        diaryTagTableView.delegate = self
        diaryTagTableView.dataSource = self
    }
    
    private func setRealmTask() {
        tasksTag = localRealm.objects(UserTag.self).sorted(byKeyPath: "_id", ascending: true)
        tasksDiary = localRealm.objects(UserDiary.self).sorted(byKeyPath: "date", ascending: true)
    }
    
    private func setNavigation() {
        //navigationbar setting
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("my diary", comment: "일기장")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addTagButtonClicked))
    }
    
    private func setTapBar() {
        //tabbar setting
        tabBarController?.tabBar.selectedItem?.title = NSLocalizedString("diary", comment: "일기")
        tabBarController?.tabBar.tintColor = UIColor(named: "bear")
    }

    @objc func addTagButtonClicked(_ sender: UIButton) {
        print(#function)
        //alert에 view(text field)를 추가하는 방식으로 tag 추가
        
        //1. UIAlertController 생성: 밑바탕 + 타이틀 + 본문
        //let alert = UIAlertController(title: "타이틀 테스트", message: "메시지가 입력되었습니다.", preferredStyle: .alert)
        let alert = UIAlertController(title: NSLocalizedString("addFolderTitle", comment: "폴더 추가"), message: NSLocalizedString("addFolderMessage", comment: "폴더 추가"), preferredStyle: .alert)

        alert.addTextField { tagTextField in
            tagTextField.placeholder = NSLocalizedString("folderName", comment: "폴더 이름")
        }
        
        //2. UIAlertAction 생성: 버튼들을...
        let ok = UIAlertAction(title: NSLocalizedString("add", comment: "추가"), style: .default) { ok in
            //ok 버튼이 눌리면 textField에 입력된 값을 UserTag에 추가
            if let tag = alert.textFields?[0].text {
                //if tag 길이가 15자 이상인 경우
                if tag.count > 15 {
                    // present the toast with the new style
                    self.view.makeToast(NSLocalizedString("addFolderLongName", comment: "폴더 생성 실패 - 이름 길어서") ,duration: 2.0, position: .bottom, style: .defaultStyle)
                } else {
                    //1.UserTag에 존재하지 않는 값이 입력된 경우 - 성공
                    let searchTag = self.localRealm.objects(UserTag.self).filter("tag = '\(tag)'")
                    
                    if searchTag.count == 0 {
                        //성공
                        let data = UserTag(tag: tag, contentNum: 0)
                        
                        try! self.localRealm.write {
                            self.localRealm.add(data)
                            self.diaryTagTableView.reloadData()
                        }
                    } else {
                        //실패 - 중복 존재
                        // present the toast with the new style
                        self.view.makeToast(NSLocalizedString("addFolderFailToast", comment: "폴더 생성 실패") ,duration: 2.0, position: .bottom, style: .defaultStyle)
                    }
                    //2.UserTag에 존재하는 값이 입력된 경우 - 실패
                    
                    //2-1. "" 공백값이 입력된 경우 - 실패
                }

            } else {
                // present the toast with the new style
                self.view.makeToast(NSLocalizedString("addFolderFailToast", comment: "폴더 생성 실패") ,duration: 2.0, position: .bottom, style: .defaultStyle)
            }

        }
        
        let cancle = UIAlertAction(title: NSLocalizedString("cancle", comment: "취소"), style: .cancel) { cancle in
            // present the toast with the new style
            self.view.makeToast(NSLocalizedString("addFolderCancleToast", comment: "폴더 생성 취소") ,duration: 2.0, position: .bottom, style: .defaultStyle)
        }
        //3. 1 + 2
        alert.addAction(cancle)
        alert.addAction(ok)

        //4. present
        present(alert, animated: true, completion: nil)
    }
    
    private func deleteImageFromDocumentDirectory(imageName: String) {
        //AddViewController의 saveButtonClicked와 같은 구조
        
        //1. 이미지를 저장할 경로 설정: document 폴더 -> FileManager 사용
        // Desktop/jack/ios/folder 도큐먼트 폴더의 경로는 계속 변하기 때문에 앙래와 같은 형태로 접근해야 한다.
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        //document에 image 폴더
        let folderPath =  documentDirectory.appendingPathComponent("timediray_image")
        
        //2. 이미지 파일 이름
        //Desktop/jack/ios/folder/222.png
        let imageURL = folderPath.appendingPathComponent(imageName)
        
        //4. 이미지 저장: 동일한 경로에 이미지를 저장하게 될 경우, 덮어쓰기
        //4-1. 이미지 경로 여부 확인 (이미 존재한다면 어떻게 할지)
        
        if FileManager.default.fileExists(atPath: imageURL.path) {
            //4-2. 기존 경로에 있는 이미지 삭제
            do {
                try FileManager.default.removeItem(at: imageURL)
                print("이미지 삭제 완료")
            } catch {
                print("이미지 삭제 실패")
            }
        }
        
    }
}

extension UserDiaryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksTag.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DiaryTagTableViewCell.identifier, for: indexPath) as? DiaryTagTableViewCell else {
            return UITableViewCell()
        }
        
        if indexPath.row == 0 {
            //전체 cell
            cell.tagLabel.text = NSLocalizedString("all", comment: "전체")
            cell.tagLabel.font = UIFont().kotra_songeulssi_13
            cell.contentNumLabel.text = ""
        } else {
            let row = tasksTag[indexPath.row - 1]
            
            cell.tagLabel.text = row.tag
            cell.tagLabel.font = UIFont().kotra_songeulssi_13
            
            cell.contentNumLabel.text = "\(row.contentNum)"
            cell.contentNumLabel.font = UIFont().kotra_songeulssi_13
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        //테이블뷰 선택되면 화면전환
        let st = UIStoryboard(name: "UserTagAlbum", bundle: nil)
        if let vc = st.instantiateViewController(withIdentifier: UserTagAlbumViewController.identifier) as? UserTagAlbumViewController {
            
            if indexPath.row == 0 {
                vc.selectedTag = "All"
            } else {
                vc.selectedTag = self.tasksTag[indexPath.row - 1].tag
                vc.tagData = self.tasksTag[indexPath.row - 1]
            }
            
            vc.modalPresentationStyle = .fullScreen
                
            //navigation bar를 포함하여 다음 뷰 컨트롤러로 화면전환 - push
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row <= 1 {
            return false
        } else {
            return true
        }
    }
    
    //오른쪽 스와이프 - 폴더 삭제 기능
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .normal, title: "delete") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            
            let alert = UIAlertController(title: NSLocalizedString("alert", comment: "폴더 삭제 확인"), message: NSLocalizedString("deleteFolderMessage", comment: "폴더 삭제 확인"), preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: "네"), style: .default) {
                (action) in
                
                let tasks = self.localRealm.objects(UserDiary.self).filter("tag = '\(self.tasksTag[indexPath.row - 1].tag)'")
                print(tasks)
                //기기에 저장된 이미지 삭제
                if tasks.count != 0 {
                    for i in 0...tasks.count - 1 {
                        print(tasks[i]._id)
                        self.deleteImageFromDocumentDirectory(imageName: "\(tasks[i]._id).png")
                    }
                }
                
                //Realm에서 삭제
                try! self.localRealm.write {
                    self.localRealm.delete(self.tasksTag[indexPath.row - 1])
                    self.localRealm.delete(tasks)
                    
                    tableView.reloadData()
                }
            }
            let cancelAction = UIAlertAction(title: NSLocalizedString("cancle", comment: "취소"), style: .default, handler: nil)
            
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: false, completion: nil)

            success(true)
        }
        delete.image = UIImage(systemName: "trash.fill")
        delete.backgroundColor = UIColor(named: "MemoRed")
        
        return UISwipeActionsConfiguration(actions:[delete])
    }

}
