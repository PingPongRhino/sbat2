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
#import "LaserGrid.h"
#import "StageLayer.h"
#import "LaserTower.h"
#import "ColorStateManager.h"
#import "PathSegment.h"
#import "ScoreManager.h"
#import "GearExplosionEmitter.h"
#import "NotificationStrings.h"
#import "MasterControlSwitch.h"

//
// static globals
//
static LaserGrid *_sharedLaserGrid = nil;
static const float _inset = 70.0f;

//
// @implementation LaserGrid
//
@implementation LaserGrid

//
// synthesize
//
@synthesize _active;
@synthesize _laserTowerCount;
@synthesize _activeTowerCount;
@synthesize _laserTowers;
@synthesize _leftTowerPair;
@synthesize _rightTowerPair;
@synthesize _bottomTowerPair;
@synthesize _topTowerPair;
@synthesize _rect;
@synthesize _rectCenter;

//
//
//
+ (LaserGrid *)createSharedLaserGrid {
    [LaserGrid destroySharedLaserGrid];
    _sharedLaserGrid = [[LaserGrid alloc] init];
    return _sharedLaserGrid;
}

//
//
//
+ (LaserGrid *)sharedLaserGrid { return _sharedLaserGrid; }

//
//
//
+ (void)destroySharedLaserGrid {
    [_sharedLaserGrid release];
    _sharedLaserGrid = nil;
}

//
//
//
+ (float)inset { return _inset; };

//
//
//
- (id)init {
    self = [super init];
    
    // init properties
    self._active = false;
    self._laserTowerCount = 8;
    self._activeTowerCount = 0;
    self._laserTowers = nil;
    self._leftTowerPair = nil;
    self._rightTowerPair = nil;
    self._bottomTowerPair = nil;
    self._topTowerPair = nil;
    self._rect = CGRectZero;
    self._rectCenter = CGPointZero;
    
    // init laser array
    [self createLaserTowers];
    
    return self;
}

