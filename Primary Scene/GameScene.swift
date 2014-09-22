//
//  GameScene.swift
//
//  Created by Adrian Simionescu on 04/09/14.
//

import Foundation
import Darwin

public enum GameState
{
    case GameStateUninitialized, GameStatePlaying, GameStatePaused, GameStateWon, GameStateLost
}

public enum ZOrder : Int
{
    case ZBackground = 0
    case ZBatchNode = 1
    case ZLabels = 2
    case ZHUD = 3
}

class GameScene : CCScene
{
    var hunter : Hunter!;
    //var bird : Bird!;
    var birdsCount = 0;
    var batchNode : CCSpriteBatchNode!;
    var timeUntilNextBird : Float!;
    var birds : Array<Bird>!;
    var arrows : Array<CCSprite>!;
    var gameState : GameState;
    
    var birdsToSpawn : Int;
    var birdsToLose : Int;
    
    var maxAimingRadius : Int;
    var aimingIndicator : CCSprite!;
    
    var hud : HUDLayer!;
    
    var gameStats : GameStats!;
    
    override init()
    {
     
        self.gameState = GameState.GameStateUninitialized;
        self.birdsToSpawn = 10;
        self.birdsToLose = 1;
        self.maxAimingRadius = 0;
        super.init()
        userInteractionEnabled = true
        self.timeUntilNextBird = 0;
        self.birds = Array<Bird>();
        self.arrows = Array<CCSprite>();
        
        self.createBatchNode();
        
        self.addBackground();
        self.addHunter();
        self.setupAimingIndicator();
        self.initializeHUD();
        self.initializeStats();
        //self.addBird();
        
        
    }
    
    func initializeHUD()
    {
        self.hud = HUDLayer();
        self.addChild(self.hud, z: ZOrder.ZHUD.toRaw());
    }
    
    func initializeStats()
    {
        self.gameStats = GameStats();
        self.gameStats.birdsLeft = self.birdsToSpawn;
        self.gameStats.lives = self.birdsToLose;
        
        self.hud.updateStats(self.gameStats);
    }
    
    func setupAimingIndicator()
    {
        self.maxAimingRadius = 100;
        
        self.aimingIndicator = CCSprite.spriteWithImageNamed("power_meter.png") as CCSprite;
        self.aimingIndicator.opacity = 0.3;
        self.aimingIndicator.anchorPoint = CGPointMake(0, 0.5);
        self.aimingIndicator.visible = false;
        
        self.batchNode.addChild(aimingIndicator);
    }
    
    override func onEnter()
    {
        super.onEnter();
        self.gameState = GameState.GameStatePlaying;
    }
    
    override func onExit()
    {
        // always call super onExit last
        super.onExit()
    }
    
    func checkWonLost()
    {
        if(self.birdsToLose <= 0)
        {
            self.lost();
            
        } else if( self.birdsToSpawn <= 0 && self.birds.count <= 0)
        {
            self.won();
        }
    }
    
    func lost()
    {
        self.gameState = GameState.GameStateLost;
        println("YOU LOST!");
        self.displayWinLoseLabelWithText("You lose!", fontFileName: "lost.fnt");
    }
    
    func won()
    {
        self.gameState = GameState.GameStateWon;
        println("YOU WON!");
        self.displayWinLoseLabelWithText("You win!", fontFileName: "win.fnt");
    }
    
