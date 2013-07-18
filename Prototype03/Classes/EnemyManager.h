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
@class Soldier;
@class SoldierFactory;
@class LaserTower;

//
// @interface EnemySpawn
//
@interface EnemyManager : NSObject {
        
    // cached spawn area calculations
    CGRect _rect;
    CGSize _halfSize;
    CGSize _thirdSize;
    CGSize _fourthSize;
    CGPoint _center;
    NSArray *_thirdCorners;
    NSArray *_fourthCorners;
    
    // all active enemies
    NSMutableSet *_activeEnemies;
    
    // soldier list
    NSMutableSet *_soldiers;
    NSMutableSet *_inactiveSoldiers;
    
    // soldier factory list
    NSMutableSet *_soldierFactories;
    NSMutableSet *_inactiveSoldierFactories;
    
    // for tracking z spawn order on soldiers
    int _currentSoldierSpawnZorder;
}

//
// properties
//
@property (nonatomic, assign) CGRect _rect;
@property (nonatomic, assign) CGSize _halfSize;
@property (nonatomic, assign) CGSize _thirdSize;
@property (nonatomic, assign) CGSize _fourthSize;
@property (nonatomic, assign) CGPoint _center;
@property (nonatomic, retain) NSArray *_thirdCorners;
@property (nonatomic, retain) NSArray *_fourthCorners;
@property (nonatomic, retain) NSMutableSet *_activeEnemies;
@property (nonatomic, retain) NSMutableSet *_soldiers;
@property (nonatomic, retain) NSMutableSet *_inactiveSoldiers;
@property (nonatomic, retain) NSMutableSet *_soldierFactories;
@property (nonatomic, retain) NSMutableSet *_inactiveSoldierFactories;
@property (nonatomic, assign) int _currentSoldierSpawnZorder;

//
// manage shared enemy manager
//
+ (EnemyManager *)createSharedEnemyManager;
+ (EnemyManager *)createSharedEnemyManagerWithRect:(CGRect)rect;
+ (EnemyManager *)sharedEnemyManager;
+ (void)destroySharedEnemyManager;

//
// initialization
//
- (id)initWithRect:(CGRect)rect;
- (NSArray *)createThirdCorners;
- (NSArray *)createFourthCorners;

//
// get status
//
- (bool)activeEnemies;

//
// spawn enemies
//
- (Soldier *)spawnSoldierWithSpawnPoint:(CGPoint)spawnPoint
                             colorState:(ColorState)colorState
                          queueInterval:(ccTime)queueInterval
                           idleInterval:(ccTime)idleInterval;

- (Soldier *)spawnSoldierWithSpawnPoint:(CGPoint)spawnPoint
                             colorState:(ColorState)colorState
                       pathSegmentArray:(NSArray *)pathSegmentArray
                          targetedTower:(LaserTower *)targetedTower
                     skipSpawnAnimation:(bool)skipSpawnAnimation;

- (SoldierFactory *)spawnSoldierFactoryWithSpawnPoint:(CGPoint)spawnPoint
                                            enemyType:(EnemyType)enemyType
                                           colorState:(ColorState)colorState
                                        queueInterval:(ccTime)queueInterval
                                      restingInterval:(ccTime)restingInterval
                                     spawningInterval:(ccTime)spawningInterval
                                   spawnEmissionCount:(int)spawnEmissionCount;

//
// manage enemy actions
//
- (void)recalcPathsAndTargets;

//
// manage inactive enemies
//
- (id)inactiveEnemyType:(EnemyType)enemyType;
- (Soldier *)inactiveSoldier;
- (SoldierFactory *)inactiveSoldierFactoryWithEnemyType:(EnemyType)enemyType;

//
// activate/deactivate
//
- (int)deactivateAllEnemies;
- (void)handleDeactivateEnemy:(NSNotification *)notification;

//
// fetch corner spawn points
//
- (CGPoint)fourthCorner:(Corner)corner;
- (CGPoint)thirdCorner:(Corner)corner;
- (CGPoint)corner:(Corner)corner;
- (CGPoint)randomSpawnPoint;

//
// cleanup
//
- (void)dealloc;

@end
