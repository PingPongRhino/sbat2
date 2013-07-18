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
#import "LaserEndSpark.h"
#import "LaserEndEmitter.h"
#import "CubicBezierControlPoint.h"
#import "FastAnimate.h"
#import "StageScene.h"
#import "SpriteFrameManager.h"

//
// static globals
//
static const int _frameCount = 5;
static const float _velocity = 100.0f;
static const ccTime _activeInterval = 0.25f;
static const int _rotationRange = 90;

//
// @implementation LaserEndSpark
//
@implementation LaserEndSpark

//
// synthesize
//
@synthesize _laserEndEmitter;
@synthesize _active;
@synthesize _direction;
@synthesize _timer;
@synthesize _animateWhite;
@synthesize _animateBlack;
@synthesize _rotationMinRange;

//
//
//
+ (id)laserEndSparkWithLaserEndEmitter:(LaserEndEmitter *)laserEndEmitter {
    LaserEndSpark *laserEndSpark = [[LaserEndSpark alloc] initWithLaserEndEmitter:laserEndEmitter];
    return [laserEndSpark autorelease];
}

//
//
//
- (id)initWithLaserEndEmitter:(LaserEndEmitter *)laserEndEmitter {
    self = [super initWithSpriteFrame:[SpriteFrameManager laserEndSparkSpriteFrameWithColorState:kColorStateDefault frameNumber:0]];
    
    // init properties
    self._laserEndEmitter = laserEndEmitter;
    self._active = false;
    self._direction = ccp(0.0f, 0.0f);
    self._timer = 0.0f;
    self._animateWhite = [self createAnimationWithColorState:kColorStateWhite];
    self._animateBlack = [self createAnimationWithColorState:kColorStateBlack];
    self._rotationMinRange = -(_rotationRange / 2.0f);
    
    // init super class stuff
    [self scheduleUpdate];
    self.anchorPoint = ccp(0.5f, 0.0f);
    self.visible = false;
    
    return self;
}

//
//
//
- (FastAnimate *)createAnimationWithColorState:(ColorState)colorState {
    
    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:_frameCount];
    for (int i=0; i < _frameCount; i++) {
        [frames addObject:[SpriteFrameManager laserEndSparkSpriteFrameWithColorState:colorState frameNumber:i]];
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
        [spriteBatchNode addChild:self z:ZORDER_LASER_END_SPARK];
    }
    
    // set inital position
    CubicBezierControlPoint *controlPoint = [_laserEndEmitter controlPointToTrack];
    self.position = controlPoint._position;
    
    // set direction
    _direction = ccpMult(controlPoint._normal, -1);
    float angle = _rotationMinRange + (arc4random() % _rotationRange);
    _direction = ccpRotateByAngle(_direction, ccp(0.0f, 0.0f), CC_DEGREES_TO_RADIANS(angle));
    
    // set rotation
    angle = ccpAngleSigned(_direction, ccp(0.0f, 1.0f));
    self.rotation = CC_RADIANS_TO_DEGREES(angle);
    
    // randomly flip them around (helps mix up the animations)
    self.flipX = arc4random() % 2;
    self.flipY = arc4random() % 2;

    // reset timer
    _timer = 0.0f;
    
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
    
    // tell emitter we are deactivate
    [_laserEndEmitter deactivateLaserEndSpark:self];
    
    [self stopAllActions];
    
    return 0;
}

//
//
//
- (void)update:(ccTime)elapsedTime {
    
    // bail if we are not active
    if (!_active) {
        return;
    }
    
    // see if our time to live is up
    _timer += elapsedTime;
    if (_timer >= _activeInterval) {
        [self deactivateAndCleanup:false];
        return;
    }
    
    // update spark
    float delta = _velocity * elapsedTime;
    self.position = ccpAdd(self.position, ccpMult(_direction, delta));
}

//
//
//
- (void)dealloc {
    self._laserEndEmitter = nil;
    self._animateWhite = nil;
    self._animateBlack = nil;
    [super dealloc];
}

@end
