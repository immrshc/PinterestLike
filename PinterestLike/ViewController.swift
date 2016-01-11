//
//  ViewController.swift
//  PinterestLike
//
//  Created by 今村翔一 on 2016/01/10.
//  Copyright © 2016年 今村翔一. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, TimeLineLayoutDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var postArray = [
        UIImage(named: "Image01.jpg")!,
        UIImage(named: "Image02.jpg")!,
        UIImage(named: "Image03.jpg")!,
        UIImage(named: "Image05.jpg")!,
        UIImage(named: "Image06.jpg")!
    ]
    var postImage:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("①番目に実行される")
        //Pinterestのプロトコルを後で実装する
        if let layout = collectionView?.collectionViewLayout as? TimeLineLayout {
            layout.delegate = self
        }
        
        let nib = UINib(nibName: "TimeLineHeader", bundle: nil)
        collectionView.registerNib(nib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "TimeLineHeader")
        //以下はMain.storyboardで関連づけている
        //collectionView.delegate = self
        //collectionView.dataSource = self
        collectionView.reloadData()
        
    }
    
    //セル数の指定
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.postArray.count
    }
    
    //セルの生成
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TimeLineCollectionViewCell", forIndexPath: indexPath) as! TimeLineCollectionViewCell
        cell.postIV.image = postArray[indexPath.row]
        cell.postTextLabel.text = "This is test for Cell, ajusting padding."
        return cell
        
    }
    
    //セクション数の指定
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //ヘッダーをXibファイルから生成
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        print("④番目に実行される")
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "TimeLineHeader", forIndexPath: indexPath) as! HeaderReusableView
        headerView.userNameLabel.text = "This is test for header."
        return headerView
        
    }
    
    //アスペクト比に応じた写真の高さを取得して、セルの写真の高さにする
    func collectionView(collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath: NSIndexPath,
        withWidth width: CGFloat) -> CGFloat {
            print("③番目に実行される")
            let image = postArray[indexPath.row]
            self.postImage = image
            let boundingRect =  CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
            //calculate a height that retains the photo’s aspect ratio, restricted to the cell’s width
            let rect  = AVMakeRectWithAspectRatioInsideRect(postImage!.size, boundingRect)
            return rect.size.height
    }
    
    //投稿文の長さに応じて写真以外のセルの高さを調整する
    func collectionView(collectionView: UICollectionView,
        heightForAnnotationAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat {
            //Storyboard上で写真の上、下、ラベルの下にそれぞれ余白が5ずつある
            let annotationPadding = CGFloat(5) * 3
            //フォントとサイズは、Storyboard上の文字と同じにする
            let font = UIFont(name: "Times New Roman", size: 17)!
            let rect = NSString(string: "This is test for Cell, ajusting padding.").boundingRectWithSize(CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
            let commentHeight = ceil(rect.height)
            let height = commentHeight + annotationPadding
            //print(height)
            return height
    }
    
}
