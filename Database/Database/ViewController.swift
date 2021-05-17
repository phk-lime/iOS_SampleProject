//
//  ViewController.swift
//  Database
//
//  Created by limefriends on 2021/05/06.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseUI

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var majorLabel: UILabel!
    
    let database = Database.database().reference().child("User-1")
    let storage = Storage.storage().reference().child("User-1")
    
    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageView.layer.cornerRadius = self.imageView.frame.height / 2
        self.imageView.layer.masksToBounds = true
        self.imageView.layer.borderWidth = 1
        self.imageView.layer.borderColor = UIColor.lightGray.cgColor
        self.imageView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.1)
        
        self.nameLabel.text = ""
        self.majorLabel.text = ""
        
        self.imagePicker.sourceType = .photoLibrary
        self.imagePicker.allowsEditing = true
        self.imagePicker.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAction))
        
        // database data retrive
        self.retriveData()
        self.retriveImage()
    }
    
    func uploadToDatabase(_ name: String, _ major: String) {
        //upload to database
        self.nameLabel.text = name
        self.majorLabel.text = major
        
        self.database.setValue(["name": name, "major": major])
    }
    
    @objc func addAction() {
        let ac = UIAlertController(title: "add user", message: nil, preferredStyle: .alert)
        ac.addTextField { nameField in
            nameField.placeholder = "이름"
        }
        ac.addTextField { majorField in
            majorField.placeholder = "전공"
        }
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak ac] action in
            guard let name = ac?.textFields?[0].text, !name.isEmpty else { return }
            guard let major = ac?.textFields?[1].text, !name.isEmpty else { return }
            self.uploadToDatabase(name, major)
        }))
        present(ac, animated: true)
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        self.database.removeValue()
        self.nameLabel.text = ""
        self.majorLabel.text = ""
    }
    
    func retriveData() {
//        self.database.getData { (error, snapshot) in
//            if let error = error {
//                print("--->Error getting data \(error)")
//            }
//            else if snapshot.exists() {
//
//                let value = snapshot.value as? NSDictionary
//                let name = value?["name"] as? String ?? ""
//                let major = value?["major"] as? String ?? ""
//                DispatchQueue.main.async {
//                    self.nameLabel.text = name
//                    self.majorLabel.text = major
//                }
//            }
//            else {
//                print("--->No data available")
//            }
//        }
        // MARK: - 관찰자를 사용하여 데이터 한 번 읽기
        // 이 방법은 한 번 로드된 후 자주 변경되지 않거나 능동적으로 수신 대기할 필요가 없는 데이터에 유용합니다.
        self.database.observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let name = value?["name"] as? String ?? ""
            let major = value?["major"] as? String ?? ""
            DispatchQueue.main.async {
                self.nameLabel.text = name
                self.majorLabel.text = major
            }
        }
    }
    
    @IBAction func updateName(_ sender: Any) {
        let ac = UIAlertController(title: "이름 수정", message: nil, preferredStyle: .alert)
        ac.addTextField { nameField in
            nameField.placeholder = "이름"
        }
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak ac] action in
            guard let name = ac?.textFields?[0].text, !name.isEmpty else { return }
            
            self.database.updateChildValues(["name": name])
        
            DispatchQueue.main.async {
                self.nameLabel.text = name
            }
        }))
        present(ac, animated: true)
    }
    
    @IBAction func updateMajor(_ sender: Any) {
        let ac = UIAlertController(title: "전공 수정", message: nil, preferredStyle: .alert)
        ac.addTextField { majorField in
            majorField.placeholder = "전공"
        }
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak ac] action in
            guard let major = ac?.textFields?[0].text, !major.isEmpty else { return }
            
            self.database.updateChildValues(["major": major])
            
            DispatchQueue.main.async {
                self.majorLabel.text = major
            }
        }))
        present(ac, animated: true)
    }
    
    @IBAction func photoUpload(_ sender: Any) {
        present(imagePicker, animated: true)
    }
    @IBAction func removeProfile(_ sender: Any) {
        self.removeProfileImage()
    }
    
    func removeProfileImage() {
        let ref = storage.child("profile/profile.jpg")
        ref.delete { (error) in
            if let error = error {
                print("--->DELETE ERROR:", error)
            } else {
                // 이미지 캐시 삭제
                let sdWebImageManager = SDWebImageManager.shared
                sdWebImageManager.imageCache.clear(with: .all) {
                    print("--->이미지 캐시 제거완료")
                }
                self.imageView.image = UIImage(systemName: "person.crop.circle")
                print("--->DELETE COMPLETE")
            }
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var newImage: UIImage?
        
        if let possibleImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            newImage = possibleImage // 이미지가 수정된 경우
        } else if let possibleImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            newImage = possibleImage // 이미지가 수정되지 않은 경우
        }
        
        picker.dismiss(animated: true, completion: nil)
        uploadImage(newImage!)
    }
    
    func uploadImage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 1) else { return }
        let ref = storage.child("profile/profile.jpg")
        
        ref.putData(imageData, metadata: nil) { (metaData, error) in
            if error != nil {
                print("--->Error:",error ?? "")
            }
            else {
                self.imageView.image = UIImage(data: imageData)
                // 이미지 캐시 삭제
                let sdWebImageManager = SDWebImageManager.shared
                sdWebImageManager.imageCache.clear(with: .all) {
                    print("--->이미지 캐시 제거완료")
                }
            }
        }
    }
    
    func retriveImage() {
        // // FirebaseUI, SDWebImage 사용해 이미지 다운로드
        let ref = storage.child("profile/profile.jpg")
        let imageView: UIImageView = self.imageView
        let placeholder = UIImage(systemName: "person.crop.circle")
        imageView.sd_setImage(with: ref, placeholderImage: placeholder)
        
//        // 메모리에 다운로드 -> getData(maxSize: , completion: )
//        // 로컬 파일로 다운로드 -> write(toFile: , completion: )
//        // 다운로드 url 생성-> downloadURL(completion: )
//        ref.downloadURL { (url, error) in
//            guard error == nil,
//                  let imageURL = url else {
//                print("--->ERROR ", error ?? "")
//                return
//            }
//            DispatchQueue.main.async {
//                let imageData = try? Data(contentsOf: imageURL)
//                self.imageView.image = UIImage(data: imageData!)
//            }
//        }
    }
}
