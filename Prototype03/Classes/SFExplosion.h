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

//
// @interface SFExplosion
//
@interface SFExplosion : CCSprite {
    SoldierFactory *_soldierFactory;
    bool _active;
    CCSequence *_whiteAnimation;
    CCSequence *_blackAnimation;
    bool _doRotation;
}

//
// properties
//
@property (nonatomic, assign) SoldierFactory *_soldierFactory;
@property (nonatomic, assign) bool _active;
@property (nonatomic, retain) CCSequence *_whiteAnimation;
@property (nonatomic, retain) CCSequence *_blackAnimation;
@property (nonatomic, assign) bool _doRotation;

//
// static functions
//
+ (id)sfExplosionWithSoldierFactory:(SoldierFactory *)soldierFactory;

//
// functions
//
- (id)initwithSoldierFactory:(SoldierFactory *)soldierFactory;
- (CCSequence *)createSequenceWithColorState:(ColorState)colorState;
- (CCSequence *)animationSequenceWithColorState:(ColorState)colorState;
- (int)activate;
- (int)deactivate;
- (void)update:(ccTime)elapsedTime;
- (void)animation01Completed;
- (void)animation02Completed;
- (void)dealloc;

@end
