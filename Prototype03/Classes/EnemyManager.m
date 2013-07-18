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
#import "EnemyManager.h"
#import "Soldier.h"
#import "SoldierFactory.h"
#import "NSMutableSet+Extended.h"
#import "NotificationStrings.h"
#import "StageLayer.h"
#import "LaserGrid.h"

//
// static globals
//
static EnemyManager *_sharedEnemyManager = nil;
static const float _defaultInset = 35.0f;   // default inset from laser grid

//
// @implementation EnemySpawn
//
@implementation EnemyManager

//
// synthesize
//
@synthesize _rect;
@synthesize _halfSize;
@synthesize _thirdSize;
@synthesize _fourthSize;
@synthesize _center;
@synthesize _thirdCorners;
@synthesize _fourthCorners;
@synthesize _activeEnemies;
@synthesize _soldiers;
@synthesize _inactiveSoldiers;
@synthesize _soldierFactories;
@synthesize _inactiveSoldierFactories;
@synthesize _currentSoldierSpawnZorder;

//
//
//
+ (EnemyManager *)createSharedEnemyManager {
    float inset = [LaserGrid inset] + _defaultInset;
    CGRect rect = CGRectInset([[StageLayer sharedStageLayer] boundingBox], inset, inset);
    return [EnemyManager createSharedEnemyManagerWithRect:rect];
}

//
//
//
+ (EnemyManager *)createSharedEnemyManagerWithRect:(CGRect)rect {
    [_sharedEnemyManager release];
    _sharedEnemyManager = [[EnemyManager alloc] initWithRect:rect];
    return _sharedEnemyManager;
}

//
//
//
+ (EnemyManager *)sharedEnemyManager {
    return _sharedEnemyManager;
}

//
//
//
+ (void)destroySharedEnemyManager {
    [_sharedEnemyManager release];
    _sharedEnemyManager = nil;
}

//
//
//
- (id)initWithRect:(CGRect)rect {
    self = [super init];
    
    // init properties
    self._rect = rect;
    self._halfSize = CGSizeMake(_rect.size.width / 2.0f, _rect.size.height / 2.0f);
    self._thirdSize = CGSizeMake(_rect.size.width / 3.0f, _rect.size.height / 3.0f);
    self._fourthSize = CGSizeMake(_rect.size.width / 4.0f, _rect.size.height / 4.0f);
    self._center = ccp(_rect.origin.x + _halfSize.width,
                       _rect.origin.y + _halfSize.height);
    self._thirdCorners = [self createThirdCorners];
    self._fourthCorners = [self createFourthCorners];
    self._activeEnemies = [NSMutableSet set];
    self._soldiers = [NSMutableSet set];
    self._inactiveSoldiers = [NSMutableSet set];
    self._soldierFactories = [NSMutableSet set];
    self._inactiveSoldierFactories = [NSMutableSet set];
    self._currentSoldierSpawnZorder = 0;
    
    // register for enemy soldier deactivate events
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeactivateEnemy:) name:kNotificationSoldierDeactivated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeactivateEnemy:) name:kNotificationSoldierFactoryDeactivated object:nil];    
    
    return self;
}

//
//
//
- (NSArray *)createThirdCorners {
    return [NSArray arrayWithObjects:
            [NSValue valueWithCGPoint:ccp(CGRectGetMaxX(_rect) - _thirdSize.width, CGRectGetMaxY(_rect) - _thirdSize.height)],
            [NSValue valueWithCGPoint:ccp(CGRectGetMaxX(_rect) - _thirdSize.width, CGRectGetMinY(_rect) + _thirdSize.height)],
            [NSValue valueWithCGPoint:ccp(CGRectGetMinX(_rect) + _thirdSize.width, CGRectGetMinY(_rect) + _thirdSize.height)],
            [NSValue valueWithCGPoint:ccp(CGRectGetMinX(_rect) + _thirdSize.width, CGRectGetMaxY(_rect) - _thirdSize.height)], nil];
}