//
//
//
- (void)createLaserTowers {
    
    // create all the laser towers
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    for (int i=0; i < _laserTowerCount; i++) {
        LaserTower *laserTower = [LaserTower laserTower];
        [mutableArray addObject:laserTower];
    }
    
    // set laser towers
    self._laserTowers = [NSArray arrayWithArray:mutableArray];
    
    // get all the laser towers so we can get them organized
    LaserTower *laserTower01 = [_laserTowers objectAtIndex:0];
    LaserTower *laserTower02 = [_laserTowers objectAtIndex:1];
    LaserTower *laserTower03 = [_laserTowers objectAtIndex:2];
    LaserTower *laserTower04 = [_laserTowers objectAtIndex:3];
    LaserTower *laserTower05 = [_laserTowers objectAtIndex:4];
    LaserTower *laserTower06 = [_laserTowers objectAtIndex:5];
    LaserTower *laserTower07 = [_laserTowers objectAtIndex:6];
    LaserTower *laserTower08 = [_laserTowers objectAtIndex:7];
    
    // set layer mask for each guy
    laserTower01._collisionLayer = LAYER_MASK_LASER_TOWER_BOTTOM_LEFT;
    laserTower02._collisionLayer = LAYER_MASK_LASER_TOWER_BOTTOM_RIGHT;
    laserTower03._collisionLayer = LAYER_MASK_LASER_TOWER_TOP_LEFT;
    laserTower04._collisionLayer = LAYER_MASK_LASER_TOWER_TOP_RIGHT;
    laserTower05._collisionLayer = LAYER_MASK_LASER_TOWER_LEFT_BOTTOM;
    laserTower06._collisionLayer = LAYER_MASK_LASER_TOWER_LEFT_TOP;
    laserTower07._collisionLayer = LAYER_MASK_LASER_TOWER_RIGHT_BOTTOM;
    laserTower08._collisionLayer = LAYER_MASK_LASER_TOWER_RIGHT_TOP;
    
    // set initial layer mask for each guy
    laserTower01._wallCollisionLayer = LAYER_MASK_OUTSIDE_INVISIBLE_WALL_RIGHT;
    laserTower02._wallCollisionLayer = LAYER_MASK_OUTSIDE_INVISIBLE_WALL_LEFT;
    laserTower03._wallCollisionLayer = LAYER_MASK_OUTSIDE_INVISIBLE_WALL_RIGHT;
    laserTower04._wallCollisionLayer = LAYER_MASK_OUTSIDE_INVISIBLE_WALL_LEFT;
    laserTower05._wallCollisionLayer = LAYER_MASK_OUTSIDE_INVISIBLE_WALL_TOP;
    laserTower06._wallCollisionLayer = LAYER_MASK_OUTSIDE_INVISIBLE_WALL_BOTTOM;
    laserTower07._wallCollisionLayer = LAYER_MASK_OUTSIDE_INVISIBLE_WALL_TOP;
    laserTower08._wallCollisionLayer = LAYER_MASK_OUTSIDE_INVISIBLE_WALL_BOTTOM;
    
    // now sync it's partners
    laserTower01._partner = laserTower02;
    laserTower02._partner = laserTower01;
    laserTower03._partner = laserTower04;
    laserTower04._partner = laserTower03;
    laserTower05._partner = laserTower06;
    laserTower06._partner = laserTower05;
    laserTower07._partner = laserTower08;
    laserTower08._partner = laserTower07;
    
    // init health bar locations
    laserTower01._healthBarDirection = ccp( 0.0f,  1.0f);
    laserTower02._healthBarDirection = ccp( 0.0f,  1.0f);
    laserTower03._healthBarDirection = ccp( 0.0f, -1.0f);
    laserTower04._healthBarDirection = ccp( 0.0f, -1.0f);
    laserTower05._healthBarDirection = ccp( 1.0f,  0.0f);
    laserTower06._healthBarDirection = ccp( 1.0f,  0.0f);
    laserTower07._healthBarDirection = ccp(-1.0f,  0.0f);
    laserTower08._healthBarDirection = ccp(-1.0f,  0.0f);
    
    // set direction of health icons
    laserTower01._reverseIconDirection = false;
    laserTower02._reverseIconDirection = true;
    laserTower03._reverseIconDirection = true;
    laserTower04._reverseIconDirection = false;
    laserTower05._reverseIconDirection = true;
    laserTower06._reverseIconDirection = false;
    laserTower07._reverseIconDirection = false;
    laserTower08._reverseIconDirection = true;
    
    // set up pair list
    self._bottomTowerPair = [NSArray arrayWithObjects:laserTower01, laserTower02, nil];
    self._topTowerPair    = [NSArray arrayWithObjects:laserTower03, laserTower04, nil];
    self._leftTowerPair   = [NSArray arrayWithObjects:laserTower05, laserTower06, nil];
    self._rightTowerPair  = [NSArray arrayWithObjects:laserTower07, laserTower08, nil];
}

//
//
//
- (void)registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleLaserTowerDeactivated:)
                                                 name:kNotificationLaserTowerDeactivated
                                               object:nil];
}

//
//
//
- (void)unregisterForNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationLaserTowerDeactivated object:nil];
}

