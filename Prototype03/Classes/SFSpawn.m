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
#import "SFSpawn.h"
#import "SoldierFactory.h"
#import "StageScene.h"
#import "StageLayer.h"
#import "ColorStateManager.h"
#import "FastAnimate.h"
#import "SFExplosion.h"
#import "BarrierManager.h"
#import "SpriteFrameManager.h"

//
// static globals
//
static const float _zAcceleration = 1000.0f;
static const float _zVelocityMin = 0.0f;
static const float _zVelocityMax = 2000.0f;
static const float _zMin = -500.0f;
static const float _zMax = 0.0f;
static const float _healthBarVelocity = 100.0f;
static const float _maxRotationVelocity = 360.0f;
static const float _rotationAcceleration = 360.0f;
static const ccTime _centerDelay = 0.25f;
static const int _animationBeginFrame = 9;
static const int _animationEndFrame = 5;
static const ccTime _animationDuration = 0.3f;
static const float _animationRotationVelocity = -90.0f;

//
// @implementation SFSpawn
//
@implementation SFSpawn

//
// synthesize
//
@synthesize _soldierFactory;
@synthesize _active;
@synthesize _centerSprite;
@synthesize _gearSprite;
@synthesize _gearShadowSprite;
@synthesize _healthBar;
@synthesize _barrierManager;
@synthesize _centerZVelocity;
@synthesize _gearZVelocity;
@synthesize _gearRotationVelocity;
@synthesize _gearDeacclerate;
@synthesize _timer;
@synthesize _animation;
@synthesize _whiteAnimation;
@synthesize _blackAnimation;

//
//
//
+ (id)sfSpawnWithSoldierFactory:(SoldierFactory *)soldierFactory {
    SFSpawn *sfSpawn = [[SFSpawn alloc] initWithSoldierFactory:soldierFactory];
    return [sfSpawn autorelease];
}

//
//
//
- (id)initWithSoldierFactory:(SoldierFactory *)soldierFactory {
    self = [super init];
    
    // init properties
    self._soldierFactory = soldierFactory;
    self._active = false;
    self._centerSprite = [CCSprite spriteWithSpriteFrame:[SpriteFrameManager soldierFactoryCenterSpriteFrameWithColorState:kColorStateDefault]];
    self._gearSprite = [CCSprite spriteWithSpriteFrame:[SpriteFrameManager soldierFactoryGearSpriteFrameWithColorState:kColorStateDefault]];
    self._gearShadowSprite = [CCSprite spriteWithSpriteFrame:[SpriteFrameManager soldierFactoryGearShadowSpriteFrame]];
    self._healthBar = [self createHealthBar];
    self._barrierManager = [BarrierManager barrierManagerWithSoldierFactory:_soldierFactory];
    self._centerZVelocity = 0.0f;
    self._gearZVelocity = 0.0f;
    self._gearRotationVelocity = 0.0f;
    self._gearDeacclerate = false;
    self._timer = 0.0f;
    self._animation = [CCSprite spriteWithSpriteFrame:[SpriteFrameManager soldierFactoryExplosionSpriteFrameWithColorState:kColorStateDefault frameNumber:0]];
    self._whiteAnimation = [self createSequenceWithColorState:kColorStateWhite];
    self._blackAnimation = [self createSequenceWithColorState:kColorStateBlack];
    
    // init super stuff
    [self scheduleUpdate];
    
    return self;
}

//
//
//
- (CCProgressTimer *)createHealthBar {
    CCSpriteFrame *spriteFrame = [SpriteFrameManager soldierFactoryHealthBarSpriteFrameWithColorState:kColorStateDefault];
    CCSprite *sprite = [CCSprite spriteWithSpriteFrame:spriteFrame];
    CCProgressTimer *progressTimer = [CCProgressTimer progressWithSprite:sprite];
    progressTimer.type = kCCProgressTimerTypeRadial;
    return progressTimer;
}

//
//
//
- (CCSequence *)createSequenceWithColorState:(ColorState)colorState {
    
    // get frames for animation 01
    NSMutableArray *frameArray = [NSMutableArray array];
    
    // now forward
    for (int i=_animationBeginFrame; i >= _animationEndFrame; i--) {
        [frameArray addObject:[SpriteFrameManager soldierFactoryExplosionSpriteFrameWithColorState:colorState frameNumber:i]];
    }
    
    // create animation
    CCAnimation *animation = [CCAnimation animationWithFrames:frameArray];
    FastAnimate *animate = [FastAnimate actionWithAnimation:animation duration:_animationDuration];
    
    // create call backs
    CCCallFunc *completedAnimation = [CCCallFunc actionWithTarget:self selector:@selector(completedAnimation)];
    
    return [CCSequence actions:animate, completedAnimation, nil];
}

