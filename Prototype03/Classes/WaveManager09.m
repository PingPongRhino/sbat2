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
#import "WaveManager09.h"
#import "EnemyManager.h"
#import "SoldierFactory.h"
#import "ColorStateManager.h"

//
// @implementation WaveManager09
//
@implementation WaveManager09

//
//
//
- (int)activate {
    if ([super activate] == 1) {
        return 1;
    }
    
    [self spawnWhiteBarrierSFInCenter:[EnemyManager sharedEnemyManager]];
    return 0;
}

//
//
//
- (void)spawnWhiteBarrierSFInCenter:(EnemyManager *)enemyManager {
    [_trackingEnemies addObject:[enemyManager spawnSoldierFactoryWithSpawnPoint:enemyManager._center
                                                                      enemyType:kEnemyTypeBarrierFactory
                                                                     colorState:kColorStateWhite
                                                                  queueInterval:0.0f
                                                                restingInterval:0.1f
                                                               spawningInterval:0.1f
                                                             spawnEmissionCount:3]];
    self._enemiesDeactivatedAction = @selector(spawnBlackBarrierSFInCenter:);
}

//
//
//
- (void)spawnBlackBarrierSFInCenter:(EnemyManager *)enemyManager {
    [_trackingEnemies addObject:[enemyManager spawnSoldierFactoryWithSpawnPoint:enemyManager._center
                                                                      enemyType:kEnemyTypeBarrierFactory
                                                                     colorState:kColorStateBlack
                                                                  queueInterval:0.0f
                                                                restingInterval:0.1f
                                                               spawningInterval:0.1f
                                                             spawnEmissionCount:3]];
    self._enemiesDeactivatedAction = @selector(spawnWhiteBarrierHighBlackBarrierLow:);
}

//
//
//
- (void)spawnWhiteBarrierHighBlackBarrierLow:(EnemyManager *)enemyManager {
    CGPoint spawnPoint = ccp(enemyManager._center.x, [enemyManager fourthCorner:kCornerLeftTop].y);
    [_trackingEnemies addObject:[enemyManager spawnSoldierFactoryWithSpawnPoint:spawnPoint
                                                                      enemyType:kEnemyTypeBarrierFactory
                                                                     colorState:kColorStateWhite
                                                                  queueInterval:0.0f
                                                                restingInterval:0.1f
                                                               spawningInterval:0.1f
                                                             spawnEmissionCount:3]];
    
    spawnPoint = ccp(enemyManager._center.x, [enemyManager fourthCorner:kCornerLeftBottom].y);
    [_trackingEnemies addObject:[enemyManager spawnSoldierFactoryWithSpawnPoint:spawnPoint
                                                                      enemyType:kEnemyTypeBarrierFactory
                                                                     colorState:kColorStateBlack
                                                                  queueInterval:0.0f
                                                                restingInterval:0.1f
                                                               spawningInterval:0.1f
                                                             spawnEmissionCount:3]];
    
    self._enemiesDeactivatedAction = @selector(spawnBlackBarrierHighWhiteBarrierLow:);
}

//
//
//
- (void)spawnBlackBarrierHighWhiteBarrierLow:(EnemyManager *)enemyManager {
    CGPoint spawnPoint = ccp(enemyManager._center.x, [enemyManager fourthCorner:kCornerLeftTop].y);
    [_trackingEnemies addObject:[enemyManager spawnSoldierFactoryWithSpawnPoint:spawnPoint
                                                                      enemyType:kEnemyTypeBarrierFactory
                                                                     colorState:kColorStateBlack
                                                                  queueInterval:0.0f
                                                                restingInterval:0.1f
                                                               spawningInterval:0.1f
                                                             spawnEmissionCount:3]];
    
    spawnPoint = ccp(enemyManager._center.x, [enemyManager fourthCorner:kCornerLeftBottom].y);
    [_trackingEnemies addObject:[enemyManager spawnSoldierFactoryWithSpawnPoint:spawnPoint
                                                                      enemyType:kEnemyTypeBarrierFactory
                                                                     colorState:kColorStateWhite
                                                                  queueInterval:0.0f
                                                                restingInterval:0.1f
                                                               spawningInterval:0.1f
                                                             spawnEmissionCount:3]];
    
    self._enemiesDeactivatedAction = @selector(spawnCrossStartingWithWhite:);
}

//
//
//
- (void)spawnCrossStartingWithWhite:(EnemyManager *)enemyManager {
    [self spawnCross:enemyManager startingColor:kColorStateWhite withCenter:false];
    self._enemiesDeactivatedAction = @selector(spawnCrossStartingWithBlack:);
}

//
//
//
- (void)spawnCrossStartingWithBlack:(EnemyManager *)enemyManager {
    [self spawnCross:enemyManager startingColor:kColorStateBlack withCenter:false];
    self._enemiesDeactivatedAction = @selector(spawnFourInCornersStartingWithWhite:);
}

