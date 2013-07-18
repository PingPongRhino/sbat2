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
#import "defines.h"

//
// forward declarations
//
@class SoldierFactory;
@class BarrierObject;

//
// @interface BarrierManager
//
@interface BarrierManager : NSObject {
    SoldierFactory *_soldierFactory;
    BarrierObject *_barrierObject01;
    BarrierObject *_barrierObject02;
    bool _active;
    float _rotation;
    float _rotationGoal;
    float _rotationGoalDistance;
    float _rotationTraveled;
}

//
// properties
//
@property (nonatomic, assign) SoldierFactory *_soldierFactory;
@property (nonatomic, retain) BarrierObject *_barrierObject01;
@property (nonatomic, retain) BarrierObject *_barrierObject02;
@property (nonatomic, assign) bool _active;
@property (nonatomic, assign) float _rotation;
@property (nonatomic, assign) float _rotationGoal;
@property (nonatomic, assign) float _rotationTraveled;
@property (nonatomic, assign) float _rotationGoalDistance;

//
// static functions
//
+ (id)barrierManagerWithSoldierFactory:(SoldierFactory *)soldierFactory;

//
// functions
//
- (id)initWithSoldierFactory:(SoldierFactory *)soldierFactory;
- (int)activateWithSpriteBatchNode:(CCSpriteBatchNode *)spriteBatchNode chipmunkEnabled:(bool)chipmunkEnabled;
- (int)deactivate;
- (void)switchToColorState:(ColorState)colorState;
- (void)explode;
- (void)setVertexZ:(float)vertexZ;
- (void)calcBarrierObjectRotation;
- (float)calcGoalRotation;
- (void)updateRotation:(ccTime)elapsedTime;
- (void)update:(ccTime)elapsedTime;
- (void)dealloc;


@end
