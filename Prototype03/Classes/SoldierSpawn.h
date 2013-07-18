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
#import "chipmunk.h"
#import "cocos2d.h"
#import "defines.h"

//
// forward declarations
//
@class Soldier;

//
// @interface SoldierSpawn
//
@interface SoldierSpawn : CCSprite {
    Soldier *_soldier;
    bool _active;
    SoldierSpawnState _state;
    float _zVelocity;
    CCProgressTimer *_healthBar;
    CCSprite *_animatedSprite;
    CCSequence *_animationWhite;
    CCSequence *_animationBlack;
    
    // chipmunk sensor (makes sure we are clear to spawn
    cpBody *_body;
    cpShape *_shape;
    int _collisionCount;
}

//
// properties
//
@property (nonatomic, assign) Soldier *_soldier;
@property (nonatomic, assign) SoldierSpawnState _state;
@property (nonatomic, assign) bool _active;
@property (nonatomic, assign) float _zVelocity;
@property (nonatomic, assign) CCProgressTimer *_healthBar;
@property (nonatomic, retain) CCSprite *_animatedSprite;
@property (nonatomic, retain) CCSequence *_animationWhite;
@property (nonatomic, retain) CCSequence *_animationBlack;
@property (nonatomic, assign) cpBody *_body;
@property (nonatomic, assign) cpShape *_shape;
@property (nonatomic, assign) int _collisionCount;

//
// static functions
//
+ (id)soldierSpawnWithSoldier:(Soldier *)soldier;

//
// initialization
//
- (id)initWithSoldier:(Soldier *)soldier;
- (CCSequence *)initSequenceWithColorState:(ColorState)colorState;
- (cpShape *)initShape;

//
// activate/deactivate
//
- (int)activate;
- (int)deactivate;

//
// manage sequence
//
- (CCSequence *)sequenceWithColorState:(ColorState)colorState;

//
// set state
//
- (int)setStateToSpawn;
- (int)setStateToZTransform;
- (int)setStateToHealthBar;

//
// animation call backs
//
- (void)completedSpawnAnimation;

//
// update
//
- (void)updateStateSpawn:(ccTime)elapsedTime;
- (void)updateStateZTransform:(ccTime)elapsedTime;
- (void)updateStateHealthBar:(ccTime)elapsedTime;
- (void)update:(ccTime)elapsedTime;

//
// chipmunk stuff
//
- (void)handleSoldierCollisionBegin:(Soldier *)soldier;
- (void)handleSoldierCollisionSeparate:(Soldier *)soldier;

//
// cleanup
//
- (void)dealloc;

@end
