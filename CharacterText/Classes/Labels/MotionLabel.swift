//
//  MotionLabel.swift
//  CharacterText
//
//  Created by Andrew Hulsizer on 7/7/14.
//  Copyright (c) 2014 Swift Yeti. All rights reserved.
//

import QuartzCore

class MotionLabel: CharacterLabel {
    
    var oldMatchingCharacters = Dictionary<Int, Int>()
    var newMatchingCharacters = Dictionary<Int, Int>()
    
    override var attributedText: NSAttributedString? {
    get {
        return super.attributedText
    }
    
    set {
        
        if textStorage.string == newValue!.string {
            return
        }
        
        super.attributedText = newValue;
        
        let matches = self.matchingCharacterRanges(newValue!.string)
        oldMatchingCharacters = matches.oldMatches
        newMatchingCharacters = matches.newMatches
        
        self.animateOut(nil);
        self.animateIn(nil);
    }
    
    }
    
    override func initialTextLayerAttributes(textLayer: CATextLayer) {
        textLayer.opacity = 0
    }
    
    func animateIn(completion: ((finished: Bool) -> Void)? = nil) {
        
        var index = 0
        for textLayer in characterTextLayers {
            
            if let _ = newMatchingCharacters[index] {
                textLayer.opacity = 0;
            }else{
                let scaleTransform = CATransform3DMakeScale(0.2, 0.2, 1)
                textLayer.transform = scaleTransform
                
                CLMLayerAnimation.animation(textLayer, duration:0.3, delay:NSTimeInterval(index)*0.01, animations: {
                    textLayer.transform = CATransform3DIdentity
                    textLayer.opacity = 1;
                    }, completion:nil)
                
            }
            
            index += 1;
        }
    }
    
    func animateOut(completion: ((finished: Bool) -> Void)? = nil) {
        
        let scaleTransform = CATransform3DMakeScale(0.2, 0.2, 1)
        
        var index = 0
        for textLayer in oldCharacterTextLayers {
            
            if let newMatchingIndex = oldMatchingCharacters[index] {
                let glyphIndex = layoutManager.glyphIndexForCharacterAtIndex(newMatchingIndex)
                let matchingLayer = characterTextLayers[glyphIndex]
                let startingTransform = CATransform3DMakeTranslation(matchingLayer.position.x-textLayer.position.x, matchingLayer.position.y-textLayer.position.y, 0)
                
                CLMLayerAnimation.animation(textLayer, duration:0.3, delay:0, animations: {
                    textLayer.transform = startingTransform
                    }, completion: { finished in
                        
                        CLMLayerAnimation.animation(matchingLayer, duration:0.01, delay:0, animations: {
                            matchingLayer.opacity = 1
                            }, completion: { finished in
                                textLayer.removeFromSuperlayer()
                            })
                        
                        if index == self.oldCharacterTextLayers.count-1 {
                            if let completionFunction = completion {
                                completionFunction(finished: finished)
                            }
                        }
                    })
                
            }else{
                textLayer.transform = CATransform3DIdentity
                
                CLMLayerAnimation.animation(textLayer, duration:0.3, delay:NSTimeInterval(index)*0.01, animations: {
                    textLayer.transform = scaleTransform
                    textLayer.opacity = 0;
                    }, completion: { finished in
                        
                        textLayer.removeFromSuperlayer()
                        
                        if index == self.oldCharacterTextLayers.count-1 {
                            if let completionFunction = completion {
                                completionFunction(finished: finished)
                            }
                        }
                    })
            }
            
            index += 1;
        }
    }
    
    func matchingCharacterRanges(newString: String) -> (oldMatches: Dictionary<Int, Int>, newMatches: Dictionary<Int, Int>) {
        var oldMatches = Dictionary<Int, Int>()
        var newMatches = Dictionary<Int, Int>()
        
        var outerIndex = 0
        var innerIndex = 0
        var startingInnerIndex = 0
        let buffer = 6
        let characterTextLayersEndIndex = characterTextLayers.count-1
        
        for characterLayer in oldCharacterTextLayers {
            if startingInnerIndex >= characterTextLayersEndIndex {
                break;
            }
            
            let character = characterLayer.string as! NSAttributedString
            for newCharacterLayer in characterTextLayers[startingInnerIndex...characterTextLayersEndIndex] {
                if innerIndex >= buffer {
                    break
                }
                
                let newCharacter = newCharacterLayer.string as! NSAttributedString
                if character.isEqualToAttributedString(newCharacter) {
                    oldMatches[outerIndex] = startingInnerIndex+innerIndex
                    newMatches[startingInnerIndex+innerIndex] = outerIndex
                    startingInnerIndex += innerIndex
                    break
                }
                innerIndex += 1
            }
            innerIndex = 0
            startingInnerIndex += 1
            outerIndex += 1
        }
        
        assert(oldMatches.count == newMatches.count, "Matches dont match", file: "NSStringExtension", line: 46)
        return (oldMatches, newMatches)
    }
}
