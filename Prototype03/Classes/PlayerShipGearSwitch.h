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
@class PlayerShipGear;
@class StageLayer;
@class FastAnimate;

//
// @interface PlayerShipGearSwitch
//
@interface PlayerShipGearSwitch : CCSprite {
    PlayerShipGear *_playerShipGear;
    bool _active;
    ColorState _colorState;
    FastAnimate *_animateWhite;
    FastAnimate *_animateBlack;
    CCProgressTimer *_gearBaseWhite;
    CCProgressTimer *_gearBaseBlack;
    CCProgressTimer *_activeGearBase;
}

//
// properties
//
@property (nonatomic, assign) PlayerShipGear *_playerShipGear;
@property (nonatomic, assign) bool _active;
@property (nonatomic, assign) ColorState _colorState;
@property (nonatomic, retain) FastAnimate *_animateWhite;
@property (nonatomic, retain) FastAnimate *_animateBlack;
@property (nonatomic, retain) CCProgressTimer *_gearBaseWhite;
@property (nonatomic, retain) CCProgressTimer *_gearBaseBlack;
@property (nonatomic, assign) CCProgressTimer *_activeGearBase;

//
// static functions
//
+ (id)playerShipGearSwitchWithPlayerShipGear:(PlayerShipGear *)playerShipGear;

//
// functions
//
- (id)initWithPlayerShipGear:(PlayerShipGear *)playerShipGear;
- (FastAnimate *)createAnimationWithColorState:(ColorState)colorState;
- (CCProgressTimer *)createGearBaseWithColorState:(ColorState)colorState;
- (FastAnimate *)animationWithColorState:(ColorState)colorState;
- (CCProgressTimer *)gearBaseWithColorState:(ColorState)colorState;
- (void)setPositionWithValue:(NSValue *)value;
- (void)setRotationWithNumber:(NSNumber *)number;
- (int)activateWithColorState:(ColorState)colorState;
- (int)deactivate;
- (void)update:(ccTime)elapsedTime;
- (void)dealloc;

@end
