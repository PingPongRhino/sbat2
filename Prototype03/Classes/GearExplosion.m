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
#import "GearExplosion.h"
#import "defines.h"
#import "FastAnimate.h"
#import "LaserTower.h"
#import "StageScene.h"
#import "SimpleAudioEngine.h"

//
// static globals
//
static const ccTime _start01AnimateDuration = 0.25f;
static const ccTime _start02AnimateDuration = 0.15f;
static const ccTime _endAnimateDuration = 0.5f;

//
// @implementation GearExplosion
//
@implementation GearExplosion

//
// synthesize
//
@synthesize _laserTower;
@synthesize _spriteBatchNode;
@synthesize _glowColor;
@synthesize _active;
@synthesize _animationSequence;
@synthesize _normalDamageSequence;

//
//
//
+ (id)gearExplosionWithLaserTower:(LaserTower *)laserTower
                        glowColor:(NSString *)glowColor
{
    GearExplosion *gearExplosion = [[GearExplosion alloc] initWithLaserTower:laserTower
                                                                   glowColor:glowColor];
    return [gearExplosion autorelease];
}

//
//
//
+ (CCSpriteFrame *)getFrameWithGlowColor:(NSString *)glowColor frameNumber:(int)frameNumber {
    NSString *frameName = [NSString stringWithFormat:@"gear_explosion_%@_%02d.png", glowColor, frameNumber];
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
}

//
// functions
//
- (id)initWithLaserTower:(LaserTower *)laserTower
               glowColor:(NSString *)glowColor
{
    self = [super initWithSpriteFrame:[GearExplosion getFrameWithGlowColor:glowColor frameNumber:4]];
    
    // init properties
    self._laserTower = laserTower;
    self._spriteBatchNode = [[StageScene sharedStageScene]._spriteBatchNodeList objectAtIndex:SPRITEBATCHNODE_INDEX_PLAYFIELD_04];
    self._glowColor = glowColor;
    self._active = false;
    self._animationSequence = [self initAnimationSequence];
    self._normalDamageSequence = [self initNormalDamageSequence];
    
    // set anchor point
    self.anchorPoint = ccp(0.6f, 0.85f);

    return self;
}

//
//
//
- (CCSequence *)initNormalDamageSequence {
    
    // get frames for start animation
    NSMutableArray *array = [NSMutableArray array];
    for (int i=0; i < 3; i++) {
        CCSpriteFrame *frame = [GearExplosion getFrameWithGlowColor:_glowColor frameNumber:i];
        [array addObject:frame];
    }
    
    // create start animation
    CCAnimation *animation = [CCAnimation animationWithFrames:array];
    FastAnimate *start01Animate = [FastAnimate actionWithAnimation:animation duration:_start01AnimateDuration];
    
    // generate our callback
    CCCallFunc *completedNormalDamageAnimation = [CCCallFunc actionWithTarget:self selector:@selector(completedNormalDamageAnimation)];
    
    return [CCSequence actions:start01Animate, completedNormalDamageAnimation, nil];
}

//
//
//
- (CCSequence *)initAnimationSequence {
    
    // get frames for start animation
    NSMutableArray *array = [NSMutableArray array];
    for (int i=0; i < 3; i++) {
        CCSpriteFrame *frame = [GearExplosion getFrameWithGlowColor:_glowColor frameNumber:i];
        [array addObject:frame];
    }
    
    // create start animation
    CCAnimation *animation = [CCAnimation animationWithFrames:array];
    FastAnimate *start01Animate = [FastAnimate actionWithAnimation:animation duration:_start01AnimateDuration];
    
    // load up start 2
    for (int i=2; i < 4; i++) {
        CCSpriteFrame *frame = [GearExplosion getFrameWithGlowColor:_glowColor frameNumber:i];
        [array addObject:frame];
    }
    
    // create start animation
    animation = [CCAnimation animationWithFrames:array];
    FastAnimate *start02Animate = [FastAnimate actionWithAnimation:animation duration:_start02AnimateDuration];

    
    // load up reset of end animation
    [array removeAllObjects];
    for (int i=4; i < 11; i++) {
        CCSpriteFrame *frame = [GearExplosion getFrameWithGlowColor:_glowColor frameNumber:i];
        [array addObject:frame];
    }
    
    animation = [CCAnimation animationWithFrames:array];
    FastAnimate *endAnimate = [FastAnimate actionWithAnimation:animation duration:_endAnimateDuration];
    
    // delay
    CCDelayTime *delayTime = [CCDelayTime actionWithDuration:0.25f];
    
    // call back functions
    CCCallFunc *hideFunc = [CCCallFunc actionWithTarget:self selector:@selector(hide)];
    CCCallFunc *showFunc = [CCCallFunc actionWithTarget:self selector:@selector(show)];
    CCCallFunc *hideLaserTowerFunc = [CCCallFunc actionWithTarget:self selector:@selector(hideLaserTower)];
    CCCallFunc *completedFunc = [CCCallFunc actionWithTarget:self selector:@selector(completedAnimation)];

    // create
    return [CCSequence actions:start01Animate, // run this twice
                               hideFunc,
                               delayTime,
                               showFunc,
                               start02Animate,
                               hideLaserTowerFunc,
                               endAnimate,
                               completedFunc, nil];
}

//
//
//
- (int)activateWithFullSequence:(bool)fullSequence {
    
    // this stuff we just want to reset if something else is already running
    if (_active) {
        [self deactivate];
    }
    
    _active = true;
    [_spriteBatchNode addChild:self z:ZORDER_GEAR_EXPLOSION];
    
    // choose the sequence to run
    CCSequence *sequence = fullSequence ? _animationSequence : _normalDamageSequence;
    [self runAction:sequence];
    
    // if doing full sequence then play sound effect
    if (fullSequence) {
        [[SimpleAudioEngine sharedEngine] playEffect:SFX_TOWER_SPUTTER pitch:1.0f pan:0.0f gain:SFX_TOWER_SPUTTER_GAIN];
    }
    
    return 0;
}

//
//
//
- (int)deactivate {
    
    if (!_active) {
        return 1;
    }
    
    _active = false;
    [self removeFromParentAndCleanup:false];
    [self stopAllActions];
    return 0;
}

//
//
//
- (void)hide {
    self.visible = false;
}

//
//
//
- (void)show {
    self.visible = true;
    [[SimpleAudioEngine sharedEngine] playEffect:SFX_TOWER_SPUTTER pitch:1.0f pan:0.0f gain:SFX_TOWER_SPUTTER_GAIN];
}

//
//
//
- (void)hideLaserTower {
    [_laserTower setVisible:false];
    [[SimpleAudioEngine sharedEngine] playEffect:SFX_TOWER_EXPLODE pitch:1.0f pan:0.0f gain:SFX_TOWER_EXPLODE_GAIN];
}

//
//
//
- (void)completedAnimation {
    [_laserTower deactivate];
}

//
//
//
- (void)completedNormalDamageAnimation {
    [self deactivate];
}

//
//
//
- (void)dealloc {
    self._laserTower = nil;
    self._spriteBatchNode = nil;
    self._glowColor = nil;
    self._animationSequence = nil;
    self._normalDamageSequence = nil;
    [super dealloc];
}

@end