//
//
//
- (NSArray *)createFourthCorners {
    
    return [NSArray arrayWithObjects:
            [NSValue valueWithCGPoint:ccp(CGRectGetMaxX(_rect) - _fourthSize.width, CGRectGetMaxY(_rect) - _fourthSize.height)],
            [NSValue valueWithCGPoint:ccp(CGRectGetMaxX(_rect) - _fourthSize.width, CGRectGetMinY(_rect) + _fourthSize.height)],
            [NSValue valueWithCGPoint:ccp(CGRectGetMinX(_rect) + _fourthSize.width, CGRectGetMinY(_rect) + _fourthSize.height)],
            [NSValue valueWithCGPoint:ccp(CGRectGetMinX(_rect) + _fourthSize.width, CGRectGetMaxY(_rect) - _fourthSize.height)], nil];
}

//
//
//
- (bool)activeEnemies {
    if ([_activeEnemies count] > 0) {
        return true;
    }
    
    return false;
}

//
//
//
- (Soldier *)spawnSoldierWithSpawnPoint:(CGPoint)spawnPoint
                             colorState:(ColorState)colorState
                          queueInterval:(ccTime)queueInterval
                           idleInterval:(ccTime)idleInterval
{
    Soldier *soldier = [self inactiveEnemyType:kEnemyTypeSoldier];
    if (!soldier) {
        return nil;
    }

    // set color
    [soldier switchToColorState:colorState];

    // set intervals
    soldier._stateQueuedInterval = queueInterval;
    soldier._subStateIdleInterval = idleInterval;
    
    // set spawn z order
    soldier._spawnZorder = _currentSoldierSpawnZorder;
    _currentSoldierSpawnZorder--;

    // activate with spawn point and start tracking it
    [soldier activateWithSpawnPoint:spawnPoint skipSpawnAnimation:false];
    [_activeEnemies addObject:soldier];
    return soldier;
}

//
//
//
- (Soldier *)spawnSoldierWithSpawnPoint:(CGPoint)spawnPoint
                             colorState:(ColorState)colorState
                       pathSegmentArray:(NSArray *)pathSegmentArray
                          targetedTower:(LaserTower *)targetedTower
                     skipSpawnAnimation:(bool)skipSpawnAnimation
{
    // get inactive soldier
    Soldier *soldier = [self inactiveEnemyType:kEnemyTypeSoldier];
    if (!soldier) {
        return nil;
    }
        
    // set up the soldier and spawn him
    [soldier switchToColorState:colorState];                // set color state
    [[soldier pathSegments] setArray:pathSegmentArray];     // set way points
    [soldier setTargetedTower:targetedTower];               // set targeted tower
    soldier._stateQueuedInterval = 0.0f;                    // spawn these guys immediately
    soldier._subStateIdleInterval = 0.0f;                   // don't be idle at all, just go go go!
    [soldier activateWithSpawnPoint:spawnPoint              // spawn soldier
                 skipSpawnAnimation:skipSpawnAnimation];
    
    // add to our active enemies
    [_activeEnemies addObject:soldier];
    return soldier;
}

//
//
//
- (SoldierFactory *)spawnSoldierFactoryWithSpawnPoint:(CGPoint)spawnPoint
                                            enemyType:(EnemyType)enemyType
                                           colorState:(ColorState)colorState
                                        queueInterval:(ccTime)queueInterval
                                      restingInterval:(ccTime)restingInterval
                                     spawningInterval:(ccTime)spawningInterval
                                   spawnEmissionCount:(int)spawnEmissionCount
{
    SoldierFactory *soldierFactory = [self inactiveEnemyType:enemyType];
    if (!soldierFactory) {
        return nil;
    }
    
    // set properties
    soldierFactory._enemyType = enemyType;
    [soldierFactory switchToColorState:colorState];
    soldierFactory._stateQueuedInterval = queueInterval;
    soldierFactory._spawnMaxCount = spawnEmissionCount;
    soldierFactory._aliveStateRestingInterval = restingInterval;
    soldierFactory._aliveStateSpawningInterval = spawningInterval;
    
    // activate and add to enemy manager
    [soldierFactory activateWithSpawnPoint:spawnPoint];
    [_activeEnemies addObject:soldierFactory];
    return soldierFactory;
}

//
//
//
- (void)recalcPathsAndTargets {
    [_activeEnemies makeObjectsPerformSelector:@selector(recalcTargetedTowerAndPath)];
}

//
//
//
- (id)inactiveEnemyType:(EnemyType)enemyType {
   switch (enemyType) {
       case kEnemyTypeSoldier: return [self inactiveSoldier];
           
       case kEnemyTypeSoldierFactory:
       case kEnemyTypeBarrierFactory: return [self inactiveSoldierFactoryWithEnemyType:enemyType];
       default: break;
   }
   
   return nil;
}