//
//
//
- (CCSequence *)animationWithColorState:(ColorState)colorState {
    switch (colorState) {
        case kColorStateWhite: return _whiteAnimation;
        case kColorStateBlack: return _blackAnimation;
        default: break;
    }
    
    return nil;
}

//
//
//
- (int)activate {
    if (_active) {
        return 1;
    }
    
    _active = true;
    CCSpriteBatchNode *spriteBatchNode = [[StageScene sharedStageScene] spriteBatchNodeWithIndex:SPRITEBATCHNODE_INDEX_SPAWN];
    [spriteBatchNode addChild:_centerSprite z:ZORDER_SF_CENTER];
    [spriteBatchNode addChild:_gearSprite z:ZORDER_SF_GEAR];
    [spriteBatchNode addChild:_gearShadowSprite z:ZORDER_SF_GEAR_SHADOW];
    [spriteBatchNode addChild:_animation z:ZORDER_SF_EXPLOSION];
    [[StageLayer sharedStageLayer] addChild:_healthBar z:ZORDER_SF_SPAWN_HEALTH_BAR];
    [[StageLayer sharedStageLayer] addChild:self]; // add ourselves so we can update
    
    // set colors
    [_centerSprite setDisplayFrame:[SpriteFrameManager soldierFactoryCenterSpriteFrameWithColorState:_soldierFactory._colorState]];
    [_gearSprite setDisplayFrame:[SpriteFrameManager soldierFactoryGearSpriteFrameWithColorState:_soldierFactory._colorState]];
    
    // set health bar
    [_healthBar.sprite setDisplayFrame:[SpriteFrameManager soldierFactoryHealthBarSpriteFrameWithColorState:_soldierFactory._colorState]];
    _healthBar.percentage = -1.0f; // this is to force CCProgressTimer to update it's frame

    // hide everything
    _centerSprite.visible = false;
    _gearSprite.visible = false;
    _gearShadowSprite.visible = false;
    _animation.visible = false;
    _healthBar.visible = false;
    
    _timer = 0.0;
    
    // start animation
    [self activateAnimation];
    
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
    [_centerSprite removeFromParentAndCleanup:false];
    [_gearSprite removeFromParentAndCleanup:false];
    [_gearShadowSprite removeFromParentAndCleanup:false];
    [_animation removeFromParentAndCleanup:false];
    [_healthBar removeFromParentAndCleanup:false];
    [self removeFromParentAndCleanup:false];
    
    // kill barrier
    [_barrierManager deactivate];
            
    // kill animations
    [_animation stopAllActions];
    return 0;
}

//
//
//
- (void)activateAnimation {
    ColorState colorState = _soldierFactory._colorState;
    [_animation setDisplayFrame:[SpriteFrameManager soldierFactoryExplosionSpriteFrameWithColorState:colorState frameNumber:_animationBeginFrame]];
    CCSequence *sequence = [self animationWithColorState:colorState];
    [_animation runAction:sequence];
    _animation.visible = true;
    _animation.position = _soldierFactory._body->p;
    _animation.rotation = arc4random() % 360;
    _animation.vertexZ = _zMin;
}

//
//
//
- (void)completedAnimation {
    [self activateGearSprite];
    [self activateCenterSprite];
    [self activateBarrierManager];
    _animation.visible = false;
}

//
//
//
- (void)activateGearSprite {
    _gearSprite.visible = true;
    _gearSprite.position = _soldierFactory._body->p;
    _gearSprite.vertexZ = _zMin;
    _gearZVelocity = _zVelocityMin;
    _gearRotationVelocity = 0.0f;
    _gearDeacclerate = false;
    
    // activate shadows
    _gearShadowSprite.visible = true;
    _gearShadowSprite.position = _soldierFactory._body->p;
    _gearShadowSprite.vertexZ = _zMin;
}

//
//
//
- (void)activateCenterSprite {
    _centerSprite.visible = true;
    _centerSprite.position = _soldierFactory._body->p;
    _centerSprite.rotation = 0.0f;
    _centerSprite.vertexZ = _zMin;
    _centerZVelocity = _zVelocityMin;
}

//
//
//
- (void)activateBarrierManager {

    // if not barrier type, then don't worry about it
    if (_soldierFactory._enemyType != kEnemyTypeBarrierFactory) {
        return;
    }
    
    // activate and set z
    CCSpriteBatchNode *spriteBatchNode = [[StageScene sharedStageScene] spriteBatchNodeWithIndex:SPRITEBATCHNODE_INDEX_SPAWN];
    [_barrierManager switchToColorState:[ColorStateManager nextColorState:_soldierFactory._colorState]];
    [_barrierManager activateWithSpriteBatchNode:spriteBatchNode chipmunkEnabled:false];
    [_barrierManager setVertexZ:_centerSprite.vertexZ];
}

