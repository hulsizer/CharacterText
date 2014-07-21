//
//  CATextLayerExtensions.swift
//  CharacterText
//
//  Created by Andrew Hulsizer on 6/26/14.
//  Copyright (c) 2014 Swift Yeti. All rights reserved.
//

import QuartzCore
import UIKit

extension CATextLayer {
    convenience init(frame: CGRect, string: NSAttributedString) {
        self.init();
        self.contentsScale = UIScreen.mainScreen().scale;
        self.frame = frame;
        self.string = string;
    }
}