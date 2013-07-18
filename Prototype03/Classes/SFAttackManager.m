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
#import "SFAttackManager.h"
#import "SoldierFactory.h"
#import "ColorStateManager.h"
#import "SFAttackStreamManager.h"
#import "StageScene.h"
#import "FastAnimate.h"
#import "SFSpawn.h"
#import "SpriteFrameManager.h"

//
// static globals
//
static const int _baseAttackFrameCount = 8;
static const int _centerAttackFrameCount = 5;
static const ccTime _baseAttackDuration = 0.5f;
static const ccTime _centerAttackDuration = 0.1f;

//
//  @implementation SFAttackManager
//
@implementation SFAttackManager

//
// synthesize
//
@synthesize _soldierFactory;
@synthesize _gear;
@synthesize _gearShadow;
@synthesize _baseAttack;
@synthesize _centerAttack;
@synthesize _attackStreamManager;
@synthesize _whiteBaseAttackSequence;
@synthesize _blackBaseAttackSequence;
@synthesize _whiteCenterAttackAnimation;
@synthesize _blackCenterAttackAnimation;
@synthesize _active;

//
//
//
+ (id)sfAttackManagerWithSoldierFactory:(SoldierFactory *)soldierFactory {
    SFAttackManager *attackManager = [[SFAttackManager alloc] initWithSoldierFactory:soldierFactory];
    return [attackManager autorelease];
}

//
// methods
//
- (id)initWithSoldierFactory:(SoldierFactory *)soldierFactory {
    self = [super init];
    
    // init properties
    self._soldierFactory = soldierFactory;
    self._gear = [CCSprite spriteWithSpriteFrame:[SpriteFrameManager soldierFactoryGearSpriteFrameWithColorState:kColorStateDefault]];
    self._gearShadow = [CCSprite spriteWithSpriteFrame:[SpriteFrameManager soldierFactoryGearShadowSpriteFrame]];
    self._baseAttack = [CCSprite spriteWithSpriteFrame:[SpriteFrameManager soldierFactoryBaseAttackSpriteFrameWithColorState:kColorStateDefault frameNumber:0]];
    self._centerAttack = [CCSprite spriteWithSpriteFrame:[SpriteFrameManager soldierFactoryCenterAttackSpriteFrameWithColorState:kColorStateDefault frameNumber:0]];
    self._attackStreamManager = [SFAttackStreamManager sfAttackStreamManagerWithAttackManager:self];
    self._whiteBaseAttackSequence = [self createBaseAttackSequenceWithColorState:kColorStateWhite];
    self._blackBaseAttackSequence = [self createBaseAttackSequenceWithColorState:kColorStateBlack];
    self._whiteCenterAttackAnimation = [self createCenterAttackAnimationWithColorState:kColorStateWhite];
    self._blackCenterAttackAnimation = [self createCenterAttackAnimationWithColorState:kColorStateBlack];
    self._active = false;
    
    return self;
}

//
//
//
- (CCSequence *)createBaseAttackSequenceWithColorState:(ColorState)colorState {
    
    // get frames
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:_baseAttackFrameCount];
    for (int i=0; i < _baseAttackFrameCount; i++) {
        [array addObject:[SpriteFrameManager soldierFactoryBaseAttackSpriteFrameWithColorState:colorState frameNumber:i]];
    }
    
    CCAnimation *animation = [CCAnimation animationWithFrames:array];
    FastAnimate *animate = [FastAnimate actionWithAnimation:animation duration:_baseAttackDuration];
    
    CCCallFunc *completedAnimation = [CCCallFunc actionWithTarget:self selector:@selector(completedAnimation)];
    
    return [CCSequence actions:animate, completedAnimation, nil];
}

//
//
//
- (CCRepeatForever *)createCenterAttackAnimationWithColorState:(ColorState)colorState {
    
    // get frames
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:_baseAttackFrameCount];
    for (int i=0; i < _centerAttackFrameCount; i++) {
        [array addObject:[SpriteFrameManager soldierFactoryCenterAttackSpriteFrameWithColorState:colorState frameNumber:i]];
    }
    
    CCAnimation *animation = [CCAnimation animationWithFrames:array];
    FastAnimate *animate = [FastAnimate actionWithAnimation:animation duration:_centerAttackDuration];
    
    return [CCRepeatForever actionWithAction:animate];

}

