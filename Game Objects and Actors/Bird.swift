//
//  Bird.swift
//
//  Created by Adrian Simionescu on 05/09/14.
//

import Foundation

public enum BirdType
{
    case BirdTypeBig, BirdTypeMedium, BirdTypeSmall
    
}

public enum BirdState
{
    case BirdStateFlyingIn, BirdStateFlyingOut, BirdStateFlewOut, BirdStateDead
}

public class Bird : CCSprite
{
    var birdType : BirdType;
    var birdState : BirdState;
    var timesToVisit : Int;
    
    init(birdType : BirdType) {
        
        
        self.birdType = birdType;
        self.birdState = BirdState.BirdStateFlyingIn;
        self.timesToVisit = 1;
        
        var birdImageName : String;
        switch birdType
            {
                case .BirdTypeBig:
                    birdImageName = "bird_big_0.png";
            
        case .BirdTypeMedium:
            birdImageName = "bird_middle_0.png";
            
        case .BirdTypeSmall:
            birdImageName = "bird_small_0.png";
            
        default:
            birdImageName = "bird_small_0.png";
            
        }
        
        
        super.init(imageNamed: birdImageName);
        //animateFly();
    }
    
    func animateFly()
    {
        var animFrameNameFormat : String;
        
        
        switch self.birdType
            {
        case .BirdTypeBig:
            //String(format: "The current time is %02d:%02d", 10, 4)
            animFrameNameFormat = "bird_big_%d.png";
            
        case .BirdTypeMedium:
            animFrameNameFormat = "bird_middle_%d.png";
            
        case .BirdTypeSmall:
            animFrameNameFormat = "bird_small_%d.png";
            
        default:
            animFrameNameFormat = "bird_small_%d.png";
            
        }
        
        var animFrames = [CCSpriteFrame]();
        
        for (var i = 0; i < 7 ; i++)
        {
            var currentFrameName = String(format: animFrameNameFormat, i);
            
            
            //var animationFrame = CCSpriteFrame(textureFilename: currentFrameName, rectInPixels: CGRectNull, rotated: false, offset: CGPointZero, originalSize: CGSizeZero);
            
            var animationFrame = CCSpriteFrameCache.sharedSpriteFrameCache().spriteFrameByName(currentFrameName);
            animFrames.append(animationFrame);
        }
        
        var flyAnimation = CCAnimation(spriteFrames: animFrames, delay: Float(0.1));
        
        var flyAnimateAction = CCActionAnimate(animation: flyAnimation);
        
        var flyForever = CCActionRepeatForever(action: flyAnimateAction);
        
        self.runAction(flyForever);
        
        
        
    }
    
    func animateFall()
    {
        var fallDownOffScreenPoint : CGPoint = CGPointMake(self.position.x, -self.boundingBox().size.height);
        var fallOffScreen : CCActionMoveTo = CCActionMoveTo.actionWithDuration(2.0, position: fallDownOffScreenPoint) as CCActionMoveTo;
        
        var removeWhenDone : CCActionRemove = CCActionRemove.action() as CCActionRemove;
        
        var actions = Array<CCAction>();
        actions.append(fallOffScreen);
        actions.append(removeWhenDone);
        var fallSequence : CCActionSequence = CCActionSequence.actionWithArray(actions) as CCActionSequence;
        
        self.runAction(fallSequence);
        
        var rotate : CCActionRotateBy = CCActionRotateBy.actionWithDuration(0.1, angle: 60) as CCActionRotateBy;
        
        var rotateForever : CCActionRepeatForever = CCActionRepeatForever.actionWithAction(rotate) as CCActionRepeatForever;
        
        self.runAction(rotateForever);
    }
    
    func turnAround()
    {
        self.flipX = !self.flipX;
        
        if(self.flipX == true)
        {
            self.timesToVisit--;
        }
        
        if(self.timesToVisit <= 0)
        {
            self.birdState = BirdState.BirdStateFlyingOut;
        }
        
    }
    
    func explodeFeathers()
    {
        var totalNumbersOfFeathers : UInt = 100;
        
        var explosion : CCParticleSystem = CCParticleSystem.particleWithTotalParticles(totalNumbersOfFeathers) as CCParticleSystem;
        
        explosion.position = self.position;
        
        explosion.emitterMode = CCParticleSystemMode.Gravity;
        
        explosion.duration = 0.1;
        
        explosion.emissionRate = Float(Float(totalNumbersOfFeathers) / explosion.duration);
        
        explosion.texture = CCTexture(file: "feather.png");
        
        explosion.startColor = CCColor.whiteColor() as CCColor;
        
        explosion.endColor = CCColor.whiteColor().colorWithAlphaComponent(0.0) as CCColor;
        
        explosion.life = 0.25;
        explosion.lifeVar = 0.75;
        explosion.speed = 60;
        explosion.speedVar = 80;
        
        explosion.startSize = 16;
        explosion.startSizeVar = 4;
        explosion.endSize = Float(CCParticleSystemStartSizeEqualToEndSize);
        explosion.endSizeVar = 8;
        
        explosion.angleVar = 360;
        explosion.startSpinVar = 360;
        explosion.endSpinVar = 360;
        
        explosion.autoRemoveOnFinish = true;
        
        var blendFunc : ccBlendFunc = ccBlendFunc(src: GLenum(GL_SRC_ALPHA), dst: GLenum(GL_ONE));
        
        explosion.blendFunc = blendFunc;
        
        var batchNode : CCNode = self.parent;
        var scene : CCNode = batchNode.parent;
        scene.addChild(explosion);
    }
    
