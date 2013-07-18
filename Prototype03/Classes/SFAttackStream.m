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
#import "SFAttackStream.h"
#import "StageScene.h"
#import "SoldierFactory.h"
#import "CCSprite+Extended.h"
#import "SFAttackStreamManager.h"
#import "LaserTower.h"
#import "SpriteFrameManager.h"

//
// static globals
//
static const int _frameCount = 5;
static const ccTime _animationDuration = 0.05f;
static const float _velocity = 300.0f;

//
// @implementation SFAttackStream
//
@implementation SFAttackStream

//
// synthesize
//
@synthesize _soldierFactory;
@synthesize _attackStreamManager;
@synthesize _laserTower;
@synthesize _active;
@synthesize _goalPosition;
@synthesize _direction;
@synthesize _distance;
@synthesize _originalTextureRect;
@synthesize _currentTextureRect;
@synthesize _currentPosition;
@synthesize _timer;
@synthesize _frameIndex;
@synthesize _colorState;
@synthesize _growing;
@synthesize _damagedTower;

//
//
//
+ (id)sfAttackStreamWithSoldierFactory:(SoldierFactory *)soldierFactory sfAttackStreamManager:(SFAttackStreamManager *)sfAttackStreamManager {
    SFAttackStream *attackStream = [[SFAttackStream alloc] initWithSoldierFactory:soldierFactory sfAttackStreamManager:sfAttackStreamManager];
    return [attackStream autorelease];
}

//
//
//
- (id)initWithSoldierFactory:(SoldierFactory *)soldierFactory sfAttackStreamManager:(SFAttackStreamManager *)sfAttackStreamManager {
    CCSpriteFrame *spriteFrame = [SpriteFrameManager soldierFactoryAttackSpriteFrameWithColorState:kColorStateDefault number:0];
    self = [super initWithSpriteFrame:spriteFrame];
    
    // init properties
    self._soldierFactory = soldierFactory;
    self._attackStreamManager = sfAttackStreamManager;
    self._laserTower = nil;
    self._active = false;
    self._goalPosition = CGPointZero;
    self._direction = CGPointZero;
    self._distance = 0.0f;
    self._originalTextureRect = self.textureRect;
    self._currentTextureRect = CGRectZero;
    self._currentPosition = CGPointZero;
    self._timer = 0.0f;
    self._frameIndex = 0;
    self._growing = false;
    self._damagedTower = false;
    
    // set sprite stuff
    [self scheduleUpdate];
    self.anchorPoint = ccp(0.5f, 0.0f);
    
    return self;
}

//
//
//
- (int)activateWithColorState:(ColorState)colorState laserTower:(LaserTower *)laserTower {
    if (_active) {
        return 1;
    }
    
    _active = true;
    [[[StageScene sharedStageScene] spriteBatchNodeWithIndex:SPRITEBATCHNODE_INDEX_PLAYFIELD_01] addChild:self z:ZORDER_SF_ATTACK_STREAM];
    
    // set laser tower we are attacking and do damage to him, we display the damage later
    // need to do decrement now for sorting and finding the one with the next lowest health
    self._laserTower = laserTower;
    [_laserTower decrementHealthByValue:LASER_TOWER_DEFAULT_DAMAGE];
        
    // init positions and what not
    _goalPosition = laserTower._body->p;
    _direction = ccpNormalize(ccpSub(_goalPosition, _soldierFactory._body->p));
    self.position = ccpAdd(_soldierFactory._body->p, ccpMult(_direction, [SoldierFactory radius]));
    _currentPosition = self.position;
    
    // rotate along direction
    self.rotation = CC_RADIANS_TO_DEGREES(ccpAngleSigned(_direction, ccp(0.0f, 1.0f)));
    
    // cacl distance
    _distance = ccpDistance(_goalPosition, self.position);
    
    // reset frame stuff
    _timer = 0.0f;
    
    // set initial frame
    _colorState = colorState;
    [self setDisplayFrame:[SpriteFrameManager soldierFactoryAttackSpriteFrameWithColorState:_colorState number:0]];
    
    // randomly flip along the x
    self.flipX = arc4random() % 2;
        
    // init textureRect
    _currentTextureRect = _originalTextureRect;
    _currentTextureRect.size.height = 0.0f;
    
    // set initial texture
    // set our texture rect
    CGRect newTextureRect = self.textureRect;
    newTextureRect.origin.y += _currentTextureRect.origin.y - _originalTextureRect.origin.y;
    newTextureRect.size.height = _currentTextureRect.size.height;
    self.textureRect = newTextureRect;
    
    // reset tracking state stuff
    _growing = true;
    _damagedTower = false;
    
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
    [_attackStreamManager deactivateAttackStream:self];
    
    return 0;
}

//
//
//
- (void)updateGrowing:(ccTime)elapsedTime
{
    // calc delta
    float delta = _velocity * elapsedTime;
    
    // update height
    _currentTextureRect.size.height += delta;
    
    // if we haven't grown to the distance, then bail, nothing left to do
    if (_currentTextureRect.size.height <= _distance) {
        return;
    }
    
    // if we haven't done damage yet, do it know cause we should be in contact with the tower at this point
    if (!_damagedTower) {
        _damagedTower = true;
        [_laserTower displayDamage];
    }
    
    // cap the height if we need to height
    _currentTextureRect.size.height = _distance;
    
    // start shifting y coordinate
    _currentTextureRect.origin.y += delta;
    
    // check if we are done growing, (bottom edge has gone pase the original bottom edge
    float originalMaxY = _originalTextureRect.origin.y + _originalTextureRect.size.height;
    float currentMaxY = _currentTextureRect.origin.y + _currentTextureRect.size.height;
    if (currentMaxY >= originalMaxY) {
        _currentTextureRect.origin.y = originalMaxY - _distance;
        _growing = false;
        [_attackStreamManager streamIsShrinking:self];
    }
}

//
//
//
- (void)updateShrinking:(ccTime)elapsedTime
{
    // calc delta
    float delta = _velocity * elapsedTime;
    
    // shrink texture height
    _currentTextureRect.size.height -= delta;
    _currentTextureRect.origin.y += delta;
    
    if (_currentTextureRect.size.height <= 0.0f) {
        _currentTextureRect.size.height = 0.0f;
        [self deactivate]; // we are done
        return;
    }
    
    // update position
    _currentPosition = ccpAdd(_currentPosition, ccpMult(_direction, delta));
}

//
//
//
- (void)update:(ccTime)elapsedTime {
    
    // update texture rect stuff
    if (_growing) {
        [self updateGrowing:elapsedTime];
    }
    else {
        [self updateShrinking:elapsedTime];
    }
    
    // update frame
    _timer += elapsedTime;
    if (_timer >= _animationDuration) {
        _timer = 0.0f;
        
        _frameIndex++;
        if (_frameIndex >= _frameCount) {
            _frameIndex = 0;
        }
        
        [self setDisplayFrame:[SpriteFrameManager soldierFactoryAttackSpriteFrameWithColorState:_colorState number:_frameIndex]];
        
        // set our texture rect
        CGRect newTextureRect = self.textureRect;
        newTextureRect.origin.y += _currentTextureRect.origin.y - _originalTextureRect.origin.y; // add the delta to actual y coordinate
        newTextureRect.size.height = _currentTextureRect.size.height;
        self.textureRect = newTextureRect;
        
        // set position
        self.position = _currentPosition;
    }
}

//
//
//
- (void)dealloc {
    self._soldierFactory = nil;
    self._attackStreamManager = nil;
    self._laserTower = nil;
    [super dealloc];
}


@end
