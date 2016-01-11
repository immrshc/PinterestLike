//
//  TimeLineLayout.swift
//  PinterestLike
//
//  Created by 今村翔一 on 2016/01/10.
//  Copyright © 2016年 今村翔一. All rights reserved.
//

import UIKit

protocol TimeLineLayoutDelegate {
    
    func collectionView(collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:NSIndexPath,
        withWidth:CGFloat) -> CGFloat
    
    func collectionView(collectionView: UICollectionView,
        heightForAnnotationAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat
    
}

class TimeLineLayoutAttributes: UICollectionViewLayoutAttributes {
    
    var photoHeight:CGFloat = 0.0
    
    //photoHeightを更新するために以下が必要になる
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = super.copyWithZone(zone) as! TimeLineLayoutAttributes
        copy.photoHeight = photoHeight
        return copy
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let attributes = object as? TimeLineLayoutAttributes {
            if attributes.photoHeight == photoHeight {
                return super.isEqual(object)
            }
        }
        return false
    }

}

class TimeLineLayout: UICollectionViewLayout {
    
    var delegate: TimeLineLayoutDelegate!
    var _layoutAttributes = Dictionary<String, TimeLineLayoutAttributes>()
    var numberOfColumns = 2 //列の数
    var cellPadding:CGFloat = 5.0 //セルの余白
    var contentHeight:CGFloat = 80.0
    var contentWidth:CGFloat {
        let insets = collectionView!.contentInset
        return CGRectGetWidth(collectionView!.bounds) - (insets.left + insets.right)
    }
    
    // MARK: -
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        print("②番目に実行される")
        _layoutAttributes = Dictionary<String, TimeLineLayoutAttributes>() // 1
        let path = NSIndexPath(forItem: 0, inSection: 0)
        let attributes = TimeLineLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withIndexPath: path)
        
        let headerHeight = CGFloat(130)
        attributes.frame = CGRectMake(0, 0, self.collectionView!.frame.size.width, headerHeight)
        
        let headerKey = layoutKeyForHeaderAtIndexPath(path)
        _layoutAttributes[headerKey] = attributes
        let numberOfSections = self.collectionView!.numberOfSections()
        
        
        for var section = 0; section < numberOfSections; section++ {
            
            let numberOfItems = self.collectionView!.numberOfItemsInSection(section)
            let columnWidth = contentWidth / CGFloat(numberOfColumns)
            var xOffset = [CGFloat]()
            var yOffset = [CGFloat](count: numberOfColumns, repeatedValue: headerHeight)
            for column in 0 ..< numberOfColumns {
                xOffset.append(CGFloat(column) * columnWidth )//それぞれの列ごとの始めのx座標の位置
            }
            var column = 0
            
            for var item = 0; item < numberOfItems; item++ {
                
                let indexPath = NSIndexPath(forItem: item, inSection: section)
                let width = columnWidth - cellPadding * 2
                let photoHeight = delegate.collectionView(collectionView!, heightForPhotoAtIndexPath: indexPath, withWidth: width)
                let annotationHeight = delegate.collectionView(collectionView!,
                    heightForAnnotationAtIndexPath: indexPath, withWidth: width)
                let height = cellPadding +  photoHeight + annotationHeight + cellPadding
                let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
                let insetFrame = CGRectInset(frame, cellPadding, cellPadding)
                let attributes = TimeLineLayoutAttributes(forCellWithIndexPath: indexPath)
                attributes.photoHeight = photoHeight
                attributes.frame = insetFrame
                let key = layoutKeyForIndexPath(indexPath)
                _layoutAttributes[key] = attributes
                
                contentHeight = max(contentHeight, CGRectGetMaxY(frame))
                yOffset[column] = yOffset[column] + height
                
                column = column >= (numberOfColumns - 1) ? 0 : ++column
            }
            
        }
        
    }
    
    // MARK: -
    // MARK: Helpers
    
    func layoutKeyForIndexPath(indexPath : NSIndexPath) -> String {
        return "\(indexPath.section)_\(indexPath.row)"
    }
    
    func layoutKeyForHeaderAtIndexPath(indexPath : NSIndexPath) -> String {
        return "s_\(indexPath.section)_\(indexPath.row)"
    }
    
    // MARK:
    // MARK: Invalidate
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return !CGSizeEqualToSize(newBounds.size, self.collectionView!.frame.size)
    }
    
    // MARK: -
    // MARK: Required methods
    
    //セルの領域のサイズを返す
    override func collectionViewContentSize() -> CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    //ヘッダーのレイアウトの属性を返す
    //これがないとヘッダー領域が割り当てられないので、ViewControllerでヘッダーが生成されない
    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        
        let headerKey = layoutKeyForIndexPath(indexPath)
        return _layoutAttributes[headerKey]
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        
        let key = layoutKeyForIndexPath(indexPath)
        return _layoutAttributes[key]
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let predicate = NSPredicate {  [unowned self] (evaluatedObject, bindings) -> Bool in
            let layoutAttribute = self._layoutAttributes[evaluatedObject as! String]
            return CGRectIntersectsRect(rect, layoutAttribute!.frame)
        }
        
        let dict = _layoutAttributes as NSDictionary
        let keys = dict.allKeys as NSArray
        let matchingKeys = keys.filteredArrayUsingPredicate(predicate)
        
        return dict.objectsForKeys(matchingKeys, notFoundMarker: NSNull()) as? [TimeLineLayoutAttributes]
    }
    
}
