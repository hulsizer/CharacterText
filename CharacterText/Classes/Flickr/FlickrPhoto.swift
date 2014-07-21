//
//  FlickrPhoto.swift
//  CharacterText
//
//  Created by Andrew Hulsizer on 7/6/14.
//  Copyright (c) 2014 Swift Yeti. All rights reserved.
//

import Foundation

class FlickrPhoto: NSObject {
    var photoURL: NSURL
    var title: String
    
    init(photoURL: NSURL, title: String) {
        self.photoURL = photoURL
        self.title = title
        super.init()
    }
}
