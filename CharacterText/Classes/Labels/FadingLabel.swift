//
//  FadingLabel.swift
//  CharacterText
//
//  Created by Andrew Hulsizer on 7/4/14.
//  Copyright (c) 2014 Swift Yeti. All rights reserved.
//

import UIKit
import QuartzCore
import CoreText

class FadingLabel: CharacterLabel {
    
    override var attributedText: NSAttributedString? {
    get {
        return super.attributedText
    }
    
    set {
        super.attributedText = newValue
        self.animateOut() { finished in
            self.animateIn(nil);
        }
    }
    
    }
    
    override func initialTextLayerAttributes(textLayer: CATextLayer) {
        textLayer.opacity = 0
    }
    
    func animateIn(completion: ((finished: Bool) -> Void)?) {
    
        for textLayer in characterTextLayers {
            
            let duration = (NSTimeInterval(arc4random()%100)/200.0)+0.25
            let delay = NSTimeInterval(arc4random()%100)/500.0
            
            CLMLayerAnimation.animation(textLayer, duration:duration, delay:delay, animations: {
                textLayer.opacity = 1;
            }, completion:nil)
            
        }
    }
    
    func animateOut(completion: ((finished: Bool) -> Void)? = nil) {
        
        var longestAnimation = 0.0
        var longestAnimationIndex = -1
        var index = 0
        
        for textLayer in oldCharacterTextLayers {
            
            let duration = (NSTimeInterval(arc4random()%100)/200.0)+0.25
            let delay = NSTimeInterval(arc4random()%100)/500.0
            
            if duration+delay > longestAnimation {
                longestAnimation = duration+delay
                longestAnimationIndex = index
            }
            CLMLayerAnimation.animation(textLayer, duration:duration, delay:delay, animations: {
                textLayer.opacity = 0;
                }, completion:{ finished in
                    textLayer.removeFromSuperlayer()
                    if textLayer == self.oldCharacterTextLayers[longestAnimationIndex] {
                        if let completionFunction = completion {
                            completionFunction(finished: finished)
                        }
                    }
                })
            
            index += 1
        }
    }
}
