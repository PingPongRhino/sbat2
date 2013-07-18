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
#import "SoldierSpawn.h"
#import "Soldier.h"
#import "StageScene.h"
#import "StageLayer.h"
#import "SoldierExplosion.h"
#import "FastAnimate.h"
#import "SpriteFrameManager.h"

//
// static globals
//
static const float _zAcceleration = 1000.0f;
static const float _zVelocityMin = 0.0f;
static const float _zVelocityMax = 5000.0f;
static const float _zMin = -500.0f;
static const float _zMax = 0.0f;
static const float _healthBarVelocity = 100.0f;
static const int _startFrame = 3;
static const int _endFrame = 0;
static const ccTime _spawnDuration = 0.5f;
static const float _spawnRotationVelocity = 45.0f;

//
// @implementation SoldierSpawn
//
@implementation SoldierSpawn

//
// synthesize
//
@synthesize _soldier;
@synthesize _active;
@synthesize _state;
@synthesize _zVelocity;
@synthesize _healthBar;
@synthesize _animatedSprite;
@synthesize _animationWhite;
@synthesize _animationBlack;

@synthesize _body;
@synthesize _shape;
@synthesize _collisionCount;

//
//
//
+ (id)soldierSpawnWithSoldier:(Soldier *)soldier {
    SoldierSpawn *soldierSpawn = [[SoldierSpawn alloc] initWithSoldier:soldier];
    return [soldierSpawn autorelease];
}

//
//
//
- (id)initWithSoldier:(Soldier *)soldier {
    self = [super initWithSpriteFrame:[SpriteFrameManager soldierSpriteFrameWithColorState:kColorStateDefault]];
    
    // init properties
    self._soldier = soldier;
    self._active = false;
    self._state = kSoldierSpawnStateUnknown;
    self._zVelocity = _zVelocityMin;
    self._healthBar = _soldier._healthBar;
    self._animatedSprite = [CCSprite spriteWithSpriteFrame:[SpriteFrameManager soldierExplosionSpriteFrameWithColor:kColorStateDefault frameNumber:0]];
    self._animationWhite = [self initSequenceWithColorState:kColorStateWhite];
    self._animationBlack = [self initSequenceWithColorState:kColorStateBlack];
    self._body = cpBodyNew(INFINITY, INFINITY);
    self._shape = [self initShape];
    self._collisionCount = 0;
    
    // init super stuff
    [self scheduleUpdate];
    
    return self;
}

//
//
//
- (CCSequence *)initSequenceWithColorState:(ColorState)colorState {
    
    // get frames
    NSMutableArray *array = [NSMutableArray array];
    for (int i=_startFrame; i >= _endFrame; i--) {
        [array addObject:[SpriteFrameManager soldierExplosionSpriteFrameWithColor:colorState frameNumber:i]];
    }
    
    // create animation
    CCAnimation *animation = [CCAnimation animationWithFrames:array];
    FastAnimate *animate = [FastAnimate actionWithAnimation:animation duration:_spawnDuration];
    CCCallFunc *completedSpawnAnimation = [CCCallFunc actionWithTarget:self selector:@selector(completedSpawnAnimation)];
    return [CCSequence actions:animate, completedSpawnAnimation, nil];
}

//
//
//
- (cpShape *)initShape {
    cpShape *shape = cpCircleShapeNew(_body, [Soldier radius], cpvzero);
    
    // shape setup
    shape->e = 0.0f;
    shape->u = 0.0f;
    shape->group = GROUP_SOLDIERS + _soldier._soldierId;
    shape->collision_type = COLLISION_TYPE_SOLDIER_SPAWN_SENSOR;
    shape->layers = LAYER_MASK_SOLDIERS;
    shape->sensor = true;
    shape->data = self;
    
    return shape;
}

//
//
//
- (int)activate {
    
    if (_active) {
        return 1;
    }
    
    _active = true;
    [[[StageScene sharedStageScene] spriteBatchNodeWithIndex:SPRITEBATCHNODE_INDEX_SPAWN] addChild:self z:_soldier._spawnZorder];
    self.visible = false;
    
    // set frame
    [self setDisplayFrame:[SpriteFrameManager soldierSpriteFrameWithColorState:_soldier._colorState]];
    
    // set position
    self.position = _soldier._body->p;
    
    // init zvertex
    self.vertexZ = _zMin;
    
    // add chipmunk stuff
    cpSpace *space = [StageLayer sharedStageLayer]._space;
    cpSpaceAddBody(space, _body);
    cpSpaceAddStaticShape(space, _shape);
    _collisionCount = 0;
    
    // set initial state
    [self setStateToSpawn];
    
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
    
    // if showing the health bar, then remove it
    if (_state == kSoldierSpawnStateHealthBar ||
        _state == kSoldierSpawnStateWaitingOnCollision)
    {
        [_healthBar removeFromParentAndCleanup:false];
    }
    
    // remove chipmunk stuff
    cpSpace *space = [StageLayer sharedStageLayer]._space;
    cpSpaceRemoveBody(space, _body);
    cpSpaceRemoveStaticShape(space, _shape);
    
    return 0;
}