    func displayWinLoseLabelWithText(text : String, fontFileName : String)
    {
        var viewSize = CCDirector.sharedDirector().viewSize();
        var label : CCLabelBMFont = CCLabelBMFont.labelWithString(text, fntFile: fontFileName) as CCLabelBMFont;
        
        label.position = CGPointMake(viewSize.width * 0.5, viewSize.height * 0.75);
        
        self.addChild(label, z: ZOrder.ZLabels.toRaw());
        label.scale = 0.01;
        
        var scaleUp : CCActionScaleTo = CCActionScaleTo.actionWithDuration(1.5, scale: 1.2) as CCActionScaleTo;
        var easedScaleUp : CCActionEaseIn = CCActionEaseIn.actionWithAction(scaleUp, rate: 5.0) as CCActionEaseIn;
        var scaleNormal : CCActionScaleTo = CCActionScaleTo.actionWithDuration(0.5, scale: 1.0) as CCActionScaleTo;
        var actions = Array<CCAction>();
        actions.append(easedScaleUp);
        actions.append(scaleNormal);
        var scaleUpThenNormal : CCActionSequence = CCActionSequence.actionWithArray(actions) as CCActionSequence;
        
        label.runAction(scaleUpThenNormal);
    }
    
    override func update(delta: CCTime) {
        var viewSize = CCDirector.sharedDirector().viewSize();
        
        // Single bird logic
        /*if(self.bird.position.x < 0)
        {
            self.bird.flipX = true;
        }
        
        if(self.bird.position.x > viewSize.width )
        {
            self.bird.flipX = false;
        }
        
        var birdSpeed : Float = 50;
        var distanceToMove : Float = birdSpeed * Float(delta);
        
        var direction : Float = bird.flipX ? 1 : -1;
        
        var newX = Float(bird.position.x) + direction * distanceToMove;
        var newY = viewSize.height * 0.9 + 10 * sin(bird.position.x / 20);
        
        bird.position = CGPointMake(CGFloat(newX), CGFloat(newY));*/
        
        if(self.gameState != GameState.GameStatePlaying)
        {
            return;
        }
        
        self.timeUntilNextBird! -= Float(delta);
        
        if(self.timeUntilNextBird <= 0 && self.birdsToSpawn > 0)
        {
            self.spawnBird();
            self.birdsToSpawn--;
            
            var nextBirdTimeMax : Int = 3;
            var nextBirdTimeMin : Int = 1;
            var nextBirdTime : Int  = nextBirdTimeMin + Int(arc4random_uniform(UInt32(nextBirdTimeMax - nextBirdTimeMin)));
            
            self.timeUntilNextBird! =  Float(nextBirdTime);
            
            self.gameStats.birdsLeft = self.birdsToSpawn;
            self.hud.updateStats(self.gameStats);
        }
        
        
        var viewBounds : CGRect = CGRectMake(0, 0, viewSize.width, viewSize.height);
        
        for(var i = self.birds.count - 1; i >= 0; i--)
        {
            var bird : Bird = self.birds[i];
            
            var birdFlewOffScreen : Bool = (bird.position.x + (bird.contentSize.width * 0.5)) > viewSize.width;
            
            if (bird.birdState == BirdState.BirdStateFlyingOut && birdFlewOffScreen)
            {
                self.birdsToLose--;
                
                self.gameStats.lives = self.birdsToLose;
                self.hud.updateStats(self.gameStats);
                
                self.birds.removeAtIndex(i);
                bird.removeBird(false);
                
                continue;
            }
            
            for (var j = self.arrows.count - 1; j >= 0; j--)
            {
                var arrow : CCSprite = self.arrows[j];
                
                if(!CGRectContainsPoint(viewBounds, arrow.position))
                {
                    arrow.removeFromParentAndCleanup(true);
                    self.arrows.removeAtIndex(j);
                    
                    continue;
                }
                
                if(CGRectIntersectsRect(arrow.boundingBox(), bird.boundingBox()))
                {
                    arrow.removeFromParentAndCleanup(true);
                    self.arrows.removeAtIndex(j);
                    
                    
                    
                    self.birds.removeAtIndex(i);
                    var score : Int = bird.removeBird(true);
                    self.gameStats.score += score;
                    self.hud.updateStats(self.gameStats);
                    
                    break;
                }
            }
        }
        
        self.checkWonLost();
    }
    
