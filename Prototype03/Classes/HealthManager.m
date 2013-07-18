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
#import "HealthManager.h"
#import "LaserCollider.h"

//
// @implementation HealthManager
//
@implementation HealthManager

//
// synthesize
//
@synthesize _maxHealth;
@synthesize _health;
@synthesize _percentage;
@synthesize _damageVelocity;
@synthesize _isPercentageDirty;
@synthesize _laserHitSet;

//
//
//
+ (id)healthManagerWithMaxHealth:(int)maxHealth damageVelocity:(float)damageVelocity {
    HealthManager *healthManager = [[HealthManager alloc] initWithMaxHealth:maxHealth damageVelocity:damageVelocity];
    return [healthManager autorelease];
}

//
//
//
- (id)initWithMaxHealth:(int)maxHealth damageVelocity:(float)damageVelocity {
    self = [super init];
    self._maxHealth = maxHealth;
    self._health = 0;
    self._percentage = 0.0f;
    self._damageVelocity = damageVelocity;
    self._isPercentageDirty = false;
    self._laserHitSet = [NSMutableSet setWithCapacity:4];
    return self;
}

//
//
//
- (float)getPercentage {
    
    // if percentage is not dirty, then send current value
    if (!_isPercentageDirty)
        return _percentage;
    
    // if percentage is dirty, then recalc
    _isPercentageDirty = false;
    
    // if we are at 100%
    if (_health >= _maxHealth) {
        _percentage = 100.0f;
    }
    else if (_health <= 0.0f) {
        _percentage = 0.0f;
    }
    else {
        _percentage = 100 * _health / _maxHealth;
    }
    
    return _percentage;
}

//
//
//
- (bool)isTakingDamage {
    if ([_laserHitSet count] > 0) {
        return true;
    }
    
    return false;
}

//
//
//
- (void)reset {
    _health = _maxHealth;
    _percentage = 100.0f;
    [_laserHitSet removeAllObjects];
}

//
//
//
- (void)takingDamageFromLaserCollider:(LaserCollider *)laserCollider {
    [_laserHitSet addObject:laserCollider._laserEmitter];
}

//
//
//
- (int)updateHealth:(ccTime)elapsedTime {
    
    // if not taking damage, then bail
    if ([_laserHitSet count] <= 0) {
        return _health;
    }
    
    // else decrement the health
    float delta = (_damageVelocity * [_laserHitSet count]) * elapsedTime;
    
    // remove health
    _health -= delta;
    
    // if we drop below zero
    if (_health <= 0.0f) {
        _health = 0.0f;
    }
    
    // percentage is now dirty
    _isPercentageDirty = true;
    
    // reset lasers array
    [_laserHitSet removeAllObjects];
    
    return _health;    
}

//
//
//
- (void)dealloc {
    self._laserHitSet = nil;
    [super dealloc];
}


@end