//
//
//
- (int)activate {
    
    // if already active, then bail
    if (_active)
        return 1;
    
    // set to active
    _active = true;
    
    // calc laser towers layout rect
    _rect = CGRectInset([[StageLayer sharedStageLayer] boundingBox], _inset, _inset);
    _rectCenter = ccp(CGRectGetMidX(_rect), CGRectGetMidY(_rect));
    
    // setup offset for tower coordinates
    float positionInset = (_inset / 2.0f) + (_inset / 10.0f);
    CGRect positionRect = CGRectInset(_rect, -positionInset, -positionInset);

    // activate towers
    [[_laserTowers objectAtIndex:0] activateWithSpawnPoint:ccp(CGRectGetMinX(positionRect), CGRectGetMinY(_rect)) withDirection:ccp(1.0f, 0.0f)];
    [[_laserTowers objectAtIndex:1] activateWithSpawnPoint:ccp(CGRectGetMaxX(positionRect), CGRectGetMinY(_rect)) withDirection:ccp(-1.0f, 0.0f)];
    [[_laserTowers objectAtIndex:2] activateWithSpawnPoint:ccp(CGRectGetMinX(positionRect), CGRectGetMaxY(_rect)) withDirection:ccp(1.0f, 0.0f)];
    [[_laserTowers objectAtIndex:3] activateWithSpawnPoint:ccp(CGRectGetMaxX(positionRect), CGRectGetMaxY(_rect)) withDirection:ccp(-1.0f, 0.0f)];
    [[_laserTowers objectAtIndex:4] activateWithSpawnPoint:ccp(CGRectGetMinX(_rect), CGRectGetMinY(positionRect)) withDirection:ccp(0.0f, 1.0f)];
    [[_laserTowers objectAtIndex:5] activateWithSpawnPoint:ccp(CGRectGetMinX(_rect), CGRectGetMaxY(positionRect)) withDirection:ccp(0.0f, -1.0f)];
    [[_laserTowers objectAtIndex:6] activateWithSpawnPoint:ccp(CGRectGetMaxX(_rect), CGRectGetMinY(positionRect)) withDirection:ccp(0.0f, 1.0f)];
    [[_laserTowers objectAtIndex:7] activateWithSpawnPoint:ccp(CGRectGetMaxX(_rect), CGRectGetMaxY(positionRect)) withDirection:ccp(0.0f, -1.0f)];
    
    // refresh th layer mask for all the towers
    [_laserTowers makeObjectsPerformSelector:@selector(refreshLayerMask)];
    
    // set all towers as active
    _activeTowerCount = _laserTowerCount;
    
    // reset color state
    [self switchToColorState:kColorStateDefault playSFX:false forceSwitch:true];
    
    // register for notifications
    [self registerForNotifications];
    
    return 0;
}

//
//
//
- (int)deactivate {
    
    // if not active, then bail
    if (!_active) {
        return 1;
    }
    
    // set to inactive
    _active = false;
    
    // deactivate all the towers
    [_laserTowers makeObjectsPerformSelector:@selector(deactivate)];
    
    // unregister for notifications
    [self unregisterForNotifications];
    return 0;
}

//
//
//
- (void)reset {
    [self deactivate];
    [self activate];
}

//
//
//
- (void)handleLaserTowerDeactivated:(NSNotification *)notification {
    _activeTowerCount--;
    if (_activeTowerCount <= 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAllLaserTowersDeactivated object:self];
    }
}

//
//
//
- (bool)allTowersDeactivated {
    
    if (_activeTowerCount <= 0)
        return true;
    
    return false;
}

//
//
//
- (bool)allTowersDeactivatedOrExploding {
     
    for (LaserTower *laserTower in _laserTowers) {
        if (laserTower._active && laserTower._laserTowerState != kLaserTowerStateExploding) {
            return false;
        }
    }
    
    return true;
}

//
//
//
- (bool)allTowersHaveCompletedColorSwitch {
    for (LaserTower *laserTower in _laserTowers) {
        if ([laserTower isSwitchingColor]) {
            return false;
        }
    }
    
    return true;
}

//
//
//
- (void)registerMasterControlSwitches:(NSArray *)masterControlSwitches {
    for (MasterControlSwitch *masterControlSwitch in masterControlSwitches) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleMasterControlSwitchTapped:)
                                                     name:kNotificationMasterControlSwitchTapped
                                                   object:masterControlSwitch];
    }
}

//
//
//
- (void)unregisterMasterControlSwitches:(NSArray *)masterControlSwitches {
    for (MasterControlSwitch *masterControlSwitch in masterControlSwitches) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationMasterControlSwitchTapped object:masterControlSwitch];
    }
}

