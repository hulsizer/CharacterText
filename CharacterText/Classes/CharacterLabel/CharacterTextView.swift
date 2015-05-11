//
//  CharacterTextView.swift
//  CharacterText
//
//  Created by Andrew Hulsizer on 6/26/14.
//  Copyright (c) 2014 Swift Yeti. All rights reserved.
//

import UIKit
import QuartzCore
import CoreText

class CharacterTextView: UITextView, NSLayoutManagerDelegate {
    
    var oldCharacterTextLayers = Array<CALayer>()
    var characterTextLayers = Array<CALayer>()
    
    override var text: String! {
    get {
        return super.text
    }
    
    set {
        self.attributedText = NSAttributedString(string: newValue);
    }
    
    }
    
    override var attributedText: NSAttributedString! {
    get {
        return super.attributedText
    }
    
    set {
        cleanOutOldCharacterTextLayers();
        oldCharacterTextLayers = Array<CALayer>(characterTextLayers);
        var newAttributedText = NSMutableAttributedString(attributedString: newValue);
        newAttributedText.addAttribute(NSForegroundColorAttributeName, value:UIColor.clearColor(), range:NSMakeRange(0, newValue.length));
        super.attributedText = newAttributedText;
    }
    
    }
        
    override init(frame: CGRect, textContainer: NSTextContainer!) {
        super.init(frame: frame, textContainer: textContainer);
        setupLayoutManager();
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayoutManager()
    }
    
    override func awakeFromNib()  {
        super.awakeFromNib();
        setupLayoutManager();
    }
    
    func setupLayoutManager() {
        layoutManager.delegate = self;
    }
    
    func layoutManager(layoutManager: NSLayoutManager, didCompleteLayoutForTextContainer textContainer: NSTextContainer?, atEnd layoutFinishedFlag: Bool) {
        calculateTextLayers();
    }

    func calculateTextLayers() {
        
        let wordRange = NSMakeRange(0, self.attributedText.length);
        let attributedString = self.internalAttributedText();
        
        for var index = wordRange.location; index < wordRange.length+wordRange.location; index += 0 {
            let glyphRange = NSMakeRange(index, 1);
            let characterRange = layoutManager.characterRangeForGlyphRange(glyphRange, actualGlyphRange:nil);
            let textContainer = layoutManager.textContainerForGlyphAtIndex(index, effectiveRange: nil);
            var glyphRect = layoutManager.boundingRectForGlyphRange(glyphRange, inTextContainer: textContainer!);
            var location = layoutManager.locationForGlyphAtIndex(index);
            var kerningRange = layoutManager.rangeOfNominallySpacedGlyphsContainingIndex(index);
            
            if kerningRange.length > 1 && kerningRange.location == index {
                var previousLayer = self.characterTextLayers[self.characterTextLayers.endIndex]
                var frame = previousLayer.frame
                frame.size.width += (CGRectGetMaxX(glyphRect)+location.x)-CGRectGetMaxX(frame)
                previousLayer.frame = frame
            }

            
            glyphRect.origin.y += location.y-(glyphRect.height/2);
            var textLayer = CATextLayer(frame: glyphRect, string: attributedString.attributedSubstringFromRange(characterRange));
            
            layer.addSublayer(textLayer);
            characterTextLayers.append(textLayer);
            
            let stepGlyphRange = layoutManager.glyphRangeForCharacterRange(characterRange, actualCharacterRange:nil);
            index += stepGlyphRange.length;
        }
    }
    
    func internalAttributedText() -> NSMutableAttributedString! {
        let wordRange = NSMakeRange(0, self.attributedText.length);
        var attributedText = NSMutableAttributedString(string: self.text);
        attributedText.addAttribute(NSForegroundColorAttributeName , value:self.textColor.CGColor, range:wordRange);
        attributedText.addAttribute(NSFontAttributeName , value:self.font, range:wordRange);
        return attributedText;
    }
    
    func cleanOutOldCharacterTextLayers() {
        //Remove all text layers from the superview
        for textLayer in oldCharacterTextLayers {
            textLayer.removeFromSuperlayer();
        }
        //clean out the text layer
        characterTextLayers.removeAll(keepCapacity: false);
    }
}
