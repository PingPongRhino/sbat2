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
@class SFAttackStreamManager;

//
// @interface SFAttackManager
//
@interface SFAttackManager : NSObject {
    SoldierFactory *_soldierFactory;
    CCSprite *_gear;
    CCSprite *_gearShadow;
    CCSprite *_baseAttack;
    CCSprite *_centerAttack;
    SFAttackStreamManager *_attackStreamManager;
    
    CCSequence *_whiteBaseAttackSequence;
    CCSequence *_blackBaseAttackSequence;
    
    CCRepeatForever *_whiteCenterAttackAnimation;
    CCRepeatForever *_blackCenterAttackAnimation;
    
    bool _active;
}

//
// properties
//
@property (nonatomic, assign) SoldierFactory *_soldierFactory;
@property (nonatomic, retain) CCSprite *_gear;
@property (nonatomic, retain) CCSprite *_gearShadow;
@property (nonatomic, retain) CCSprite *_baseAttack;
@property (nonatomic, retain) CCSprite *_centerAttack;
@property (nonatomic, retain) SFAttackStreamManager *_attackStreamManager;
@property (nonatomic, retain) CCSequence *_whiteBaseAttackSequence;
@property (nonatomic, retain) CCSequence *_blackBaseAttackSequence;
@property (nonatomic, retain) CCRepeatForever *_whiteCenterAttackAnimation;
@property (nonatomic, retain) CCRepeatForever *_blackCenterAttackAnimation;
@property (nonatomic, assign) bool _active;

//
// static methods
//
+ (id)sfAttackManagerWithSoldierFactory:(SoldierFactory *)soldierFactory;

//
// methods
//
- (id)initWithSoldierFactory:(SoldierFactory *)soldierFactory;
- (CCSequence *)createBaseAttackSequenceWithColorState:(ColorState)colorState;
- (CCRepeatForever *)createCenterAttackAnimationWithColorState:(ColorState)colorState;
- (CCSequence *)baseSequenceWithColorState:(ColorState)colorState;
- (CCRepeatForever *)centerAnimationWithColorState:(ColorState)colorState;
- (void)setPosition:(CGPoint)position;
- (int)activate;
- (int)deactivate;
- (void)startEndingAnimation;
- (void)completedAnimation;
- (void)dealloc;

@end