//
//
//
- (CCSequence *)sequenceWithColorState:(ColorState)colorState {
    switch (colorState) {
        case kColorStateWhite: return _animationWhite;
        case kColorStateBlack: return _animationBlack;
        default: break;
    }
    
    return nil;
}

//
//
//
- (int)setStateToSpawn {
    _state = kSoldierSpawnStateSpawn;
    
    // activate spawn animation
    [[[StageScene sharedStageScene] spriteBatchNodeWithIndex:SPRITEBATCHNODE_INDEX_SPAWN] addChild:_animatedSprite z:_soldier._spawnZorder];
    [_animatedSprite setDisplayFrame:[SpriteFrameManager soldierExplosionSpriteFrameWithColor:_soldier._colorState frameNumber:_startFrame]];
    [_animatedSprite runAction:[self sequenceWithColorState:_soldier._colorState]];
    _animatedSprite.rotation = arc4random() % 360;
    _animatedSprite.position = _soldier._body->p;
    _animatedSprite.vertexZ = _zMin;
    return 0;
} 

//
//
//
- (int)setStateToZTransform {
    _state = kSoldierSpawnStateZTransform;
    _zVelocity = _zVelocityMin;
    self.visible = true;
    return 0;
}

//
//
//
- (int)setStateToHealthBar {
    _state = kSoldierSpawnStateHealthBar;
    [[StageLayer sharedStageLayer] addChild:_healthBar z:ZORDER_SOLDIER_SPAWN_HEALTH_BAR];
    _healthBar.percentage = 0.0f;
    _healthBar.position = self.position;
    _healthBar.visible = true;
    return 0;
}

//
//
//
- (void)completedSpawnAnimation {
    [_animatedSprite removeFromParentAndCleanup:false];
    [self setStateToZTransform];
}

//
//
//
- (void)updateStateSpawn:(ccTime)elapsedTime {
    float delta = elapsedTime * _spawnRotationVelocity;
    _animatedSprite.rotation += delta;
}

//
//
//
- (void)updateStateZTransform:(ccTime)elapsedTime {
    
    // don't update if we already hit the max velocity
    if (_zVelocity < _zVelocityMax) {
        float delta = elapsedTime * _zAcceleration;
        _zVelocity += delta;
        
        // cap velocity
        if (_zVelocity >= _zVelocityMax) {
            _zVelocity = _zVelocityMax;
        }
    }

    // update vertez
    float delta = (elapsedTime * _zVelocity) * CC_CONTENT_SCALE_FACTOR(); // scale for retina
    self.vertexZ = (self.vertexZ + delta) / CC_CONTENT_SCALE_FACTOR(); // have to unscale cause retina will rescale it...
    
    if (self.vertexZ >= _zMax) {
        self.vertexZ = _zMax;
        [self setStateToHealthBar];
    }
}

//
//
//
- (void)updateStateHealthBar:(ccTime)elapsedTime {
    float delta = elapsedTime * _healthBarVelocity;
    _healthBar.percentage += delta;
    
    if (_healthBar.percentage >= 100.0f) {
        _state = kSoldierSpawnStateWaitingOnCollision;        
    }
}

//
//
//
- (void)update:(ccTime)elapsedTime {
    
    switch (_state) {
        case kSoldierSpawnStateSpawn: [self updateStateSpawn:elapsedTime]; break;
        case kSoldierSpawnStateZTransform: [self updateStateZTransform:elapsedTime]; break;
        case kSoldierSpawnStateHealthBar: [self updateStateHealthBar:elapsedTime]; break;
        default: break;
    }
    
    // if we are waiting for collisions to clear out and collisions are clear, then
    // we are done spawning, so kill us and set soldier into an alive state
    if (_state == kSoldierSpawnStateWaitingOnCollision && _collisionCount <= 0) {
        [self deactivate];
        [_soldier setStateToAlive];
    }
}

//
//
//
- (void)handleSoldierCollisionBegin:(Soldier *)soldier {
    _collisionCount++;
}

//
//
//
- (void)handleSoldierCollisionSeparate:(Soldier *)soldier {
    _collisionCount--;
}

//
//
//
- (void)dealloc {
    self._soldier = nil;
    self._healthBar = nil;
    self._animatedSprite = nil;
    self._animationWhite = nil;
    self._animationBlack = nil;

    if (_body) {
        cpBodyFree(_body);
        _body = NULL;
    }
    
    if (_shape) {
        cpShapeFree(_shape);
        _shape = NULL;
    }
    [super dealloc];
}

@end