    func spawnBird()
    {
        var viewSize : CGSize = CCDirector.sharedDirector().viewSize();
        var maxY : Int = Int(viewSize.width * CGFloat(0.9));
        var minY : Int = Int(viewSize.height * CGFloat(0.6));
        var birdY : Int = minY + Int(arc4random_uniform(UInt32(maxY - minY)));
        var birdX : Int = Int(viewSize.width * CGFloat(1.3));
        var birdStart : CGPoint = CGPointMake(CGFloat(birdX), CGFloat(birdY));
        
        var birdType : BirdType;
        switch(arc4random_uniform(3))
            {
        case 0:
            birdType = BirdType.BirdTypeBig;
        case 1:
            birdType = BirdType.BirdTypeMedium;
        case 2:
            birdType = BirdType.BirdTypeSmall;
        default:
            birdType = BirdType.BirdTypeMedium;
        }
        
        var bird : Bird = Bird(birdType: birdType);
        bird.position = birdStart;
        
        self.batchNode.addChild(bird);
        bird.animateFly();
        
        self.birds.append(bird);
        
        var maxTime : Int = 6;
        var minTime : Int = 4;
        var birdTime : Int = minTime + (Int(arc4random()) % (maxTime - minTime));
        var screenLeft = CGPointMake(0, CGFloat(birdY));
        
        var moveToLeftEdge : CCActionMoveTo = CCActionMoveTo(duration: CCTime(birdTime), position: screenLeft);
        //var turnaround : CCActionFlipX = CCActionFlipX(flipX: true);
        let mySelectorTurnAround: Selector = "turnAround";
        var turnArround : CCActionCallFunc = CCActionCallFunc.actionWithTarget(bird, selector: mySelectorTurnAround) as CCActionCallFunc;
        var moveBackOffScreen : CCActionMoveTo = CCActionMoveTo(duration: CCTime(birdTime), position: birdStart);
        var birdActions = Array<CCAction>();
        birdActions.append(moveToLeftEdge);
        birdActions.append(turnArround);
        birdActions.append(moveBackOffScreen);
        birdActions.append(turnArround);
        var moveLeftThenBack : CCActionSequence = CCActionSequence.actionWithArray(birdActions) as CCActionSequence;
        
        var flyForever : CCActionRepeatForever = CCActionRepeatForever.actionWithAction(moveLeftThenBack) as CCActionRepeatForever;
        
        bird.runAction(flyForever);
        
    }
    
    func addBackground()
    {
        var viewSize = CCDirector.sharedDirector().viewSize();
        var background = CCSprite(imageNamed: "game_scene_bg-hd.png");
        background.position = CGPointMake(viewSize.width * 0.5, viewSize.height * 0.5);
        self.addChild(background, z: ZOrder.ZBackground.toRaw());
    }
    
    func addHunter()
    {
        self.hunter = Hunter();
        var viewSize = CCDirector.sharedDirector().viewSize();
        var hunterPositionX = viewSize.width * 0.5 - 250;
        var hunterPositionY = viewSize.height * 0.3;
        self.hunter.position = CGPointMake(hunterPositionX, hunterPositionY);
        self.batchNode.addChild(self.hunter);
    }
    
    /*func addBird()
    {
        var viewSize = CCDirector.sharedDirector().viewSize();
        self.bird = Bird(birdType: BirdType.BirdTypeBig);
        self.bird.position = CGPointMake(viewSize.width*0.8, viewSize.height*0.9);
        self.batchNode.addChild(self.bird);
        self.bird.animateFly();
    }*/
    
    func createBatchNode()
    {
        // New in Cocos 3.1
        CCSpriteFrameCache.sharedSpriteFrameCache().addSpriteFramesWithFile("Cocohunt.plist", textureFilename: "Cocohunt.png");
        /*var sharedSpriteFrameCache = CCSpriteFrameCache();
        sharedSpriteFrameCache.addSpriteFramesWithFile("Cocohunt.plist", textureFilename: "Cocohunt.png");*/
        
        self.batchNode = CCSpriteBatchNode(file: "Cocohunt.png", capacity: 32);
        
        
        self.addChild(self.batchNode, z: ZOrder.ZBatchNode.toRaw());
    }
    
