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
#import "EnemyDrop.h"
#import "StageScene.h"
#import "StageLayer.h"
#import "PlayerShip.h"
#import "EnemyDropHealth.h"
#import "EnemyDropXPts.h"
#import "FastAnimate.h"
#import "NotificationStrings.h"
#import "SpriteFrameManager.h"
#import "SimpleAudioEngine.h"

//
// static globals
//
static const ccTime _expireInterval = 5.0f;
static const ccTime _halfExpireInterval = 2.5f;
static const Byte _minOpacity = 100;
static const float _boundingBoxHalfSize = 11.0f;
static const ccTime _animationDuration = 0.5f;
static const int _animationFrameCount = 7;
static const float _scaleVelocity = 5.0f;

//
// @implementation EnemyDrop
//
@implementation EnemyDrop

//
// synthesize
//
@synthesize _enemyDropType;
@synthesize _body;
@synthesize _shape;
@synthesize _active;
@synthesize _chipmunkActive;
@synthesize _deactivateAfterScaling;
@synthesize _expireTimer;
@synthesize _blinkInterval;
@synthesize _blinkTimer;
@synthesize _activatedAnimation;

//
//
//
+ (id)enemyDropWithEnemyDropType:(EnemyDropType)enemyDropType {
    
    switch (enemyDropType) {
        case kEnemyDropTypeHealth:  return [[[EnemyDropHealth alloc] initWithEnemyDropType:enemyDropType] autorelease];
        case kEnemyDropType500Pts:
        case kEnemyDropType1000Pts:
        case kEnemyDropType1500Pts:
        case kEnemyDropType2000Pts:
        case kEnemyDropType2500Pts: return [[[EnemyDropXPts alloc] initWithEnemyDropType:enemyDropType] autorelease];
            
        default: break;
    }
    
    return nil;
}

//
// methods
//
- (id)initWithEnemyDropType:(EnemyDropType)enemyDropType {
    self = [super initWithSpriteFrame:[SpriteFrameManager enemyDropSpriteFrameFrameWithEnemyDropType:enemyDropType]];
    
    // init stuff
    self._enemyDropType = enemyDropType;
    self._body = cpBodyNew(INFINITY, INFINITY);
    self._shape = [self createShape];
    self._active = false;
    self._chipmunkActive = false;
    self._deactivateAfterScaling = true;
    self._expireTimer = 0.0f;
    self._blinkInterval = 0.0f;
    self._blinkTimer = 0.0f;
    
    // setup sprite stuff
    [self scheduleUpdate];
    
    return self;
}

//
//
//
- (cpShape *)createShape {
    
    cpVect vertices[] = {
        cpv(-_boundingBoxHalfSize, -_boundingBoxHalfSize),
        cpv(-_boundingBoxHalfSize,  _boundingBoxHalfSize),
        cpv( _boundingBoxHalfSize,  _boundingBoxHalfSize),
        cpv( _boundingBoxHalfSize, -_boundingBoxHalfSize)
    };
    
    cpShape *shape = cpPolyShapeNew(_body, 4, vertices, cpvzero);
    
    // shape setup
    shape->e = 0.0f;
    shape->u = 0.0f;
    shape->group = GROUP_ENEMY_DROP;
    shape->collision_type = COLLISION_TYPE_ENEMY_DROP;
    shape->layers = LAYER_MASK_ENEMY_DROPS;
    shape->sensor = true;
    shape->data = self;

    return shape;
}

//
//
//
- (CCSprite *)createActivatedAnimation {
    CCSprite *sprite = [CCSprite spriteWithSpriteFrame:[SpriteFrameManager enemyDropActivatedSpriteFrameWithNumber:0]];
    
    // generate frames
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:_animationFrameCount];
    for (int i=0; i < _animationFrameCount; i++) {
        [array addObject:[SpriteFrameManager enemyDropActivatedSpriteFrameWithNumber:i]];
    }
    
    CCAnimation *animation = [[CCAnimation alloc] initWithFrames:array];
    FastAnimate *fastAnimate = [[FastAnimate alloc] initWithAnimation:animation duration:_animationDuration];
    CCCallFunc *completedCallFunc = [[CCCallFunc alloc] initWithTarget:self selector:@selector(completedAnimation)];
    CCSequence *sequence = [[CCSequence alloc] initOne:fastAnimate two:completedCallFunc];
    [sprite runAction:sequence];
    
    // add to scene
    sprite.position = self.position;
    [[[StageScene sharedStageScene] spriteBatchNodeWithIndex:SPRITEBATCHNODE_INDEX_HUD_LOW] addChild:sprite z:ZORDER_ED_ACTIVATED_ANIMATION];

    // cleanup
    [array release];
    [animation release];
    [fastAnimate release];
    [completedCallFunc release];
    [sequence release];
    return sprite;
}

