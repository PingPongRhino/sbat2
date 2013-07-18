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
#import "protocols.h"

//
// forward declarations
//
@class LaserTower;

//
// @interface LaserGrid
//
@interface LaserGrid : NSObject {
    bool _active;
    int _laserTowerCount;
    int _activeTowerCount;
    NSArray *_laserTowers;
    NSArray *_leftTowerPair;
    NSArray *_rightTowerPair;
    NSArray *_bottomTowerPair;
    NSArray *_topTowerPair;
    
    // defines layout of the grid for quick reference
    CGRect _rect;
    CGPoint _rectCenter;
}

//
// properties
//
@property (nonatomic, assign) bool _active;
@property (nonatomic, assign) int _laserTowerCount;
@property (nonatomic, assign) int _activeTowerCount;
@property (nonatomic, retain) NSArray *_laserTowers;
@property (nonatomic, retain) NSArray *_leftTowerPair;
@property (nonatomic, retain) NSArray *_rightTowerPair;
@property (nonatomic, retain) NSArray *_bottomTowerPair;
@property (nonatomic, retain) NSArray *_topTowerPair;
@property (nonatomic, assign) CGRect _rect;
@property (nonatomic, assign) CGPoint _rectCenter;

//
// static functions
//
+ (LaserGrid *)createSharedLaserGrid;
+ (LaserGrid *)sharedLaserGrid;
+ (void)destroySharedLaserGrid;

//
// get static variables
//
+ (float)inset;

//
// initialization
//
- (id)init;
- (void)createLaserTowers;
- (void)registerForNotifications;
- (void)unregisterForNotifications;

//
// activate/deactivate
//
- (int)activate;
- (int)deactivate;
- (void)reset;

//
// manage tower state stuff
//
- (void)handleLaserTowerDeactivated:(NSNotification *)notification;
- (bool)allTowersDeactivated;
- (bool)allTowersDeactivatedOrExploding;
- (bool)allTowersHaveCompletedColorSwitch;

//
// manage observation of master control switches
//
- (void)registerMasterControlSwitches:(NSArray *)masterControlSwitches;
- (void)unregisterMasterControlSwitches:(NSArray *)masterControlSwitches;
- (void)handleMasterControlSwitchTapped:(NSNotification *)notification;

//
// color state
//
- (void)switchToColorState:(ColorState)colorState playSFX:(bool)playSFX forceSwitch:(bool)forceSwitch;
- (bool)laserTowerIsColorState:(ColorState)colorState;

//
// manage tower health
//
- (void)decrementHealthOnAllTowersByValue:(int)healthToDecrement;
- (NSArray *)towersSortedByHealth;

//
// calc tower targeting and pathing
//
- (LaserTower *)nearestTowerForPosition:(CGPoint)point withTowerPair:(NSArray *)towerPair;
- (LaserTower *)calcPathForLaserTowerTargetingObject:(id<LaserTowerTargetingProtocol>)targetingObject;

//
// manage LaserTowerTargetingProtocol objects
//
- (void)deactivateLaserTowerTargetingObject:(id<LaserTowerTargetingProtocol>)targetingObject;

//
// handle touch
//
- (bool)handleTouchEnded:(UITouch *)touch;

//
// clenup
//
- (void)dealloc;

@end