//
//
//
- (void)handleMasterControlSwitchTapped:(NSNotification *)notification {
    MasterControlSwitch *masterControlSwitch = (MasterControlSwitch *)[notification object];
    [self switchToColorState:masterControlSwitch._colorState playSFX:false forceSwitch:true];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLaserGridHandledMasterControlSwitchTap
                                                        object:[notification object]];
}

//
//
//
- (void)switchToColorState:(ColorState)colorState playSFX:(bool)playSFX forceSwitch:(bool)forceSwitch {
    for (LaserTower *laserTower in _laserTowers) {
        [laserTower switchToColorState:colorState playSFX:playSFX forceSwitch:forceSwitch];
    }
}

//
//
//
- (bool)laserTowerIsColorState:(ColorState)colorState {
    for (LaserTower *laserTower in _laserTowers) {
        if (laserTower._colorState == colorState) {
            return true;
        }
    }
    
    return false;
}

//
//
//
- (void)decrementHealthOnAllTowersByValue:(int)healthToDecrement
{
    [_laserTowers makeObjectsPerformSelector:@selector(decrementHealthByNumber:) 
                                      withObject:[NSNumber numberWithInt:healthToDecrement]];
}

//
//
//
- (NSArray *)towersSortedByHealth {
    
    // get the towers that are still alive
    NSMutableArray *activeTowers = [NSMutableArray array];
    for (LaserTower *laserTower in _laserTowers) {
        if (![laserTower isDead]) {
            [activeTowers addObject:laserTower];
        }
    }
    
    [activeTowers sortUsingComparator:^(LaserTower *obj1, LaserTower *obj2) {
        
        if (obj1._health > obj2._health) {
            return NSOrderedAscending;
        }
        
        if (obj1._health < obj2._health) {
            return NSOrderedDescending;
        }
        
        // if they are the same then randomly order them
        return (arc4random() % 2) ? NSOrderedDescending : NSOrderedAscending;
    }];

    return activeTowers;
}

//
//
//
- (LaserTower *)nearestTowerForPosition:(CGPoint)point withTowerPair:(NSArray *)towerPair {
    
    LaserTower *tower01 = [towerPair objectAtIndex:0];
    LaserTower *tower02 = [towerPair objectAtIndex:1];
    
    // if both towers are inactive, then bail
    if ([tower01 isDead] && [tower02 isDead]) {
        return nil;
    }
    
    // if tower 1 is active but tower 2 isn't, then use tower 1
    if (![tower01 isDead] && [tower02 isDead]) {
        return tower01;
    }
    
    // if tower 1 is NOT active but tower 2 is active, then user tower 2
    if ([tower01 isDead] && ![tower02 isDead]) {
        return tower02;
    }
    
    // both towers are active, so find which one is closer
    float distance01 = ccpDistance(tower01.position, point);
    float distance02 = ccpDistance(tower02.position, point);
    
    // tower 1 is closer
    if (distance01 < distance02) {
        return tower01;
    }
    
    // else they are equal distance or tower 2 is closer
    return tower02;
}

