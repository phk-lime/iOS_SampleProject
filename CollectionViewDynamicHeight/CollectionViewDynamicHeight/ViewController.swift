//
//  ViewController.swift
//  CollectionViewDynamicHeight
//
//  Created by limefriends on 2021/06/04.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var photos = ["1", "3", "4", "2"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let customLayout = DynamicHeightLayout()
        customLayout.delegate = self
        collectionView.collectionViewLayout = customLayout
        collectionView.dataSource = self
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as? MyCell else {
            return UICollectionViewCell()
        }
        
        cell.layer.backgroundColor = UIColor.lightGray.cgColor
        cell.imageView.image = UIImage(named: self.photos[indexPath.item])
        cell.layer.cornerRadius = 12
        cell.layer.masksToBounds = true
        return cell
    }
}

extension ViewController: DynaminHeightLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        let photo: UIImage?
        let photoNumber = self.photos[indexPath.item]
        photo = UIImage(named: photoNumber)
        return photo?.size.height ?? 0
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
}

// MARK: - cell
class MyCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
}
