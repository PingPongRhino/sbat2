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
#import "BarrierObject.h"
#import "SoldierFactory.h"
#import "StageLayer.h"
#import "StageScene.h"
#import "FastAnimate.h"
#import "LaserEmitter.h"
#import "LaserCollider.h"
#import "HealthManager.h"
#import "SpriteFrameManager.h"
#import "SimpleAudioEngine.h"

//
// static globals
//
static const int _frameCount = 8;
static const int _explosionFrameCount = 7;
static const ccTime _animationDuration = 0.25f;
static const ccTime _explosionDuration = 0.25f;
static const int _maxHealth = 100;
static const float _damageVelocity = 50;
static const float _shakeDistance = 2.0f;

//
// @implementation BarrierObject
//
@implementation BarrierObject

//
// synthesize
//
@synthesize _soldierFactory;
@synthesize _body;
@synthesize _shape;
@synthesize _active;
@synthesize _chipmunkActive;
@synthesize _exploding;
@synthesize _colorState;
@synthesize _healthManager;
@synthesize _whiteAnimation;
@synthesize _blackAnimation;
@synthesize _whiteExplosion;
@synthesize _blackExplosion;

//
//
//
+ (id)barrierObjectWithSoldierFactory:(SoldierFactory *)soldierFactory {
    BarrierObject *barrierObject = [[BarrierObject alloc] initWithSoldierFactory:soldierFactory];
    return [barrierObject autorelease];
}


//
//
//
- (id)initWithSoldierFactory:(SoldierFactory *)soldierFactory {
    self = [super initWithSpriteFrame:[SpriteFrameManager soldierFactoryBarrierSpriteFrameWithColorState:kColorStateDefault frameNumber:0]];
    
    // init properties
    self._soldierFactory = soldierFactory;
    self._body = cpBodyNew(INFINITY, INFINITY);
    self._shape = NULL;
    self._active = false;
    self._chipmunkActive = false;
    self._exploding = false;
    self._colorState = kColorStateDefault;
    self._healthManager = [HealthManager healthManagerWithMaxHealth:_maxHealth damageVelocity:_damageVelocity];
    self._whiteAnimation = [self createAnimationWithColorState:kColorStateWhite];
    self._blackAnimation = [self createAnimationWithColorState:kColorStateBlack];
    self._whiteExplosion = [self createExplosionAnimationWithColorState:kColorStateWhite];
    self._blackExplosion = [self createExplosionAnimationWithColorState:kColorStateBlack];
    
    // init chipmunk objects
    [self setupChipmunkObjects];
    
    // schedule update
    [self scheduleUpdate];
    
    return self;
}

//
//
//
- (void)setupChipmunkObjects {
        
    // explanation of magic numbers.  i wouldn't made this a const can't set static
    // function with non-constants (aka can't use cpv()).  I figured this out from translating coordinates
    // from the "collision boundary" shape in the emission_generator.psd under the barrier group.
    cpVect vertices[] = {
        cpv(0.0f, 0.0f),
        cpv(-19.0f, -28.0f),
        cpv(-33.0f, -14.0f),
        cpv(-33.0f,  14.0f),
        cpv(-19.0f,  28.0f)
    };
    
    _shape = cpPolyShapeNew(_body, 5, vertices, cpvzero);
    _shape->e = 0.0f;
    _shape->u = 1.0f;
    _shape->group = _soldierFactory._collisionGroup;
    _shape->collision_type = COLLISION_TYPE_BARRIER;
    _shape->layers = LAYER_MASK_PLAYER_LASER_COLLIDERS;
    _shape->sensor = true;
    _shape->data = self;
}

//
//
//
- (CCRepeatForever *)createAnimationWithColorState:(ColorState)colorState {
    
    // get frames for animation 01
    NSMutableArray *frameArray = [NSMutableArray arrayWithCapacity:_frameCount];
    
    // now forward
    for (int i=0; i < _frameCount; i++) {
        [frameArray addObject:[SpriteFrameManager soldierFactoryBarrierSpriteFrameWithColorState:colorState frameNumber:i]];
    }
    
    // create animation
    CCAnimation *animation = [CCAnimation animationWithFrames:frameArray];
    FastAnimate *animate = [FastAnimate actionWithAnimation:animation duration:_animationDuration];
    return [CCRepeatForever actionWithAction:animate];
}

//
//
//
- (CCSequence *)createExplosionAnimationWithColorState:(ColorState)colorState {
    // get frames for animation 01
    NSMutableArray *frameArray = [NSMutableArray arrayWithCapacity:_frameCount];
    
    // now forward
    for (int i=0; i < _explosionFrameCount; i++) {
        [frameArray addObject:[SpriteFrameManager soldierFactoryBarrierExplosionSpriteFrameWithColorState:colorState frameNumber:i]];
    }
    
    // create animation
    CCAnimation *animation = [CCAnimation animationWithFrames:frameArray];
    FastAnimate *animate = [FastAnimate actionWithAnimation:animation duration:_explosionDuration];
    
    CCCallFunc *completedExplosion = [CCCallFunc actionWithTarget:self selector:@selector(completedExplosion)];
    
    return [CCSequence actions:animate, completedExplosion, nil];
}