    override func touchBegan(touch: UITouch!, withEvent event: UIEvent!)
    {
        if (self.hunter.hunterState != HunterState.HunterStateIdle || self.gameState != GameState.GameStatePlaying)
        {
            super.touchBegan(touch, withEvent: event);
            return;
        }
        var touchLocation : CGPoint = touch.locationInNode(self);
        
        self.hunter.aimAtPoint(touchLocation);
        
        self.aimingIndicator.visible = true;
        self.checkAimingIndicatorForPoint(touchLocation);
        
        var x = touch.locationInWorld().x;
        var y = touch.locationInWorld().y;
        var msg = String(format: "finger down at : %f %f", Float(x), Float(y));
        //String(format: "finger down at : (%f)", CGPoint(touch.locationInWorld).x);
        println(msg);
    }
    
    override func touchMoved(touch: UITouch!, withEvent event: UIEvent!) {
        var touchLocation : CGPoint = touch.locationInNode(self);
        self.hunter.aimAtPoint(touchLocation);
        
        self.checkAimingIndicatorForPoint(touchLocation);
        
        var x = touch.locationInWorld().x;
        var y = touch.locationInWorld().y;
        var msg = String(format: "finger moving at : %f %f", Float(x), Float(y));
        //String(format: "finger down at : (%f)", CGPoint(touch.locationInWorld).x);
        println(msg);
    }
    
    override func touchEnded(touch: UITouch!, withEvent event: UIEvent!) {
        if (self.gameState != GameState.GameStatePlaying)
        {
           return;
        }
        
        var touchLocation : CGPoint = touch.locationInNode(self);
        
        var canShoot : Bool = self.checkAimingIndicatorForPoint(touchLocation);
        
        if(canShoot == true)
        {
            var arrow : CCSprite = self.hunter.shootAtPoint(touchLocation);
            self.arrows.append(arrow);
        } else
        {
            self.hunter.getReadyToShootAgain()
        }
        
        self.aimingIndicator.visible = false;
        
        /*
        var arrow : CCSprite = self.hunter.shootAtPoint(touchLocation);
        self.arrows.append(arrow);
        self.hunter.getReadyToShootAgain();*/
        
        var x = touch.locationInWorld().x;
        var y = touch.locationInWorld().y;
        var msg = String(format: "finger ended at : %f %f", Float(x), Float(y));
        //String(format: "finger down at : (%f)", CGPoint(touch.locationInWorld).x);
        println(msg);
    }
    
    override func touchCancelled(touch: UITouch!, withEvent event: UIEvent!) {
        var x = touch.locationInWorld().x;
        var y = touch.locationInWorld().y;
        var msg = String(format: "finger canceled at : %f %f", Float(x), Float(y));
        //String(format: "finger down at : (%f)", CGPoint(touch.locationInWorld).x);
        println(msg);
    }
    
    deinit
    {
        // clean up code goes here
    }
    
    
    func checkAimingIndicatorForPoint(point : CGPoint) -> Bool
    {
        self.aimingIndicator.position = self.hunter.torsoCenterInWorldCoordinates();
        self.aimingIndicator.rotation = self.hunter.torsoRotation();
        
        var distance : Float = Float(CGPoint.Distance(self.aimingIndicator.position, v2: point));
        var isInRange : Bool;
        if(distance < Float(self.maxAimingRadius))
        {
            isInRange = true;
        } else
        {
            isInRange = false;
        }
        
        var scale : Float = distance / Float(self.aimingIndicator.contentSize.width);
        
        self.aimingIndicator.scale = scale;
        
        self.aimingIndicator.color = isInRange ? CCColor.greenColor() as CCColor : CCColor.redColor() as CCColor;
        
        return isInRange;
    }
   
    
}