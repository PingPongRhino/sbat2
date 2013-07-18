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
#import "WaveManager07.h"
#import "ColorStateManager.h"
#import "EnemyManager.h"
#import "SoldierFactory.h"

//
// @implementation WaveManager07
//
@implementation WaveManager07

//
//
//
- (int)activate {
    if ([super activate] == 1) {
        return 1;
    }
    
    [self spawnThreeCenterStartingWithWhiteTop:[EnemyManager sharedEnemyManager]];
    return 0;
}

//
//
//
- (void)spawnThreeCenterStartingWithWhiteTop:(EnemyManager *)enemyManager {
    [self spawnThreeCenter:enemyManager startingWithColor:kColorStateWhite top:true];
    self._enemiesDeactivatedAction = @selector(spawnThreeCenterStartingWithBlackBottom:);
}

//
//
//
- (void)spawnThreeCenterStartingWithBlackBottom:(EnemyManager *)enemyManager {
    [self spawnThreeCenter:enemyManager startingWithColor:kColorStateBlack top:false];
    self._enemiesDeactivatedAction = @selector(spawnThreeLeftStartingWithWhite:);
}

//
//
//
- (void)spawnThreeLeftStartingWithWhite:(EnemyManager *)enemyManager {
    [self spawnThreeSide:enemyManager startingWithColor:kColorStateWhite left:true];
    self._enemiesDeactivatedAction = @selector(spawnThreeRightStartingWithBlack:);
}

//
//
//
- (void)spawnThreeRightStartingWithBlack:(EnemyManager *)enemyManager {
    [self spawnThreeSide:enemyManager startingWithColor:kColorStateBlack left:false];
    self._enemiesDeactivatedAction = @selector(spawnFiveCenterTopStartingWithWhite:);
}

//
//
//
- (void)spawnFiveCenterTopStartingWithWhite:(EnemyManager *)enemyManager {
    [self spawnFiveCenter:enemyManager startingWithColor:kColorStateWhite top:true];
    self._enemiesDeactivatedAction = @selector(spawnFiveCenterBottomStartingWithBlack:);
}

//
//
//
- (void)spawnFiveCenterBottomStartingWithBlack:(EnemyManager *)enemyManager {
    [self spawnFiveCenter:enemyManager startingWithColor:kColorStateBlack top:false];
    self._enemiesDeactivatedAction = @selector(spawnDiagonalLeftStartingWithWhite:);
}

//
//
//
- (void)spawnDiagonalLeftStartingWithWhite:(EnemyManager *)enemyManager {
    [self spawnDiagonal:enemyManager startingWithColor:kColorStateWhite left:true];
    self._enemiesDeactivatedAction = @selector(spawnDiagonalRightStartingWithBlack:);
}

//
//
//
- (void)spawnDiagonalRightStartingWithBlack:(EnemyManager *)enemyManager {
    [self spawnDiagonal:enemyManager startingWithColor:kColorStateBlack left:false];
    _completedSpawn = true;
}

//
//
//
- (void)spawnThreeCenter:(EnemyManager *)enemyManager startingWithColor:(ColorState)startingColor top:(bool)top {
    
    // spawn outside ones first
    float ySpacing = [SoldierFactory radius];
    float xSpacing = [SoldierFactory spawnSpacing];
    float yCoord = (top) ? enemyManager._center.y + ySpacing : enemyManager._center.y - ySpacing;
    CGPoint spawnPoint = ccp(enemyManager._center.x - xSpacing, yCoord);
    [_trackingEnemies addObject:[enemyManager spawnSoldierFactoryWithSpawnPoint:spawnPoint
                                                                      enemyType:kEnemyTypeSoldierFactory
                                                                     colorState:startingColor
                                                                  queueInterval:0.0f
                                                                restingInterval:0.1f
                                                               spawningInterval:1.0f
                                                             spawnEmissionCount:3]];
    
    spawnPoint.x = enemyManager._center.x + xSpacing;
    [_trackingEnemies addObject:[enemyManager spawnSoldierFactoryWithSpawnPoint:spawnPoint
                                                                      enemyType:kEnemyTypeSoldierFactory
                                                                     colorState:startingColor
                                                                  queueInterval:0.0f
                                                                restingInterval:0.1f
                                                               spawningInterval:1.0f
                                                             spawnEmissionCount:3]];
    
    // spawn center guy
    spawnPoint.x = enemyManager._center.x;
    [_trackingEnemies addObject:[enemyManager spawnSoldierFactoryWithSpawnPoint:spawnPoint
                                                                      enemyType:kEnemyTypeSoldierFactory
                                                                     colorState:[ColorStateManager nextColorState:startingColor]
                                                                  queueInterval:0.75f
                                                                restingInterval:0.1f
                                                               spawningInterval:1.0f
                                                             spawnEmissionCount:3]];
}

