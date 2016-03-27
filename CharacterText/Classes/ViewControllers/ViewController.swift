//
//  ViewController.swift
//  CharacterText
//
//  Created by Andrew Hulsizer on 6/26/14.
//  Copyright (c) 2014 Swift Yeti. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    var dataArray = Array<FlickrPhoto>()
    var characterLabel: MotionLabel!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupCharacterLabel()
    }
    
    func setupCollectionView() {
        //Get Flickr Data
        FlickrKit.sharedFlickrKit().initializeWithAPIKey("334626934a41897193b6a0613f1c94a0", sharedSecret: "b0132e5cfd44574b")
        let flickrKit = FlickrKit.sharedFlickrKit()
        flickrKit.call(FKFlickrInterestingnessGetList()) { response, error in
            if (response != nil) {
                var photoUrls = Array<FlickrPhoto>()
                let photos: NSDictionary = response["photos"] as! NSDictionary;
                let photoArray: NSArray = photos["photo"] as! NSArray;
                //Get Photos
                for photoData : AnyObject in photoArray {
                    let photoDict: NSDictionary = photoData as! NSDictionary
                    let url = flickrKit.photoURLForSize(FKPhotoSizeMedium800, fromPhotoDictionary: photoDict as [NSObject : AnyObject])
                    let newPhoto = FlickrPhoto(photoURL: url, title: photoDict["title"] as! String)
                    photoUrls.append(newPhoto)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.dataArray = Array<FlickrPhoto>(photoUrls);
                    self.collectionView.reloadData()
                    })
            }
        }
        collectionView.registerClass(FlickrCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "FlickrCollectionViewCell")
    }
    
    func setupCharacterLabel() {
        characterLabel = MotionLabel(frame: CGRectInset(self.view.bounds, 0, 200));
        characterLabel.textAlignment = NSTextAlignment.Center
        characterLabel.textColor = UIColor.whiteColor()
        characterLabel.text = "You"
        self.view.addSubview(characterLabel)
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let collectionViewCell : FlickrCollectionViewCell! = collectionView.dequeueReusableCellWithReuseIdentifier("FlickrCollectionViewCell", forIndexPath: indexPath) as! FlickrCollectionViewCell
        
        collectionViewCell.configure(dataArray[indexPath.row])
        return collectionViewCell
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let page: Int = Int(scrollView.contentOffset.x/CGRectGetWidth(self.view.bounds))
        let photo = dataArray[page];
        characterLabel.text = photo.title
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView!, delecerate: Bool) {
        if !delecerate {
            let page: Int = Int(scrollView.contentOffset.x/CGRectGetWidth(self.view.bounds))
            let photo = dataArray[page];
            characterLabel.text = photo.title
        }
    }

}

