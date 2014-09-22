//
//  Main.swift
//
//  Created by Adrian Simionescu on 24/06/14.
//

import Foundation

@UIApplicationMain class AppDelegate : CCAppDelegate, UIApplicationDelegate {



    override func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]!) -> Bool    {
        setupCocos2dWithOptions([CCSetupShowDebugStats: true])
        
        return true
    }
    
    override func startScene() -> (CCScene)
    {
        return GameScene()
    }
}