//
//
//
- (CCSequence *)baseSequenceWithColorState:(ColorState)colorState {
    switch (colorState) {
        case kColorStateWhite: return _whiteBaseAttackSequence;
        case kColorStateBlack: return _blackBaseAttackSequence;
        default: break;
    }
    
    return nil;
}

//
//
//
- (CCRepeatForever *)centerAnimationWithColorState:(ColorState)colorState {
    switch (colorState) {
        case kColorStateWhite: return _whiteCenterAttackAnimation;
        case kColorStateBlack: return _blackCenterAttackAnimation;
        default: break;
    }
    
    return nil;
}

//
//
//
- (void)setPosition:(CGPoint)position {
    _gear.position = position;
    _gearShadow.position = position;
    _baseAttack.position = position;
    _centerAttack.position = position;
}

//
//
//
- (int)activate {
    if (_active) {
        return 1;
    }
    
    _active = true;
    
    CCSpriteBatchNode *spriteBatchNode = [[StageScene sharedStageScene]._spriteBatchNodeList objectAtIndex:SPRITEBATCHNODE_INDEX_PLAYFIELD_03];
    [spriteBatchNode addChild:_gear z:ZORDER_SF_GEAR];
    [spriteBatchNode addChild:_gearShadow z:ZORDER_SF_GEAR_SHADOW];
    [spriteBatchNode addChild:_baseAttack z:ZORDER_SF_ATTACK_BASE];
    
    spriteBatchNode = [[StageScene sharedStageScene]._spriteBatchNodeList objectAtIndex:SPRITEBATCHNODE_INDEX_PLAYFIELD_01];
    [spriteBatchNode addChild:_centerAttack z:ZORDER_SF_ATTACK_CENTER];
    
    // set visibilty on everything
    [_soldierFactory setVisibility:false];
    _gear.visible = true;
    _gearShadow.visible = true;
    _baseAttack.visible = false;
    _centerAttack.visible = true;
    
    // set gear color stat
    [_gear setDisplayFrame:[SpriteFrameManager soldierFactoryGearSpriteFrameWithColorState:_soldierFactory._colorState]];
        
    // activate streams
    [_attackStreamManager activateWithColorState:_soldierFactory._colorState];
    
    // set actions
    [_baseAttack stopAllActions];
    [_centerAttack stopAllActions];
    
    // run center attack animation
    [_centerAttack runAction:[self centerAnimationWithColorState:_soldierFactory._colorState]];
    [_centerAttack setDisplayFrame:[SpriteFrameManager soldierFactoryCenterAttackSpriteFrameWithColorState:_soldierFactory._colorState frameNumber:0]];
    
    // set position
    [self setPosition:_soldierFactory._body->p];
    
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
    [_gear removeFromParentAndCleanup:false];
    [_gearShadow removeFromParentAndCleanup:false];
    [_baseAttack removeFromParentAndCleanup:false];
    [_centerAttack removeFromParentAndCleanup:false];
    [_attackStreamManager deactivate];
    
    return 0;
}

//
//
//
- (void)startEndingAnimation {
    _gear.visible = false;
    _gearShadow.visible = false;
    _centerAttack.visible = false;
    _baseAttack.visible = true;
    
    [_baseAttack stopAllActions];
    [_baseAttack runAction:[self baseSequenceWithColorState:_soldierFactory._colorState]];
    [_baseAttack setDisplayFrame:[SpriteFrameManager soldierFactoryBaseAttackSpriteFrameWithColorState:_soldierFactory._colorState frameNumber:0]];
}

//
//
//
- (void)completedAnimation {
    [_soldierFactory deactivate];
}

//
//
//
- (void)dealloc {
    self._soldierFactory = nil;
    self._gear = nil;
    self._baseAttack = nil;
    self._centerAttack = nil;
    self._attackStreamManager = nil;
    self._whiteBaseAttackSequence = nil;
    self._blackBaseAttackSequence = nil;
    self._whiteCenterAttackAnimation = nil;
    self._blackCenterAttackAnimation = nil;
    [super dealloc];
}

@end
