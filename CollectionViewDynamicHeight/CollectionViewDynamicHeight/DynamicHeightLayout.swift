//
//  DynamicHeightLayout.swift
//  CollectionViewDynamicHeight
//
//  Created by limefriends on 2021/06/04.
//

import UIKit

// 이미지 사이즈에 따라 셀의 높이가 달라지는 경우가 많기 때문에 셀에 들어가는 이미지 사이즈를 받아오는 delegate를 만든다
protocol DynaminHeightLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat
}

class DynamicHeightLayout: UICollectionViewLayout {
    
    weak var delegate: DynaminHeightLayoutDelegate?
    
    private let numberOfColumns = 2 // 셀을 몇줄로 표현할까(세로)
    private let cellPadding: CGFloat = 6
    
    private var cache = [UICollectionViewLayoutAttributes]() // 리턴할 Attribute를 모아놓은 배열
    
    // 셀 높이는 사진에 의해 변경될 것
    private var contentsHeight: CGFloat = 0.0
    // 너비는 collectionView 자체 사이즈에서 좌우 insets 값을 뺀 크기로 정한다
    private var contentsWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    // 높이, 너비 리턴
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentsWidth, height: contentsHeight)
    }
    
    // MARK: - prepare
    override func prepare() {
        // 1)cache는 비어있어야 한다 2)collectionView가 존재해야 한다
        guard cache.isEmpty,
              let collectionView = collectionView else { return }
        
        // xOffset에 x좌표 설정
        // columnWidth로 하나의 셀 너비를 정하고 좌표를 계산해 x좌표 배열에 넣는다
        let columnWidth = contentsWidth / CGFloat(numberOfColumns)
        var xOffset = [CGFloat]()
        for column in 0..<numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        
        // yOffset은 0으로 초기화(시작은 0포인트이기 때문에)
        // 이후 yOffset은 컨텐츠가 들어간 column의 사이즈를 기준으로 계산
        var column = 0
        var yOffset: [CGFloat] = .init(repeating: 0, count: numberOfColumns)
        
        // 섹션의 모든 아이템에 대한 정의
        // 지금은 섹션이 1개라서 -> inSection: 0
        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            // indexPath 지정
            let indexPath = IndexPath(item: item, section: 0)
            
            // 1)프레임을 정한다
            // 2)delegate를 사용해 사진의 높이를 받아온다
            // 3)패딩값 + 사진의 높이값으로 셀의 높이를 지정
            let photoHeight = delegate?.collectionView(collectionView, heightForPhotoAtIndexPath: indexPath) ?? 180
            let height = cellPadding * 2 + photoHeight
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            // frame에 대한 attribute를 만든다
            let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attribute.frame = insetFrame
            cache.append(attribute)
            
            // 1) contentsHeight를 지정한다
            // 2) y좌표 시작점을 만든다 -> 바로 윗 열의 y좌표 + height
            contentsHeight = max(contentsHeight, frame.maxX)
            yOffset[column] = yOffset[column] + height
            
            // 다음 column 지정
            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        }
    }
    
    // MARK: - layoutAttributesForElements
    // prepare 다음에 불리는 사각형에 어떤 것이 보이는지 결정
    // attribute를 임의로 만들었기 때문에 화면에 보이는 부분만 드릴 수 있도록 반환 (교차하는 것)
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
        for attribute in cache { // 교차하면 true
            if attribute.frame.intersects(rect) {
                visibleLayoutAttributes.append(attribute)
            }
        }
        return visibleLayoutAttributes
    }
    
    // MARK: - layoutAttributesForItem
    // 각 indexPath에 맞춰 cache 반환
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
}