//
//
//
- (void)spawnThreeSide:(EnemyManager *)enemyManager startingWithColor:(ColorState)startingColor left:(bool)left {
    // spawn outside ones first
    float xSpacing = [SoldierFactory diameter];
    float ySpacing = [SoldierFactory spawnSpacing];
    float xCoord = (left) ? CGRectGetMinX(enemyManager._rect) + xSpacing :
                            CGRectGetMaxX(enemyManager._rect) - xSpacing;
    
    CGPoint spawnPoint = ccp(xCoord, enemyManager._center.y - ySpacing);
    [_trackingEnemies addObject:[enemyManager spawnSoldierFactoryWithSpawnPoint:spawnPoint
                                                                      enemyType:kEnemyTypeSoldierFactory
                                                                     colorState:startingColor
                                                                  queueInterval:0.0f
                                                                restingInterval:0.1f
                                                               spawningInterval:1.0f
                                                             spawnEmissionCount:3]];
    
    spawnPoint.y = enemyManager._center.y + ySpacing;
    [_trackingEnemies addObject:[enemyManager spawnSoldierFactoryWithSpawnPoint:spawnPoint
                                                                      enemyType:kEnemyTypeSoldierFactory
                                                                     colorState:startingColor
                                                                  queueInterval:0.0f
                                                                restingInterval:0.1f
                                                               spawningInterval:1.0f
                                                             spawnEmissionCount:3]];
    
    // spawn center guy
    spawnPoint.y = enemyManager._center.y;
    [_trackingEnemies addObject:[enemyManager spawnSoldierFactoryWithSpawnPoint:spawnPoint
                                                                      enemyType:kEnemyTypeSoldierFactory
                                                                     colorState:[ColorStateManager nextColorState:startingColor]
                                                                  queueInterval:0.75f
                                                                restingInterval:0.1f
                                                               spawningInterval:1.0f
                                                             spawnEmissionCount:3]];
    
}

//
//
//
- (void)spawnFiveCenter:(EnemyManager *)enemyManager startingWithColor:(ColorState)startingColor top:(bool)top {
    float ySpacing = [SoldierFactory radius];
    float yCoord = (top) ? enemyManager._center.y + ySpacing : enemyManager._center.y - ySpacing;
    float xSpacing = CGRectGetWidth(enemyManager._rect) / 6.0;
    CGPoint spawnPoint = ccp(CGRectGetMinX(enemyManager._rect) + xSpacing, yCoord);
    
    for (int x=0; x < 5; x++) {
        ColorState colorState = (x != 2) ? startingColor : [ColorStateManager nextColorState:startingColor];
        float queueInterval = (x != 2) ? 0.0f : 0.75f;
        [_trackingEnemies addObject:[enemyManager spawnSoldierFactoryWithSpawnPoint:spawnPoint
                                                                          enemyType:kEnemyTypeSoldierFactory
                                                                         colorState:colorState
                                                                      queueInterval:queueInterval
                                                                    restingInterval:0.1f
                                                                   spawningInterval:1.0f
                                                                 spawnEmissionCount:3]];
        spawnPoint.x += xSpacing;
    }
}

//
//
//
- (void)spawnDiagonal:(EnemyManager *)enemyManager startingWithColor:(ColorState)startingColor left:(bool)left {
    float ySpacing = CGRectGetHeight(enemyManager._rect) / 6.0f;
    float xSpacing = CGRectGetWidth(enemyManager._rect) / 6.0;
    xSpacing = (left) ? xSpacing : xSpacing * -1.0f;
    
    CGPoint spawnPoint;
    spawnPoint.x = (left) ? CGRectGetMinX(enemyManager._rect) + xSpacing :
                            CGRectGetMaxX(enemyManager._rect) + xSpacing;
    spawnPoint.y = CGRectGetMaxY(enemyManager._rect) - ySpacing;
    
    for (int i=0; i < 5; i++) {
        ColorState colorState = (i != 2) ? startingColor : [ColorStateManager nextColorState:startingColor];
        float queueInterval = (i != 2) ? 0.0f : 0.75f;
        [_trackingEnemies addObject:[enemyManager spawnSoldierFactoryWithSpawnPoint:spawnPoint
                                                                          enemyType:kEnemyTypeSoldierFactory
                                                                         colorState:colorState
                                                                      queueInterval:queueInterval
                                                                    restingInterval:0.1f
                                                                   spawningInterval:1.0f
                                                                 spawnEmissionCount:3]];
        spawnPoint.x += xSpacing;
        spawnPoint.y -= ySpacing;
    }
}


@end
