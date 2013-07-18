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
#import "cocos2d.h"

//
// forward declarations
//
@class StageLayer;
@class HealthManager;
@class GearSwitch;
@class PathSprite;
@class ScoreTerminalWindow;
@class LabelAnimateType;
@class LaserTower;
@class LaserEmitter;
@class LaserSwitchEmitter;
@class MasterControlSwitch;
@class Soldier;
@class PlayerShip;
@class WayPoint;

//
// @protocol LaserTowerTargetingProtocol
//
@protocol LaserTowerTargetingProtocol <NSObject>
- (CGPoint)bodyPosition;
- (NSMutableArray *)pathSegments;
- (LaserTower *)targetedTower;
- (void)setTargetedTower:(LaserTower *)laserTower;
@end

//
// @protocol PathSpriteOwnerProtocol
//
@protocol PathSpriteOwnerProtocol <NSObject>
- (NSMutableArray *)pathSprites;
- (NSArray *)pathSegments;
@end

//
// @protocol TerminalWindowProtocol
//
@protocol TerminalWindowProtocol <NSObject>
- (void)completedResizing:(id)terminalWindow;
- (void)completedHiding:(id)terminalWindow;
@end

//
// @protocol LabelTypeDelegateProtocol
//
@protocol LabelTypeDelegateProtocol <NSObject>
- (void)completedTyping:(id)object;
@end

//
// @protocol LabelTypeProtocol
//
@protocol LabelTypeProtocol <NSObject>
@property (nonatomic, assign) id<LabelTypeDelegateProtocol> _delegate;
@property (nonatomic, assign) ccTime _characterInterval;
- (float)calcContentHeight;
- (void)startTyping;
@end

//
// @protocol TouchProtocol
//
@protocol TouchProtocol <NSObject>
@required
- (bool)handleTouchBegan:(UITouch *)touch handleIfCloserThanDistance:(float *)minDistance;
- (void)handleTouchMoved:(UITouch *)touch;
- (bool)handleTouchEnded:(UITouch *)touch;
- (void)handleTouchCancelled:(UITouch *)touch;
@end