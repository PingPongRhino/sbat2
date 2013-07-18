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
#import "LaserStartParticle.h"
#import "LaserStartEmitter.h"
#import "CubicBezierControlPoint.h"
#import "FastAnimate.h"
#import "StageScene.h"
#import "SpriteFrameManager.h"

//
// static globals
//
static const int _frameCount = 6;
static const ccTime _activeInterval = 0.25f;
static const float _velocity = 150.0f;

//
// @implementation LaserStartParticle
//
@implementation LaserStartParticle

//
// synthesize
//
@synthesize _laserStartEmitter;
@synthesize _active;
@synthesize _animateWhite;
@synthesize _animateBlack;
@synthesize _timer;
@synthesize _direction;
@synthesize _distanceTraveled;

//
//
//
+ (id)laserStartParticleWithLaserStartEmitter:(LaserStartEmitter *)laserStartEmitter {
    LaserStartParticle *laserStartParticle = [[LaserStartParticle alloc] initWithLaserStartEmitter:laserStartEmitter];
    return [laserStartParticle autorelease];
}

//
//
//
- (id)initWithLaserStartEmitter:(LaserStartEmitter *)laserStartEmitter {
    self = [super initWithSpriteFrame:[SpriteFrameManager laserStartParticleSpriteFrameWithColorState:kColorStateDefault frameNumber:0]];
    
    // init properties
    self._laserStartEmitter = laserStartEmitter;
    self._active = false;
    self._animateWhite = [self createAnimationWithColorState:kColorStateWhite];
    self._animateBlack = [self createAnimationWithColorState:kColorStateBlack];
    self._timer = 0.0f;
    self._direction = ccp(0.0f, 0.0f);
    self._distanceTraveled = 0.0f;
    
    // init sprite stuff
    self.visible = false;
        
    return self;
}

//
//
//
- (FastAnimate *)createAnimationWithColorState:(ColorState)colorState {
    
    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:_frameCount];
    for (int i=0; i < _frameCount; i++) {
        [frames addObject:[SpriteFrameManager laserStartParticleSpriteFrameWithColorState:colorState frameNumber:i]];
    }
    
    CCAnimation *animation = [CCAnimation animationWithFrames:frames delay:_activeInterval / (float)_frameCount];
    return [FastAnimate actionWithAnimation:animation];
}

//
//
//
- (FastAnimate *)animationWithColorState:(ColorState)colorState {
    switch (colorState) {
        case kColorStateWhite: return _animateWhite;
        case kColorStateBlack: return _animateBlack;
        default: break;
    }
    
    return nil;
}


//
//
//
- (int)activateWithColorState:(ColorState)colorState direction:(CGPoint)direction {
  
    // if already active, then bail
    if (_active) {
        return 1;
    }
    
    // activate and add to scene
    _active = true;
    self.visible = true;
    
    // if no parent, then add to scene
    CCSpriteBatchNode *spriteBatchNode = [[StageScene sharedStageScene] spriteBatchNodeWithIndex:SPRITEBATCHNODE_INDEX_PLAYFIELD_02];
    if (self.parent != spriteBatchNode) {
        [spriteBatchNode addChild:self z:ZORDER_LASER_START_PARTICLE];
    }
    
    // set initial position
    self.position = [_laserStartEmitter controlPointToTrack]._position;
    
    // set direction
    _direction = direction;
    
    // set rotation
    float angle = ccpAngleSigned(_direction, ccp(0.0f, 1.0f));
    self.rotation = CC_RADIANS_TO_DEGREES(angle);
    
    // randomly flip them around (helps mix up the animations)
    self.flipX = arc4random() % 2;
    
    // reset timer
    _timer = 0.0f;
    
    // reset distance
    _distanceTraveled = 0.0f;
    
    // start action
    [self runAction:[self animationWithColorState:colorState]];
    
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
    
    // stop actions
    [self stopAllActions];
    
    // tell emitter we are deactivated
    [_laserStartEmitter deactivateLaserStartParticle:self];
    return 0;
}

//
//
//
- (void)chipmunkUpdate:(NSNumber *)elapsedTime {
    
    // if not active, then bail
    if (!_active) {
        return;
    }
    
    // see if we have expired
    _timer += [elapsedTime floatValue];
    if (_timer >= _activeInterval) {
        [self deactivateAndCleanup:false];
        return;
    }
    
    // update position
    _distanceTraveled += _velocity * [elapsedTime floatValue];
    self.position = ccpAdd([_laserStartEmitter controlPointToTrack]._position, ccpMult(_direction, _distanceTraveled));
}

//
//
//
- (void)dealloc {
    self._laserStartEmitter = nil;
    self._animateWhite = nil;
    self._animateBlack = nil;
    [super dealloc];
}

@end
