//
//  CharacterLabel.swift
//  CharacterText
//
//  Created by Andrew Hulsizer on 7/4/14.
//  Copyright (c) 2014 Swift Yeti. All rights reserved.
//

import UIKit
import QuartzCore
import CoreText

class CharacterLabel: UILabel, NSLayoutManagerDelegate {
    
    let textStorage = NSTextStorage(string: " ");
    let textContainer = NSTextContainer();
    let layoutManager = NSLayoutManager();
    var oldCharacterTextLayers = Array<CATextLayer>()
    var characterTextLayers = Array<CATextLayer>()
    
    override var lineBreakMode: NSLineBreakMode {
        get {
            return super.lineBreakMode
        }
        
        set {
            textContainer.lineBreakMode = newValue
            super.lineBreakMode = newValue
        }
        
    }
    
    override var numberOfLines: Int {
        get {
            return super.numberOfLines
        }
        
        set {
            textContainer.maximumNumberOfLines = newValue
            super.numberOfLines = newValue
        }
        
    }
    
    override var bounds: CGRect {
        get {
            return super.bounds
        }
        
        set {
            textContainer.size = newValue.size
            super.bounds = newValue
        }
        
    }
    
    override var text: String! {
        get {
            return super.text
        }
        
        set {
            let wordRange = NSMakeRange(0, newValue.characters.count)
            let attributedText = NSMutableAttributedString(string: newValue)
            attributedText.addAttribute(NSForegroundColorAttributeName , value:self.textColor, range:wordRange)
            attributedText.addAttribute(NSFontAttributeName , value:self.font, range:wordRange)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = self.textAlignment
            attributedText.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range: wordRange)
            
            self.attributedText = attributedText
        }
        
    }
    
    override var attributedText: NSAttributedString? {
        get {
            return super.attributedText
        }
        
        set {
            
            if textStorage.string == newValue!.string {
                return
            }
            
            cleanOutOldCharacterTextLayers()
            oldCharacterTextLayers = Array<CATextLayer>(characterTextLayers)
            textStorage.setAttributedString(newValue!)
        }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayoutManager()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayoutManager()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayoutManager()
    }
    
    func setupLayoutManager() {
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        textContainer.size = bounds.size
        textContainer.maximumNumberOfLines = numberOfLines
        textContainer.lineBreakMode = lineBreakMode
        layoutManager.delegate = self
    }
    
    func layoutManager(layoutManager: NSLayoutManager, didCompleteLayoutForTextContainer textContainer: NSTextContainer?, atEnd layoutFinishedFlag: Bool) {
        calculateTextLayers()
    }
    
    func calculateTextLayers() {
        characterTextLayers.removeAll(keepCapacity: false)
        let attributedText = textStorage.string
        
        let wordRange = NSMakeRange(0, attributedText.characters.count);
        let attributedString = self.internalAttributedText();
        let layoutRect = layoutManager.usedRectForTextContainer(textContainer);
        
        var index = wordRange.location
        
        while index < wordRange.length + wordRange.location {
            let glyphRange = NSMakeRange(index, 1);
            let characterRange = layoutManager.characterRangeForGlyphRange(glyphRange, actualGlyphRange:nil);
            let textContainer = layoutManager.textContainerForGlyphAtIndex(index, effectiveRange: nil);
            var glyphRect = layoutManager.boundingRectForGlyphRange(glyphRange, inTextContainer: textContainer!);
            let location = layoutManager.locationForGlyphAtIndex(index);
            let kerningRange = layoutManager.rangeOfNominallySpacedGlyphsContainingIndex(index);
            
            if kerningRange.length > 1 && kerningRange.location == index {
                if characterTextLayers.count > 0 {
                    let previousLayer = characterTextLayers[characterTextLayers.endIndex-1]
                    var frame = previousLayer.frame
                    frame.size.width += CGRectGetMaxX(glyphRect)-CGRectGetMaxX(frame)
                    previousLayer.frame = frame
                }
            }
            
            
            glyphRect.origin.y += location.y-(glyphRect.height/2)+(self.bounds.size.height/2)-(layoutRect.size.height/2);
            
            
            let textLayer = CATextLayer(frame: glyphRect, string: attributedString.attributedSubstringFromRange(characterRange));
            initialTextLayerAttributes(textLayer)
            
            layer.addSublayer(textLayer);
            characterTextLayers.append(textLayer);
            
            index += characterRange.length;
        }
    }
    
    func initialTextLayerAttributes(textLayer: CATextLayer) {
        
    }
    
    func internalAttributedText() -> NSMutableAttributedString! {
        let wordRange = NSMakeRange(0, textStorage.string.characters.count);
        let attributedText = NSMutableAttributedString(string: textStorage.string);
        attributedText.addAttribute(NSForegroundColorAttributeName , value: self.textColor.CGColor, range:wordRange);
        attributedText.addAttribute(NSFontAttributeName , value: self.font, range:wordRange);

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = self.textAlignment
        attributedText.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range: wordRange)
        
        return attributedText;
    }
    
    func cleanOutOldCharacterTextLayers() {
        //Remove all text layers from the superview
        for textLayer in oldCharacterTextLayers {
            textLayer.removeFromSuperlayer();
        }
        //clean out the text layer
        oldCharacterTextLayers.removeAll(keepCapacity: false);
    }
}