//
//
//
- (Soldier *)inactiveSoldier {    
    Soldier *soldier = [_inactiveSoldiers popItem];
    if (!soldier) {
        soldier = [Soldier soldier];
        [_soldiers addObject:soldier];
    }
    
    return soldier;
}

//
//
//
- (SoldierFactory *)inactiveSoldierFactoryWithEnemyType:(EnemyType)enemyType {
    SoldierFactory *soldierFactory = [_inactiveSoldierFactories popItem];
    if (!soldierFactory) {
        soldierFactory = [SoldierFactory soldierFactory];
        [_soldierFactories addObject:soldierFactory];
    }
        
    return soldierFactory;
}

//
// desc: deactivate all enemies
//
- (int)deactivateAllEnemies {
    [_soldiers makeObjectsPerformSelector:@selector(deactivate)];
    [_soldierFactories makeObjectsPerformSelector:@selector(deactivate)];
    return 0;
}

//
//
//
- (void)handleDeactivateEnemy:(NSNotification *)notification {
    
    id object = [notification object];
    if (!object) {
        return;
    }
    
    [_activeEnemies removeObject:object];
    
    if ([object isKindOfClass:[Soldier class]]) {
        [_inactiveSoldiers addObject:object];
        return;
    }
    
    if ([object isKindOfClass:[SoldierFactory class]]) {
        [_inactiveSoldierFactories addObject:object];
        return;
    }
}

//
//
//
/*- (void)checkAndApplyWaveTimerDamage {
    
    if (_gameMode != kGameModeSurvival) {
        return;
    }
    
    // see if there are any active soldier factories with health greater than 10%
    for (NSObject *object in _activeEnemies) {
        
        // if soldier factory
        if ([object isKindOfClass:[SoldierFactory class]]) {
            
            // if soldier factory is already dead OR it's really close to death
            // then cheat and give them the kill
            SoldierFactory *soldierFactory = (SoldierFactory *)object;
            int health = floorf(soldierFactory._healthManager._health);
            
            // check if we should take damage or not
            if (health <= 0 ||
                ([soldierFactory._healthManager isTakingDamage] &&
                [soldierFactory._healthManager getPercentage] <= 10.0f))
            {
                soldierFactory._healthManager._health = 0;
                [soldierFactory explode];
                continue;
            }
            
            // tell soldier factory to attack towers
            [soldierFactory attack];
        }
    }
}*/

//
//
//
- (CGPoint)fourthCorner:(Corner)corner {
    NSValue *value = [_fourthCorners objectAtIndex:corner];
    return [value CGPointValue];
}

//
//
//
- (CGPoint)thirdCorner:(Corner)corner {
    NSValue *value = [_thirdCorners objectAtIndex:corner];
    return [value CGPointValue];
}

//
//
//
- (CGPoint)corner:(Corner)corner {
    switch (corner) {
        case kCornerLeftBottom:     return ccp(CGRectGetMinX(_rect), CGRectGetMinY(_rect));
        case kCornerLeftTop:        return ccp(CGRectGetMinX(_rect), CGRectGetMaxY(_rect));
        case kCornerRightBottom:    return ccp(CGRectGetMaxX(_rect), CGRectGetMinY(_rect));
        case kCornerRightTop:       return ccp(CGRectGetMaxX(_rect), CGRectGetMaxY(_rect));
        default: break;
    }
    
    return cpvzero;
}

//
//
//
- (CGPoint)randomSpawnPoint {
    // pick random spawn point
    CGPoint spawnPoint = CGPointZero;
    spawnPoint.x = _rect.origin.x + (arc4random() % (int)_rect.size.width);
    spawnPoint.y = _rect.origin.y + (arc4random() % (int)_rect.size.height);
    return spawnPoint;
}

//
//
//
- (void)dealloc {
    
    // remove from notification center
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // tell all enemies to deactivate
    [self deactivateAllEnemies];
    
    // cleanup
    self._thirdCorners = nil;
    self._fourthCorners = nil;
    self._activeEnemies = nil;
    self._soldiers = nil;
    self._inactiveSoldiers = nil;
    self._soldierFactories = nil;
    self._inactiveSoldierFactories = nil;
    [super dealloc];
}

@end
