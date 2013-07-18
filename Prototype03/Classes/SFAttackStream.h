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
#import "cocos2d.h"
#import "defines.h"

//
// soldier factory
//
@class SoldierFactory;
@class SFAttackStreamManager;
@class LaserTower;

//
// @interface SFAttackStream
//
@interface SFAttackStream : CCSprite {
    SoldierFactory *_soldierFactory;
    SFAttackStreamManager *_attackStreamManager;
    LaserTower *_laserTower;
    bool _active;
    CGPoint _goalPosition;
    CGPoint _direction;
    float _distance;
    CGRect _originalTextureRect;
    CGRect _currentTextureRect;
    CGPoint _currentPosition;
    ccTime _timer;
    int _frameIndex;
    ColorState _colorState;
    bool _growing;
    bool _damagedTower;
}

//
// properties
//
@property (nonatomic, assign) SoldierFactory *_soldierFactory;
@property (nonatomic, assign) SFAttackStreamManager *_attackStreamManager;
@property (nonatomic, assign) LaserTower *_laserTower;
@property (nonatomic, assign) bool _active;
@property (nonatomic, assign) CGPoint _goalPosition;
@property (nonatomic, assign) CGPoint _direction;
@property (nonatomic, assign) float _distance;
@property (nonatomic, assign) CGRect _originalTextureRect;
@property (nonatomic, assign) CGRect _currentTextureRect;
@property (nonatomic, assign) CGPoint _currentPosition;
@property (nonatomic, assign) ccTime _timer;
@property (nonatomic, assign) int _frameIndex;
@property (nonatomic, assign) ColorState _colorState;
@property (nonatomic, assign) bool _growing;
@property (nonatomic, assign) bool _damagedTower;

//
// static stuff
//
+ (id)sfAttackStreamWithSoldierFactory:(SoldierFactory *)soldierFactory sfAttackStreamManager:(SFAttackStreamManager *)sfAttackStreamManager;

//
// methods
//
- (id)initWithSoldierFactory:(SoldierFactory *)soldierFactory sfAttackStreamManager:(SFAttackStreamManager *)sfAttackStreamManager;
- (int)activateWithColorState:(ColorState)colorState laserTower:(LaserTower *)laserTower;
- (int)deactivate;
- (void)updateGrowing:(ccTime)elapsedTime;
- (void)updateShrinking:(ccTime)elapsedTime;
- (void)update:(ccTime)elapsedTime;
- (void)dealloc;

@end