//
//
//
- (CCRepeatForever *)animationWithColorState:(ColorState)colorState {
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
- (CCSequence *)explosionAnimationWithColorState:(ColorState)colorState {
    switch (colorState) {
        case kColorStateWhite: return _whiteExplosion;
        case kColorStateBlack: return _blackExplosion;
        default: break;
    }
    
    return nil;
}

//
//
//
- (int)activateWithSpriteBatchNode:(CCSpriteBatchNode *)spriteBatchNode chipmunkEnabled:(bool)chipmunkEnabled {
    
    // if already active, then bail
    if (_active) {
        return 1;
    }
    
    // set to active and add to scene
    _active = true;
    _exploding = false;
    [spriteBatchNode addChild:self z:ZORDER_BARRIER];
    
    // sync sprite to body
    self.position = _body->p;
    self.rotation = CC_RADIANS_TO_DEGREES(-_body->a);
    
    // activate chipmunk objects
    if (chipmunkEnabled) {
        [self activateChipmunkObjects];
    }
    
    // run animation
    [self stopAllActions];
    [self runAction:[self animationWithColorState:_colorState]];
    
    // reset health
    [_healthManager reset];
    
    // reset our verte z
    self.vertexZ = 0.0f;
    
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
    
    // set to inactive and remove from scene
    _active = false;
    [self removeFromParentAndCleanup:false];
    
    // deactivate chipmunk stuff
    [self deactivateChipmunkObjects];
    
    // reset health
    [_healthManager reset];
    _exploding = false;
    
    // stop animation
    [self stopAllActions];
    
    return 0;
}

//
//
//
- (int)activateChipmunkObjects {
    if (_chipmunkActive) {
        return 1;
    }
    
    // add to space
    _chipmunkActive = true;
    cpSpace *space = [StageLayer sharedStageLayer]._space;
    cpSpaceAddBody(space, _body);
    cpSpaceAddShape(space, _shape);
    return 0;
}

//
//
//
- (int)deactivateChipmunkObjects {
    if (!_chipmunkActive) {
        return 1;
    }
    
    // remove from collision space
    _chipmunkActive = false;
    cpSpace *space = [StageLayer sharedStageLayer]._space;
    cpSpaceRemoveBody(space, _body);
    cpSpaceRemoveShape(space, _shape);
    return 0;
}

//
//
//
- (void)switchToColorState:(ColorState)colorState {
    _colorState = colorState;
    [self setDisplayFrame:[SpriteFrameManager soldierFactoryBarrierSpriteFrameWithColorState:_colorState frameNumber:0]];
}

//
//
//
- (void)explode {
    _exploding = true;
    [self deactivateChipmunkObjects];
    [self stopAllActions];
    [self runAction:[self explosionAnimationWithColorState:_colorState]];
    
    if (_active) {
        [[SimpleAudioEngine sharedEngine] playEffect:SFX_BARRIER_DEATH pitch:1.0f pan:0.0f gain:SFX_BARRIER_DEATH_GAIN];
    }
}

//
//
//
- (void)update:(ccTime)elapsedTime {
    
    // if we are exploding, then bail
    if (_exploding) {
        return;
    }
    
    // update health
    if ([_healthManager updateHealth:elapsedTime] <= 0) {
        [self explode];
    }
}

//
//
//
- (void)completedExplosion {
    [self deactivate];
}

//
// chipmunk callbacks
//
- (void)handleLaserCollision:(LaserCollider *)laserCollider {
    // only if the laser is the same color as us, then take damage
    LaserEmitter *laserEmitter = laserCollider._laserEmitter;
    if (laserEmitter._colorState == _colorState) {
        [_healthManager takingDamageFromLaserCollider:laserCollider];
    }
}

//
//
//
- (void)chipmunkUpdate:(NSNumber *)elapsedTime {
    self.position = _body->p;
    self.rotation = CC_RADIANS_TO_DEGREES(-_body->a);
            
    // if we are taking damage, then shake
    if ([_healthManager isTakingDamage]) {
        float distance = _shakeDistance * [_healthManager._laserHitSet count];
        CGPoint shakeDelta = ccpRotateByAngle(ccp(0.0f, distance), ccp(0.0f, 0.0f), arc4random());
        self.position = ccpAdd(_body->p, shakeDelta);
    }
}

//
//
//
- (void)dealloc {
    self._soldierFactory = nil;
    
    if (_body) {
        cpBodyFree(_body);
        _body = NULL;
    }
    
    if (_shape) {
        cpShapeFree(_shape);
        _shape = NULL;
    }
    
    self._healthManager = nil;
    self._whiteAnimation = nil;
    self._blackAnimation = nil;
    self._whiteExplosion = nil;
    self._blackExplosion = nil;
    
    [super dealloc];
}

@end
