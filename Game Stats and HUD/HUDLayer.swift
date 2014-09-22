//
//  HUDLayer.swift
//
//  Created by Adrian Simionescu on 17/09/14.
//

import Foundation

let kFontName = "Noteworthy-Bold"
let kFontSize = 14

class HUDLayer : CCNode
{
    var score : CCLabelTTF!;
    var birdsLeft : CCLabelTTF!;
    var lives : CCLabelTTF!;
    
    override init()
    {
        super.init();
        
        self.score = CCLabelTTF.labelWithString("Score: 99999", fontName: kFontName, fontSize: CGFloat(kFontSize)) as CCLabelTTF;
        self.birdsLeft = CCLabelTTF.labelWithString("Birds Left: 99", fontName: kFontName, fontSize: CGFloat(kFontSize)) as CCLabelTTF;
        self.lives = CCLabelTTF.labelWithString("Lives: 99", fontName: kFontName, fontSize: CGFloat(kFontSize)) as CCLabelTTF;
        
        
        
        self.score.color = CCColor.purpleColor() as CCColor;
        self.birdsLeft.color = CCColor.purpleColor() as CCColor;
        self.lives.color = CCColor.purpleColor() as CCColor;
        
        var viewSize : CGSize = CCDirector.sharedDirector().viewSize();
        var labelsY : Float = Float(viewSize.height * 0.95);
        var labelsPaddingX : Float = Float(viewSize.width * 0.3);
        
        self.score.anchorPoint = CGPointMake(0, 0.5);
        self.score.position = CGPointMake(CGFloat(labelsPaddingX), CGFloat(labelsY));
        
        self.birdsLeft.anchorPoint = CGPointMake(0.5, 0.5);
        self.birdsLeft.position = CGPointMake(viewSize.width * 0.5, CGFloat(labelsY));
        
        self.lives.anchorPoint = CGPointMake(1, 0.5);
        self.lives.position = CGPointMake(viewSize.width - CGFloat(labelsPaddingX), CGFloat(labelsY));
        
        self.addChild(self.score);
        self.addChild(self.birdsLeft);
        self.addChild(self.lives);
    }
    
    func updateStats( stats: GameStats)
    {
        self.score.string = String(format: "Score: %d", stats.score);
        self.birdsLeft.string = String(format: "Birds Left: %d", stats.birdsLeft);
        self.lives.string = String(format: "Lives: %d", stats.lives);
    }
}
