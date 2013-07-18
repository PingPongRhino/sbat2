/* Copyright (c) 2011 Cody Sandel
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

//
// includes
//
#import "LaserEndParticle.h"
#import "LaserEndEmitter.h"
#import "CubicBezierControlPoint.h"
#import "StageScene.h"
#import "SpriteFrameManager.h"

//
// static globals
//
static const ccTime _activeInterval = 0.033333f; // _laserEndParticleCount * (1/60), in other words we always want
                                                 // a particle covering the target at every frame.
static const float _velocity = 100.0f;

//
// @implementation LaserEnd
//
@implementation LaserEndParticle

//
// synthesize
//
@synthesize _laserEndEmitter;
@synthesize _active;
@synthesize _timer;

//
//
//
+ (id)laserEndParticleWithLaserEndEmitter:(LaserEndEmitter *)laserEndEmitter {
    LaserEndParticle *laserEndParticle = [[LaserEndParticle alloc] initWithLaserEndEmitter:laserEndEmitter];
    return [laserEndParticle autorelease];
}

//
//
//
- (id)initWithLaserEndEmitter:(LaserEndEmitter *)laserEndEmitter {
    self = [super initWithSpriteFrame:[SpriteFrameManager laserEndParticleSpriteFrameWithColorState:kColorStateDefault]];
    
    // init properties
    self._laserEndEmitter = laserEndEmitter;
    self._active = false;
    self._timer = 0.0f;
    
    self.visible = false;
    
    return self;
}

//
//
//
- (int)activateWithColorState:(ColorState)colorState {
    
    // if already active, then bail
    if (_active) {
        return 1;
    }
        
    // activate and add to scene
    _active = true;
    self.visible = true;
    
    CCSpriteBatchNode *spriteBatchNode = [[StageScene sharedStageScene] spriteBatchNodeWithIndex:SPRITEBATCHNODE_INDEX_PLAYFIELD_02];
    if (self.parent != spriteBatchNode) {
        [spriteBatchNode addChild:self z:ZORDER_LASER_END];
    }
    
    // set our color
    [self setDisplayFrame:[SpriteFrameManager laserEndParticleSpriteFrameWithColorState:colorState]];
    
    // reset timer
    _timer = 0.0f;
    
    // set position
    self.position = [_laserEndEmitter controlPointToTrack]._position;
    
    return 0;
}

//
//
//
- (void)deactivateAndCleanupWithObject:(NSNumber *)cleanup {
    [self deactivateAndCleanup:[cleanup boolValue]];
}

//
//
//
- (int)deactivateAndCleanup:(bool)cleanup {
    
    // if already inactive, then bail
    if (!_active) {
        return 1;
    }
    
    // deactivate and remove from scene
    _active = false;
    self.visible = false;
    
    if (cleanup) {
        [self removeFromParentAndCleanup:false];
    }
    
    // tell parent we are deactivating
    [_laserEndEmitter deactivateLaserEndParticle:self];
    
    return 0;
}

//
//
//
- (void)update:(NSNumber *)elapsedTime {
    
    if (!_active) {
        return;
    }
    
    _timer += [elapsedTime floatValue];
    if (_timer >= _activeInterval) {
        [self deactivateAndCleanup:false];
        return;
    }
    
    // try to home in on the current target
    float delta = _velocity * [elapsedTime floatValue];
    CGPoint direction = ccpNormalize(ccpSub([_laserEndEmitter controlPointToTrack]._position, self.position));
    self.position = ccpAdd(self.position, ccpMult(direction, delta));
    
    // pick a random direction
    self.rotation = arc4random() % 360;
}

//
//
//
- (void)dealloc {
    self._laserEndEmitter = nil;
    [super dealloc];
}

@end
