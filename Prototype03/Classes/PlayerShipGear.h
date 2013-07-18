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
@class PlayerShip;
@class PlayerShipGearSwitch;

//
// @interface PlayerShipeGear
//
@interface PlayerShipGear : CCSprite {
    PlayerShip *_playerShip;
    CCSprite *_shadow;
    CGPoint _shadowDirection;
    bool _active;
    ColorState _colorState;
    NSMutableSet *_gearSwitches;
    NSMutableSet *_inactiveGearSwitches;
}

//
// properties
//
@property (nonatomic, assign) PlayerShip *_playerShip;
@property (nonatomic, retain) CCSprite *_shadow;
@property (nonatomic, assign) CGPoint _shadowDirection;
@property (nonatomic, assign) bool _active;
@property (nonatomic, assign) ColorState _colorState;
@property (nonatomic, retain) NSMutableSet *_gearSwitches;
@property (nonatomic, retain) NSMutableSet *_inactiveGearSwitches;

//
// static functions
//
+ (id)playerShipGearWithPlayerShip:(PlayerShip *)playerShip;

//
// functions
//
- (id)initWithPlayerShip:(PlayerShip *)playerShip;
- (void)setPosition:(CGPoint)position;
- (void)setRotation:(float)rotation;
- (int)activate;
- (int)deactivate;
- (PlayerShipGearSwitch *)inactivePlayerShipGearSwitch;
- (void)deactivateGearSwitch:(PlayerShipGearSwitch *)gearSwitch;
- (bool)isSwitchingColor;
- (void)switchToColorState:(ColorState)colorState;
- (void)update:(ccTime)elapsedTime;
- (void)dealloc;

@end