//
//
//
- (LaserTower *)calcPathForLaserTowerTargetingObject:(id<LaserTowerTargetingProtocol>)targetingObject
{
    // reset the targeting object to reset his state
    [self deactivateLaserTowerTargetingObject:targetingObject];
    
    // reset path segment array
    NSMutableArray *pathSegments = [targetingObject pathSegments];
    
    // if all the towers are destroyed, then just return a path segment
    // to ourselves to stop us from moving
    if ([self allTowersDeactivatedOrExploding]) {
        return nil;
    }
    
    // get point for each axis
    CGPoint position = [targetingObject bodyPosition];
    CGPoint leftPoint = ccp(CGRectGetMinX(_rect), position.y);
    CGPoint rightPoint = ccp(CGRectGetMaxX(_rect), position.y);
    CGPoint bottomPoint = ccp(position.x, CGRectGetMinY(_rect));
    CGPoint topPoint = ccp(position.x, CGRectGetMaxY(_rect));
        
    // put points in list sorted by shorest length first
    NSArray *pointArray = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:leftPoint],
                                                    [NSValue valueWithCGPoint:rightPoint],
                                                    [NSValue valueWithCGPoint:bottomPoint],
                                                    [NSValue valueWithCGPoint:topPoint], nil];
    
    // sort the array with closest point first and furthest point laser
    NSArray *sortedPointArray = [pointArray sortedArrayUsingComparator:^(NSValue *obj1, NSValue *obj2) {
        
        float distance01 = ccpDistance([obj1 CGPointValue], position);
        float distance02 = ccpDistance([obj2 CGPointValue], position);
        
        if (distance01 < distance02)
            return NSOrderedAscending;
        
        if (distance01 > distance02)
            return NSOrderedDescending;
        
        return NSOrderedSame;
    }];
    
    // now find the closest targeted tower that is active
    LaserTower *laserTower = nil;
    NSArray *towerPair = nil;
    CGPoint wayPoint01 = ccp(0.0f, 0.0f);
    
    for (NSValue *value in sortedPointArray) {
        wayPoint01 = [value CGPointValue];
        
        // figure out tower pair for this point
        if (CGPointEqualToPoint(wayPoint01, leftPoint)) {
            towerPair = _leftTowerPair;
        }
        else if (CGPointEqualToPoint(wayPoint01, rightPoint)) {
            towerPair = _rightTowerPair;
        }
        else if (CGPointEqualToPoint(wayPoint01, bottomPoint)) {
            towerPair = _bottomTowerPair;
        }
        else if (CGPointEqualToPoint(wayPoint01, topPoint)) {
            towerPair = _topTowerPair;
        }
        
        // get closest tower between these points
        laserTower = [self nearestTowerForPosition:wayPoint01 withTowerPair:towerPair];
        
        // if tower is not nil, then we got a winner so break out
        if (laserTower) {
            break;
        }
    }
    
    // if we aren't at wayPoint01 yet, then add this segment to the list
    if (ccpDistance(position, wayPoint01) > 2.0f) {
        PathSegment *pathSegment = [PathSegment pathSegment];
        pathSegment._start = position;
        pathSegment._end = wayPoint01;
        [pathSegments addObject:pathSegment];
    }
        
    // set up path segment 2
    PathSegment *pathSegment = [PathSegment pathSegment];
    
    // the groove extends to both towers.  this resolves an isssue
    // where soldiers would recalc paths after a tower got destroyed.
    // they would lock into each other cause the new groove didn't have
    // enough space for the soldiers to shift backwards.
    pathSegment._start = laserTower._partner._body->p;
    
    // end point is targeted tower
    pathSegment._end = laserTower._body->p;
    
    // add way point to list
    [pathSegments addObject:pathSegment];
    
    // add attacking enemy and return the tower that was picked
    [laserTower addAttackingEnemy:targetingObject];
    [targetingObject setTargetedTower:laserTower];
    return laserTower;
}

//
//
//
- (void)deactivateLaserTowerTargetingObject:(id<LaserTowerTargetingProtocol>)targetingObject {
    // make sure we aren't still attacking our old tower
    [[targetingObject targetedTower] removeAttackingEnemy:targetingObject];
    
    // reset path segment array
    [[targetingObject pathSegments] removeAllObjects];
}

//
//
//
- (bool)handleTouchEnded:(UITouch *)touch {
    
    // if this isn't a tap, then don't do anything
    if (touch.tapCount <= 0) {
        return false;
    }
    
    for (int i=0; i < [_laserTowers count]; i++) {
        LaserTower *laserTower = [_laserTowers objectAtIndex:i];
        if ([laserTower handleTouchEnded:touch]) {
            return true;
        }
    }
    
    return false;
}

//
//
//
- (void)dealloc {
    [self deactivate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self._laserTowers = nil;
    self._leftTowerPair = nil;
    self._rightTowerPair = nil;
    self._bottomTowerPair = nil;
    self._topTowerPair = nil;
    [super dealloc];
}


@end
