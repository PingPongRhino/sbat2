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
#import "defines.h"

//
// forward declarations
//
@class SFAttackManager;
@class SoldierFactory;
@class SFAttackStream;

//
// @interface SFAttack
//
@interface SFAttackStreamManager : NSObject {
    SFAttackManager *_attackManager;
    SoldierFactory *_soldierFactory;
    NSMutableSet *_attackStreams;
    NSMutableSet *_inactiveAttackStreams;
    int _streamsThatAreGrowing;
}

//
// properties
//
@property (nonatomic, assign) SFAttackManager *_attackManager;
@property (nonatomic, assign) SoldierFactory *_soldierFactory;
@property (nonatomic, retain) NSMutableSet *_attackStreams;
@property (nonatomic, retain) NSMutableSet *_inactiveAttackStreams;
@property (nonatomic, assign) int _streamsThatAreGrowing;

//
// static methods
//
+ (id)sfAttackStreamManagerWithAttackManager:(SFAttackManager *)attackManager;

//
// methods
//
- (id)initWithAttackManager:(SFAttackManager *)attackManager;
- (void)createAttackStreamsWithSoldierFactory:(SoldierFactory *)soldierFactory;
- (int)activateWithColorState:(ColorState)colorState;
- (int)deactivate;
- (void)deactivateAttackStream:(SFAttackStream *)attackStream;
- (void)streamIsShrinking:(SFAttackStream *)attackStream;
- (void)dealloc;


@end