    func removeBird( hitByArrow : Bool) -> Int
    {
        
        self.stopAllActions();
        
        var score : Int = 0;
        if (hitByArrow)
        {
            self.birdState = BirdState.BirdStateDead;
            score = (self.timesToVisit + 1) * 5;
            
            self.displayPoints(score);
            
            self.animateFall();
            
            self.explodeFeathers();
        }
        else {
            self.birdState = BirdState.BirdStateFlewOut;
            self.removeFromParentAndCleanup(true);
        }
        
        
        return(score);
    }
    
    func displayPoints(amount : Int)
    {
        var ptsStr : String = String(format: "%d", amount);
        var ptsLabel : CCLabelBMFont = CCLabelBMFont.labelWithString(ptsStr, fntFile: "points.fnt") as CCLabelBMFont;
        ptsLabel.position = self.position;
        
        var batchNode : CCNode = self.parent;
        var scene : CCNode = batchNode.parent;
        scene.addChild(ptsLabel);
        
        var xDelta1 : Float = 10;
        var yDelta1 : Float = 5;
        var yDelta2 : Float = 10;
        var yDelta4 : Float = 20;
        var curve : ccBezierConfig = ccBezierConfig(endPosition: CGPointMake(0, 0), controlPoint_1: CGPointMake(0, 0), controlPoint_2: CGPointMake(0, 0));
        curve.controlPoint_1 = CGPointMake(ptsLabel.position.x - CGFloat(xDelta1), ptsLabel.position.y + CGFloat(yDelta1));
        curve.controlPoint_2 = CGPointMake(ptsLabel.position.x + CGFloat(xDelta1), ptsLabel.position.y + CGFloat(yDelta2));
        curve.endPosition = CGPointMake(ptsLabel.position.x, ptsLabel.position.y + CGFloat(yDelta4));
        
        var baseDuration : Float = 1.0;
        
        var bezierMove : CCActionBezierTo = CCActionBezierTo.actionWithDuration(CCTime(baseDuration), bezier: curve) as CCActionBezierTo;
        
        var fadeOut : CCActionFadeOut = CCActionFadeOut.actionWithDuration(CCTime(baseDuration) * 0.25) as CCActionFadeOut;
        
        var delay : CCActionDelay = CCActionDelay.actionWithDuration(CCTime(baseDuration) * 0.75) as CCActionDelay;
        
        var actions = Array<CCAction>();
        actions.append(delay);
        actions.append(fadeOut);
        var delayAndFade : CCActionSequence = CCActionSequence.actionWithArray(actions) as CCActionSequence;
        
        
        var actions2 = Array<CCAction>();
        actions2.append(bezierMove);
        actions2.append(delayAndFade);
        var bezieAndFadeOut : CCActionSpawn = CCActionSpawn.actionWithArray(actions2) as CCActionSpawn;
        
        var removeInTheEnd : CCActionRemove = CCActionRemove.action() as CCActionRemove;
        
        var actions3 = Array<CCAction>();
        actions3.append(bezieAndFadeOut);
        actions3.append(removeInTheEnd);
        var mainAction : CCActionSequence = CCActionSequence.actionWithArray(actions3) as CCActionSequence;
        
        ptsLabel.runAction(mainAction);
    }
    
    
    /*

        //2
    NSMutableArray *animFrames =
    [NSMutableArray arrayWithCapacity:7];
    //3
    for (int i = 0; i < 7 ; i++)
    {
    //4
    NSString *currentFrameName  =
    [NSString stringWithFormat:animFrameNameFormat, i];
    //5
    [ 105 ]
    
    Rendering Sprites
    //6
    [animFrames addObject:animationFrame];
    }
    //7
    CCAnimation* flyAnimation =
    [CCAnimation animationWithSpriteFrames:animFrames
    delay:0.1f];
    //8
    CCActionAnimate *flyAnimateAction =
    [CCActionAnimate actionWithAnimation:flyAnimation];
    //9
    CCActionRepeatForever *flyForever =
    [CCActionRepeatForever actionWithAction:flyAnimateAction];
    //10
    [self runAction:flyForever];
    }

*/
    
    override init() {
        self.birdType = BirdType.BirdTypeBig;
        self.birdState = BirdState.BirdStateFlyingIn;
        self.timesToVisit = 3;
        
        super.init();
    }
    
    override init(texture: CCTexture!, rect: CGRect, rotated: Bool) {
        self.birdType = BirdType.BirdTypeBig;
            self.birdState = BirdState.BirdStateFlyingIn;
            self.timesToVisit = 3;
        super.init(texture: texture, rect: rect, rotated: rotated);
    }
    
    override init(spriteFrame: CCSpriteFrame!) {
        self.birdType = BirdType.BirdTypeBig;
            self.birdState = BirdState.BirdStateFlyingIn;
            self.timesToVisit = 3;
        super.init(spriteFrame: spriteFrame);
    }
    
    override init(texture: CCTexture!, rect: CGRect) {
        self.birdType = BirdType.BirdTypeBig;
            self.birdState = BirdState.BirdStateFlyingIn;
            self.timesToVisit = 3;
        super.init(texture: texture, rect: rect);
    }
    
    
}