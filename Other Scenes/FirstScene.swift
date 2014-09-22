//
//  FirstScene.swift
//
//  Created by Adrian Simionescu on 03/09/14.
//

import Foundation

public class FirstScene : CCScene
{
    override init()
    {
        super.init()
        
        // Create a colored background (Dark Grey)
        var earth = CCSprite(imageNamed: "earth.png");
        var winSize = CCDirector.sharedDirector().viewSize();
        earth.position = CGPointMake(winSize.width / 2.0, winSize.height / 2.0);
        self.addChild(earth);
        
        var welcome = CCLabelTTF(string: "Welcome!", fontName: "Helvetica", fontSize: 32);
        welcome.position = CGPointMake(winSize.width  / 3.0, winSize.height * 0.9);
        
        self.addChild(welcome);
        
        
    }
    
    
}