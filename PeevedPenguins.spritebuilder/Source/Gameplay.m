//
//  Gameplay.m
//  PeevedPenguins
//
//  Created by Nathan Lintz on 4/22/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"
#import "Penguin.h"
#import "Level.h"
#import "Seal.h"

@implementation Gameplay
{
    NSInteger _currentLevelIndex;
    NSArray * _levels;
    Level *_currentLevel;
    CCScene *level;
    NSMutableArray *_penguins;
    
    CCPhysicsNode *_physicsNode;
    CCNode *_catapultArm;
    CCNode *_levelNode;
    CCNode *_catapult;
    CCNode *_contentNode;
    CCNode *_pullbackNode;
    CCNode *_mouseJointNode;
    Penguin *_currentPenguin;
    
    CCPhysicsJoint *_catapultJoint;
    CCPhysicsJoint *_pullbackJoint;
    CCPhysicsJoint *_mouseJoint;
    CCPhysicsJoint *_penguinCatapultJoint;
    
    CCAction *_followPenguin;
}

static const int NUM_LEVELS = 3;
static const float MIN_SPEED = 5.f;

-(void) didLoadFromCCB {
    self.userInteractionEnabled = TRUE;
    
    _currentLevelIndex = 0;
    _levels = [self getLevels];
    _currentLevel = [_levels objectAtIndex:_currentLevelIndex];
    
    level = [CCBReader loadAsScene:[NSString stringWithFormat:@"Levels/%@", [_currentLevel levelName]]];
    [_levelNode addChild:level];
    [_currentLevel addObserver:self forKeyPath:@"numSeals" options:0 context:NULL];
    
    _penguins = [[NSMutableArray alloc] init];
    
    _physicsNode.debugDraw = TRUE;
    _physicsNode.collisionDelegate = self;
    
    
    [_catapultArm.physicsBody setCollisionGroup:_catapult];
    [_catapult.physicsBody setCollisionGroup:_catapult];
    
    _catapultJoint = [CCPhysicsJoint connectedPivotJointWithBodyA:_catapultArm.physicsBody bodyB:_catapult.physicsBody anchorA:_catapultArm.anchorPointInPoints];
    
    _pullbackNode.physicsBody.collisionMask = @[];
    _mouseJointNode.physicsBody.collisionMask = @[];
    
    _pullbackJoint = [CCPhysicsJoint connectedSpringJointWithBodyA:_pullbackNode.physicsBody bodyB:_catapultArm.physicsBody anchorA:ccp(0, 0) anchorB:ccp(34, 138) restLength:60.0f stiffness:500.0f damping:40.0f];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"numSeals"]) {
        if (_currentLevel.numSeals == 0) {
            [self nextLevel];
        }
    }
}

- (void)nextLevel {
    [_levelNode removeChild:level];
    
    _currentLevelIndex = (_currentLevelIndex + 1) % NUM_LEVELS;
    _currentLevel = [_levels objectAtIndex:_currentLevelIndex];
    level = [CCBReader loadAsScene:[NSString stringWithFormat:@"Levels/%@", [_currentLevel levelName]]];
    for (Penguin *penguin in _penguins) {
        [_physicsNode removeChild:penguin];
    }
    _penguins = [[NSMutableArray alloc] init];
    [self nextAttempt];
    [_levelNode addChild:level];
    [_currentLevel addObserver:self forKeyPath:@"numSeals" options:0 context:NULL];
}

- (void)update:(CCTime)delta {
    if (_currentPenguin.launched) {
        if (ccpLength(_currentPenguin.physicsBody.velocity) < MIN_SPEED) {
            [self nextAttempt];
            return;
        }
    
        int xMin = _currentPenguin.boundingBox.origin.x;
    
        if (xMin < self.boundingBox.origin.x) {
            [self nextAttempt];
            return;
        }
    
        int xMax = xMin + _currentPenguin.boundingBox.size.width;
    
        if (xMax > (self.boundingBox.origin.x + self.boundingBox.size.width)) {
            [self nextAttempt];
            return;
        }
    }
}

- (NSArray *)getLevels {
    Level *level1 = [[Level alloc] initWithLevelName:@"Level1" numSeals:5];
    Level *level2 = [[Level alloc] initWithLevelName:@"Level2" numSeals:8];
    Level *level3 = [[Level alloc] initWithLevelName:@"Level3" numSeals:5];
    return @[level1, level2, level3];
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair seal:(CCNode *)nodeA wildcard:(CCNode *)nodeB {
    
    float energy = [pair totalKineticEnergy];
    
    if (energy > 5000.0f) {
        [self sealRemoved:nodeA];
        
    }
}

- (void)sealRemoved:(CCNode *)seal {
    if ([(Seal *)seal alive]) {
        Seal *currentSeal = (Seal *)seal;
        currentSeal.alive = NO;
        _currentLevel.numSeals -= 1;
    }
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"SealExplosion"];
    explosion.autoRemoveOnFinish = TRUE;
    explosion.position = seal.position;
    [seal.parent addChild:explosion];
    [seal removeFromParent];
}

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    
    if (CGRectContainsPoint([_catapultArm boundingBox], touchLocation))
    {
        _mouseJointNode.position = touchLocation;
        _mouseJoint = [CCPhysicsJoint connectedSpringJointWithBodyA:_mouseJointNode.physicsBody bodyB:_catapultArm.physicsBody anchorA:ccp(0, 0) anchorB:ccp(34, 138) restLength:0.f stiffness:3000.f damping:150.f];
        _currentPenguin = (Penguin *)[CCBReader load:@"Penguin"];
        [_penguins addObject:_currentPenguin];
        
        CGPoint penguinPosition = [_catapultArm convertToWorldSpace:ccp(34, 138)];
        _currentPenguin.position = [_physicsNode convertToNodeSpace:penguinPosition];
        [_physicsNode addChild:_currentPenguin];
        _currentPenguin.physicsBody.allowsRotation = FALSE;
        _penguinCatapultJoint = [CCPhysicsJoint connectedPivotJointWithBodyA:_currentPenguin.physicsBody bodyB:_catapultArm.physicsBody anchorA:_currentPenguin.anchorPointInPoints];
    }
}

-(void) touchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    _mouseJointNode.position = touchLocation;
}

-(void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    [self releaseCatapult];
}

-(void) touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    [self releaseCatapult];
}

-(void) releaseCatapult {
    if (_mouseJoint != nil) {
        [_mouseJoint invalidate];
        _mouseJoint = nil;
        
        [_penguinCatapultJoint invalidate];
        _penguinCatapultJoint = nil;
        _currentPenguin.physicsBody.allowsRotation = TRUE;
        _currentPenguin.launched = TRUE;
        _followPenguin = [CCActionFollow actionWithTarget:_currentPenguin worldBoundary:self.boundingBox];
        [_contentNode runAction:_followPenguin];
    }
}

- (void)nextAttempt {
    _currentPenguin = nil;
    [_contentNode stopAction:_followPenguin];
    
    CCActionMoveTo *actionMoveTo = [CCActionMoveTo actionWithDuration:1.0f position:ccp(0, 0)];
    [_contentNode runAction:actionMoveTo];
}

-(void) retry {
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"Gameplay"]];
}

@end
