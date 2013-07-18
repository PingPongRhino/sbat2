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
#import "LaserSwitchParticle.h"
#import "LaserSwitchEmitter.h"
#import "FastAnimate.h"
#import "StageScene.h"
#import "SpriteFrameManager.h"

//
// static globals
//
static const int _frameCount = 10;
static const ccTime _animateDuration = 0.25f;

//
// @implementation LaserSwitchParticle
//
@implementation LaserSwitchParticle

//
// synthesize
//
@synthesize _laserSwitchEmitter;
@synthesize _active;
@synthesize _animateWhite;
@synthesize _animateBlack;

//
//
//
+ (id)laserSwitchParticleWithLaserSwitchEmitter:(LaserSwitchEmitter *)laserSwitchEmitter {
    LaserSwitchParticle *laserSwitchParticle = [[LaserSwitchParticle alloc] initWithLaserSwitchEmitter:laserSwitchEmitter];
    return [laserSwitchParticle autorelease];
}
                                                                                                
//
//
//
- (id)initWithLaserSwitchEmitter:(LaserSwitchEmitter *)laserSwitchEmitter {
    self = [super initWithSpriteFrame:[SpriteFrameManager laserSwitchParticleSpriteFrameWithColorState:kColorStateDefault frameNumber:0]];
    
    // init properties
    self._laserSwitchEmitter = laserSwitchEmitter;
    self._active = false;
    self._animateWhite = [self createAnimationWithColorState:kColorStateWhite];
    self._animateBlack = [self createAnimationWithColorState:kColorStateBlack];
    
    return self;
}

//
//
//
- (FastAnimate *)createAnimationWithColorState:(ColorState)colorState {
    
    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:_frameCount];
    for (int i=0; i < _frameCount; i++) {
        CCSpriteFrame *frame = [SpriteFrameManager laserSwitchParticleSpriteFrameWithColorState:colorState frameNumber:i];
        [frames addObject:frame];
    }
    
    // create animation
    CCAnimation *animation = [CCAnimation animationWithFrames:frames delay:_animateDuration / (float)_frameCount];
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
- (int)activateWithAnimateDelayInterval:(ccTime)animateDelayInterval
                             spawnPoint:(CGPoint)spawnPoint
                              direction:(CGPoint)direction
                             colorState:(ColorState)colorState
{
    
    // if already active, bail
    if (_active) {
        return 1;
    }
    
    // activate and add to scene
    _active = true;
    [[[StageScene sharedStageScene] spriteBatchNodeWithIndex:SPRITEBATCHNODE_INDEX_PLAYFIELD_02] addChild:self z:ZORDER_LASER_SWITCH_PARTICLE];
    
    // set position
    self.position = spawnPoint;
    
    // set rotation
    float radians = ccpAngleSigned(direction, ccp(0.0f, 1.0f));
    self.rotation = CC_RADIANS_TO_DEGREES(radians);
    
    // do some random flipping to mix it up
    self.flipX = arc4random() % 2;
    self.flipY = arc4random() % 2;
    
    // set current display frame, this frame is what will
    // show while we wait to run the animation
    [self setDisplayFrame:[SpriteFrameManager laserSwitchParticleSpriteFrameWithColorState:colorState frameNumber:0]];
    
    // set up animation/action
    CCDelayTime *delayAction = [CCDelayTime actionWithDuration:animateDelayInterval];
    FastAnimate *animation = [self animationWithColorState:colorState];
    CCCallFunc *completedFunc = [CCCallFunc actionWithTarget:self selector:@selector(animateCompleted)];
    CCSequence *sequence = [CCSequence actions:delayAction, animation, completedFunc, nil];
    
    // run it!
    [self runAction:sequence];

    return 0;
}

//
//
//
- (int)deactivate {
    
    // if already deactivated, then bail
    if (!_active) {
        return 1;
    }
    
    // deactivate and remove from scene
    _active = false;
    [self removeFromParentAndCleanup:false];
    
    // stop whatever actions we where running
    [self stopAllActions];
    
    // notify parent emitter we are dieing
    [_laserSwitchEmitter deactivateLaserSwitchParticle:self];
    
    return 0;
}

//
//
//
- (void)animateCompleted {
    [self deactivate];
}

//
//
//
- (void)dealloc {
    self._laserSwitchEmitter = nil;
    self._animateWhite = nil;
    self._animateBlack = nil;
    [super dealloc];
}

@end