//
//
//
- (void)activateHealthBar {
    _healthBar.visible = true;
    _healthBar.position = _soldierFactory._body->p;
    _healthBar.percentage = 0.0f;
}

//
//
//
- (void)updateAnimation:(ccTime)elapsedTime {
    float delta = elapsedTime * _animationRotationVelocity;
    _animation.rotation += delta;
}

//
//
//
- (void)updateGearSprite:(ccTime)elapsedTime {
    
    // if not visible then bail
    if (!_gearSprite.visible) {
        return;
    }
    
    // if we already hit max velocity, don't update acceleration
    if (_gearZVelocity < _zVelocityMax) {
        float delta = elapsedTime * _zAcceleration;
        _gearZVelocity += delta;
        if (_gearZVelocity >= _zVelocityMax) {
            _gearZVelocity = _zVelocityMax;
        }        
    }
    
    // if we are at max z, then don't update z
    if (_gearSprite.vertexZ < _zMax) {
        float delta = (elapsedTime * _gearZVelocity) * CC_CONTENT_SCALE_FACTOR();
        _gearSprite.vertexZ = (_gearSprite.vertexZ + delta) / CC_CONTENT_SCALE_FACTOR();
        if (_gearSprite.vertexZ >= _zMax) {
            _gearSprite.vertexZ = _zMax;
        }
    }
    
    // if we haven't hit max acceleration AND we aren't deacclerating, then update rotation
    if (_gearRotationVelocity < _maxRotationVelocity && !_gearDeacclerate) {
        float delta = elapsedTime * _rotationAcceleration;
        _gearRotationVelocity += delta;
        if (_gearRotationVelocity >= _maxRotationVelocity) {
            _gearRotationVelocity = _maxRotationVelocity;
        }
    }
    
    // if we are deaccelerating
    if (_gearDeacclerate) {
        float delta = elapsedTime * _rotationAcceleration;
        _gearRotationVelocity -= delta;
        if (_gearRotationVelocity <= 0.0f) {
            _gearRotationVelocity = 0.0f;
            [self deactivate];
            [_soldierFactory setStateToAlive];
            return;
        }
    }
    
    // update rotation
    float delta = elapsedTime * _gearRotationVelocity;
    _gearSprite.rotation -= delta;
    
    // sync shadow to gear sprite
    _gearShadowSprite.vertexZ = _gearSprite.vertexZ / CC_CONTENT_SCALE_FACTOR();
}

//
//
//
- (void)updateCenterSprite:(ccTime)elapsedTime {
    
    // if not visible then bail
    if (!_centerSprite.visible) {
        return;
    }
    
    // check delay timer
    if (_timer < _centerDelay) {
        _timer += elapsedTime;
        return;
    }
    
    // if we already hit max velocity, don't update acceleration
    if (_centerZVelocity < _zVelocityMax) {
        float delta = elapsedTime * _zAcceleration;
        _centerZVelocity += delta;
        if (_centerZVelocity >= _zVelocityMax) {
            _centerZVelocity = _zVelocityMax;
        }        
    }
    
    // if we are at max z, then don't update z
    if (_centerSprite.vertexZ < _zMax) {
        float delta = (elapsedTime * _centerZVelocity) * CC_CONTENT_SCALE_FACTOR();
        _centerSprite.vertexZ = (_centerSprite.vertexZ + delta) / CC_CONTENT_SCALE_FACTOR();
        if (_centerSprite.vertexZ >= _zMax) {
            _centerSprite.vertexZ = _zMax;
            [self activateHealthBar];
        }
    }
    
    // sync barrier to gear
    [_barrierManager setVertexZ:_centerSprite.vertexZ];
}

//
//
//
- (void)updateHealthBar:(ccTime)elapsedTime {
    
    // if not visible, then bail
    if (!_healthBar.visible) {
        return;
    }
    
    // if we hit are max percentage, then bail
    if (_healthBar.percentage >= 100.0f) {
        return;
    }
    
    // animate health bar
    float delta = elapsedTime * _healthBarVelocity;
    _healthBar.percentage += delta;
    if (_healthBar.percentage >= 100.0f) {
        _healthBar.percentage = 100.0f;
        _gearDeacclerate = true;
    }
}

//
//
//
- (void)update:(ccTime)elapsedTime {
    [self updateAnimation:elapsedTime];
    [self updateGearSprite:elapsedTime];
    [self updateCenterSprite:elapsedTime];
    [self updateHealthBar:elapsedTime];
}

//
//
//
- (void)dealloc {
    self._soldierFactory = nil;
    self._centerSprite = nil;
    self._gearSprite = nil;
    self._gearShadowSprite = nil;
    self._healthBar = nil;
    self._barrierManager = nil;
    self._animation = nil;
    self._whiteAnimation = nil;
    self._blackAnimation = nil;
    [super dealloc];
}

@end
