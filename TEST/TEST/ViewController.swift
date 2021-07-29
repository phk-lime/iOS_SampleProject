//
//  ViewController.swift
//  TEST
//
//  Created by haanwave on 2021/07/29.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    var keyword = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = LeftAlignedCollectionViewFlowLayout()
        collectionView.layer.borderWidth = 1
        collectionView.layer.borderColor = UIColor.red.cgColor
        
        keyword = ["안녕하세요","세요","안녕녕","안녕하세요","세요","안녕녕","안녕하세요","세요","안녕녕","안녕하세요","세요","안녕녕","안녕하세요","세요","안녕녕","안녕하세요","세요","안녕녕"]
        collectionView.reloadData()
        print(collectionView.contentSize.height)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        collectionViewHeight.constant = collectionView.contentSize.height
        collectionView.reloadData()
        print(collectionView.contentSize.height)
    }
    
    @IBAction func addKeyword(_ sender: Any) {
        
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return keyword.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BestKeywordsCell.identifier,
                                                            for: indexPath) as? BestKeywordsCell else { return UICollectionViewCell() }
        cell.configure(keyword: keyword[indexPath.item])
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return BestKeywordsCell.fittingSize(availableHeight: 30, keyword: keyword[indexPath.item])
    }
}

// MARK: - 키워드 태그 왼쪽 정렬위한 FlowLayout
class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    let cellSpacing: CGFloat = 10
 
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        self.minimumLineSpacing = 10.0
        self.sectionInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        let attributes = super.layoutAttributesForElements(in: rect)
 
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }
            layoutAttribute.frame.origin.x = leftMargin
            leftMargin += layoutAttribute.frame.width + cellSpacing
            maxY = max(layoutAttribute.frame.maxY, maxY)
        }
        return attributes
    }
}

// MARK: - cell
class BestKeywordsCell: UICollectionViewCell {
    
    static let identifier = "BestKeywordsCell"
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.init(red: 100/255, green: 100/255, blue: 100/255, alpha: 1)
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 13)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 5
    }
    
    private func setupUI() {
        backgroundColor = UIColor.init(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 7, left: 10, bottom: 7, right: 10))
        }
    }
    
    static func fittingSize(availableHeight: CGFloat, keyword: String) -> CGSize {
        let cell = BestKeywordsCell()
        cell.configure(keyword: keyword)
        
        let targetSize = CGSize(width: UIView.layoutFittingCompressedSize.width,
                                height: availableHeight)
        return cell.contentView.systemLayoutSizeFitting(targetSize,
                                                        withHorizontalFittingPriority: .fittingSizeLevel,
                                                        verticalFittingPriority: .required)
    }
    
    func configure(keyword: String) {
        titleLabel.text = keyword
    }
}
