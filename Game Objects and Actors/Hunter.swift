//
//  Hunter.swift
//
//  Created by Adrian Simionescu on 05/09/14.
//

import Foundation

public enum HunterState
{
    case HunterStateIdle, HunterStateAiming, HunterStateReloading
}

public class Hunter : CCSprite
{
    var torso : CCSprite?;
    var hunterState : HunterState;
    
    override init() {
        
        self.hunterState = HunterState.HunterStateIdle;
        super.init(imageNamed: "hunter_bottom.png");
        self.torso = CCSprite(imageNamed: "hunter_top_0.png");
        self.torso!.anchorPoint = CGPointMake( 0.5,10/44);
        self.torso!.position = CGPointMake(self.boundingBox().size.width/2, self.boundingBox().size.height);
        self.addChild(torso, z: -1);
        
        
    }
    
    func torsoRotation() -> Float
    {
        return self.torso!.rotation;
    }
    
    func torsoCenterInWorldCoordinates() -> CGPoint
    {
        var torsoCenterLocal : CGPoint;
        torsoCenterLocal = CGPointMake(self.torso!.contentSize.width / 2.0, self.torso!.contentSize.height / 2.0);
        
        var torsoCenterWorld : CGPoint;
        torsoCenterWorld = self.torso!.convertToWorldSpace(torsoCenterLocal);
        
        return torsoCenterWorld;
    }
    
    
    func calculateTorsoRotationToLookAtPoint(targetPoint : CGPoint) -> Float
    {
        var torsoCenterWorld : CGPoint;
        torsoCenterWorld = self.torsoCenterInWorldCoordinates();
        
        var pointStraightAhead : CGPoint;
        pointStraightAhead = CGPointMake(torsoCenterWorld.x + 1.0, torsoCenterWorld.y);
        
        var forwardVector : CGPoint;
        forwardVector = CGPoint.Sub(pointStraightAhead, v2: torsoCenterWorld);
        
        var targetVector : CGPoint;
        targetVector = CGPoint.Sub(targetPoint, v2: torsoCenterWorld);
        
        var angleRadians : Float;
        angleRadians = CGPoint.AngleSigned(forwardVector, b: targetVector);
        
        var angleDegrees : Float;
        angleDegrees = -1 * angleRadians * MathGlobals.RADIANS_TO_DEGREES;
        
        angleDegrees = clampf(angleDegrees, -60, 25);
        
        return angleDegrees;
    }
    
    func aimAtPoint(point : CGPoint)
    {
        self.torso!.rotation = calculateTorsoRotationToLookAtPoint(point);
    }
    
    func shootAtPoint(point : CGPoint) -> CCSprite
    {
        self.aimAtPoint(point);
        
        var arrow : CCSprite = CCSprite(imageNamed: "arrow.png");
        
        arrow.anchorPoint = CGPointMake(0, 0.5);
        
        var torsoCenterGlobal : CGPoint = self.torsoCenterInWorldCoordinates();
        arrow.position = torsoCenterGlobal;
        arrow.rotation = self.torso!.rotation;
        
        self.parent.addChild(arrow);
        
        var viewSize : CGSize = CCDirector.sharedDirector().viewSize();
        var forwardVector : CGPoint = CGPointMake(1.0, 0);
        
        var angleRadians : Float = -1 * MathGlobals.RADIANS_TO_DEGREES * self.torso!.rotation;
        var arrowMovementVector : CGPoint = CGPoint.RotateByAngle(forwardVector, pivot: CGPointZero, angle: angleRadians);
        arrowMovementVector = CGPoint.Normalize(arrowMovementVector);
        arrowMovementVector = CGPoint.Mult(arrowMovementVector, s: viewSize.width * 2.0);
        
        var moveAction : CCActionMoveBy = CCActionMoveBy(duration: 2.0, position: arrowMovementVector);
        arrow.runAction(moveAction);
        
        self.reloadArrow();
        
        return arrow;
    }
    
    func getReadyToShootAgain()
    {
        self.hunterState = HunterState.HunterStateIdle;
        
    }
    
    func reloadArrow()
    {
        self.hunterState = HunterState.HunterStateReloading;
        
        var frameNameFormat : String = "hunter_top_%d.png";
        var frames = Array<CCSpriteFrame>();
        
        for (var i : Int = 0; i < 6; i++)
        {
            var frameName : String = String(format: frameNameFormat, i);
            var frame : CCSpriteFrame = CCSpriteFrame.frameWithImageNamed(frameName) as CCSpriteFrame;
            frames.append(frame);
        }
        
        var reloadAnimation : CCAnimation = CCAnimation.animationWithSpriteFrames(frames, delay: 0.5) as CCAnimation;
        
        reloadAnimation.restoreOriginalFrame = true;
        var reloadAnimAction : CCActionAnimate = CCActionAnimate.actionWithAnimation(reloadAnimation) as CCActionAnimate;
        
        let mySelectorGetReadyToShootAgain: Selector = "getReadyToShootAgain";
        var readyToShootAgain : CCActionCallFunc = CCActionCallFunc.actionWithTarget(self, selector: mySelectorGetReadyToShootAgain) as CCActionCallFunc;
        
        var delay : CCActionDelay = CCActionDelay.actionWithDuration(0.25) as CCActionDelay;
        
        var actions = Array<CCAction>();
        actions.append(reloadAnimAction);
        actions.append(delay);
        actions.append(readyToShootAgain);
        var reloadAndGetReady : CCActionSequence = CCActionSequence.actionWithArray(actions) as CCActionSequence;
        
        self.torso!.runAction(reloadAndGetReady);
        
    }
    
    override init(texture: CCTexture!, rect: CGRect, rotated: Bool) {
        self.torso = CCSprite();
        self.hunterState = HunterState.HunterStateIdle;
        super.init(texture: texture, rect: rect, rotated: rotated);
    }
    
    override init(spriteFrame: CCSpriteFrame!) {
        self.torso = CCSprite();
        self.hunterState = HunterState.HunterStateIdle;
        super.init(spriteFrame: spriteFrame);
    }
    
    override init(texture: CCTexture!, rect: CGRect) {
        self.torso = CCSprite();
        self.hunterState = HunterState.HunterStateIdle;
        super.init(texture: texture, rect: rect);
    }
    
    
}