//
//
//
- (void)spawnFourInCornersStartingWithWhite:(EnemyManager *)enemyManager {
    [self spawnFourInCorners:enemyManager startingColor:kColorStateWhite withCenter:false];
    self._enemiesDeactivatedAction = @selector(spawnFourInCornersStartingWithBlack:);
}

//
//
//
- (void)spawnFourInCornersStartingWithBlack:(EnemyManager *)enemyManager {
    [self spawnFourInCorners:enemyManager startingColor:kColorStateBlack withCenter:false];
    self._enemiesDeactivatedAction = @selector(spawnFourInCornersWithCenterStartingWithWhite:);
}

//
//
//
- (void)spawnFourInCornersWithCenterStartingWithWhite:(EnemyManager *)enemyManager {
    [self spawnFourInCorners:enemyManager startingColor:kColorStateWhite withCenter:true];
    self._enemiesDeactivatedAction = @selector(spawnFourInCornersWithCenterStartingWithBlack:);
}

//
//
//
- (void)spawnFourInCornersWithCenterStartingWithBlack:(EnemyManager *)enemyManager {
    [self spawnFourInCorners:enemyManager startingColor:kColorStateBlack withCenter:true];
    _completedSpawn = true;
}

//
//
//
- (void)spawnCross:(EnemyManager *)enemyManager startingColor:(ColorState)startingColor withCenter:(bool)center {
    
    CGPoint spawnPoint = ccp(enemyManager._center.x, [enemyManager fourthCorner:kCornerLeftTop].y);
    [_trackingEnemies addObject:[enemyManager spawnSoldierFactoryWithSpawnPoint:spawnPoint
                                                                      enemyType:kEnemyTypeBarrierFactory
                                                                     colorState:startingColor
                                                                  queueInterval:0.0f
                                                                restingInterval:0.1f
                                                               spawningInterval:0.1f
                                                             spawnEmissionCount:3]];
    
    spawnPoint = ccp(enemyManager._center.x, [enemyManager fourthCorner:kCornerLeftBottom].y);
    [_trackingEnemies addObject:[enemyManager spawnSoldierFactoryWithSpawnPoint:spawnPoint
                                                                      enemyType:kEnemyTypeBarrierFactory
                                                                     colorState:startingColor
                                                                  queueInterval:0.0f
                                                                restingInterval:0.1f
                                                               spawningInterval:0.1f
                                                             spawnEmissionCount:3]];
    
    spawnPoint = ccp(CGRectGetMinX(enemyManager._rect) + [SoldierFactory diameter], enemyManager._center.y);
    [_trackingEnemies addObject:[enemyManager spawnSoldierFactoryWithSpawnPoint:spawnPoint
                                                                      enemyType:kEnemyTypeBarrierFactory
                                                                     colorState:[ColorStateManager nextColorState:startingColor]
                                                                  queueInterval:0.0f
                                                                restingInterval:0.1f
                                                               spawningInterval:0.1f
                                                             spawnEmissionCount:3]];
    
    spawnPoint = ccp(CGRectGetMaxX(enemyManager._rect) - [SoldierFactory diameter], enemyManager._center.y);
    [_trackingEnemies addObject:[enemyManager spawnSoldierFactoryWithSpawnPoint:spawnPoint
                                                                      enemyType:kEnemyTypeBarrierFactory
                                                                     colorState:[ColorStateManager nextColorState:startingColor]
                                                                  queueInterval:0.0f
                                                                restingInterval:0.1f
                                                               spawningInterval:0.1f
                                                             spawnEmissionCount:3]];
}

//
//
//
- (void)spawnFourInCorners:(EnemyManager *)enemyManager startingColor:(ColorState)startingColor withCenter:(bool)center {
    ColorState colorState = startingColor;
    for (int i=0; i < kCornerCount; i++) {
        [_trackingEnemies addObject:[enemyManager spawnSoldierFactoryWithSpawnPoint:[enemyManager fourthCorner:(Corner)i]
                                                                          enemyType:kEnemyTypeBarrierFactory
                                                                         colorState:colorState
                                                                      queueInterval:(i * 0.1f)
                                                                    restingInterval:0.1f
                                                                   spawningInterval:0.1f
                                                                 spawnEmissionCount:3]];
        colorState = [ColorStateManager nextColorState:colorState];
    }
    
    if (center) {
        [_trackingEnemies addObject:[enemyManager spawnSoldierFactoryWithSpawnPoint:enemyManager._center
                                                                          enemyType:kEnemyTypeBarrierFactory
                                                                         colorState:colorState
                                                                      queueInterval:0.5f
                                                                    restingInterval:0.1f
                                                                   spawningInterval:0.1f
                                                                 spawnEmissionCount:3]];
    }
}

@end