//
//
//
- (int)activateWithSpawnPoint:(CGPoint)spawnPoint {
    
    if (_active) {
        return 1;
    }
    
    // add some amount of jitter to the spawnpoint
    CGPoint delta = ccp((arc4random() % 30) * 0.1f, (arc4random() % 30) * 0.1f);
    delta = ccpRotateByAngle(delta, cpvzero, CC_DEGREES_TO_RADIANS(arc4random() % 360));
    spawnPoint = ccpAdd(spawnPoint, delta);
    
    _active = true;
    _deactivateAfterScaling = true;
    [[[StageScene sharedStageScene] spriteBatchNodeWithIndex:SPRITEBATCHNODE_INDEX_HUD_LOW] addChild:self z:ZORDER_ENEMY_DROP];
    _body->p = spawnPoint;
    self.position = spawnPoint;
    _expireTimer = 0.0f;
    _blinkInterval = 0.1f;
    _blinkTimer = 0.0f;
    self.opacity = 255;
    self.scale = 1.0f;
    
    [self activateChipmunk];
    
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
    [self deactivateChipmunk];
    
    // if we created animation
    if (_activatedAnimation && _activatedAnimation.parent) {
        [_activatedAnimation removeFromParentAndCleanup:true];
    }
    
    // send out notification that we deactivated
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationEnemyDropDeactivated object:self];
        
    return 0;
}

//
//
//
- (int)activateChipmunk {
    if (_chipmunkActive) {
        return 1;
    }
    
    _chipmunkActive = true;
    cpSpaceAddStaticShape([StageLayer sharedStageLayer]._space, _shape);
    return 0;
}

//
//
//
- (int)deactivateChipmunk {
    if (!_chipmunkActive) {
        return 1;
    }
    
    _chipmunkActive = false;
    cpSpaceRemoveStaticShape([StageLayer sharedStageLayer]._space, _shape);
    return 0;
}

//
//
//
- (void)update:(ccTime)elapsedTime {
    
    // check if we should deactivate
    if (_deactivateAfterScaling && self.scale <= 0.0f) {
        [self deactivate];
        return;
    }
    
    // run expire timer
    _expireTimer += elapsedTime;
    if (_expireTimer >= _expireInterval) {
        
        // scale out
        float delta = _scaleVelocity * elapsedTime;
        self.scale -= delta;
        
        if (self.scale <= 0.0f) {
            self.visible = false;
        }
        return;
    }
    
    // if we should start blinking
    if (_expireTimer >= _halfExpireInterval) {
        
        _blinkTimer += elapsedTime;
        if (_blinkTimer >= _blinkInterval) {
            self.opacity = (self.opacity == 255) ? _minOpacity : 255;
            _blinkTimer = 0.0f;
            _blinkInterval -= 0.0025f;
        }
    }
}

//
//
//
- (void)completedAnimation {
    
    // cleanup animation
    [_activatedAnimation removeFromParentAndCleanup:true];    
    [self deactivate];
    
}

//
//
//
- (void)handleCollisionWithPlayer:(id)object {
     [self dropWasActivated];
    
    // run activated animation
    _activatedAnimation = [self createActivatedAnimation];
    
    // play effect
    [[SimpleAudioEngine sharedEngine] playEffect:SFX_POWERUP pitch:1.0f pan:0.0f gain:SFX_POWERUP_GAIN];
    
    // do scale but done deactivate
    _expireTimer = _expireInterval;
    _deactivateAfterScaling = false;
}

//
//
//
- (void)chipmunkDeactivate {
    [self deactivateChipmunk];
}

//
//
//
- (void)dropWasActivated {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationEnemyDropActivated object:self];
}

//
//
//
- (void)dealloc {
    [self deactivate];
    
    if (_body) {
        cpBodyFree(_body);
        _body = NULL;
    }
    
    if (_shape) {
        cpShapeFree(_shape);
        _shape = NULL;
    }
    
    self._activatedAnimation = nil;
    
    [super dealloc];
}

@end
