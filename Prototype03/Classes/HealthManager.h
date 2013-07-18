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
#import <Foundation/Foundation.h>
#import "cocos2d.h"

//
// forward declarations
//
@class LaserCollider;

//
// @interface HealthManager
//
@interface HealthManager : NSObject {
    int _maxHealth;
    int _health;
    float _percentage;
    float _damageVelocity;
    bool _isPercentageDirty;
    NSMutableSet *_laserHitSet;
}

//
// properties
//
@property (nonatomic, assign) int _maxHealth;
@property (nonatomic, assign) int _health;
@property (nonatomic, assign) float _percentage;
@property (nonatomic, assign) float _damageVelocity;
@property (nonatomic, assign) bool _isPercentageDirty;
@property (nonatomic, retain) NSMutableSet *_laserHitSet;

//
// static functions
//
+ (id)healthManagerWithMaxHealth:(int)maxHealth damageVelocity:(float)damageVelocity;

//
// functions
//
- (id)initWithMaxHealth:(int)maxHealth damageVelocity:(float)damageVelocity;
- (float)getPercentage;
- (bool)isTakingDamage;
- (void)reset;
- (void)takingDamageFromLaserCollider:(LaserCollider *)laserCollider;
- (int)updateHealth:(ccTime)elapsedTime;
- (void)dealloc;

@end
