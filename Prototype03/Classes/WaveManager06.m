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
#import "WaveManager06.h"
#import "EnemyManager.h"
#import "SoldierFactory.h"
#import "ColorStateManager.h"

//
// @implementation WaveManager06
//
@implementation WaveManager06

//
//
//
- (int)activate {
    if ([super activate] == 1) {
        return 1;
    }
    
    [self spawnCenterTwoStartingWithWhite:[EnemyManager sharedEnemyManager]];
    return 0;
}

//
//
//
- (void)spawnCenterTwoStartingWithWhite:(EnemyManager *)enemyManager {
    [self spawnCenterTwo:enemyManager startingColor:kColorStateWhite];
    self._enemiesDeactivatedAction = @selector(spawnCenterTwoStartingWithBlack:);
}

//
//
//
- (void)spawnCenterTwoStartingWithBlack:(EnemyManager *)enemyManager {
    [self spawnCenterTwo:enemyManager startingColor:kColorStateBlack];
    self._enemiesDeactivatedAction = @selector(spawnCenterFourStartingWithWhite:);
}

//
//
//
- (void)spawnCenterFourStartingWithWhite:(EnemyManager *)enemyManager {
    [self spawnCenterFour:enemyManager startingColor:kColorStateWhite];
    self._enemiesDeactivatedAction = @selector(spawnCenterFourStartingWithBlack:);
}

//
//
//
- (void)spawnCenterFourStartingWithBlack:(EnemyManager *)enemyManager {
    [self spawnCenterFour:enemyManager startingColor:kColorStateBlack];
    self._enemiesDeactivatedAction = @selector(spawnCenterEightStartingWithWhite:);
}

//
//
//
- (void)spawnCenterEightStartingWithWhite:(EnemyManager *)enemyManager {
    [self spawnCenterEight:enemyManager startingColor:kColorStateWhite];
    self._enemiesDeactivatedAction = @selector(spawnCenterEightStartingWithBlack:);
}

//
//
//
- (void)spawnCenterEightStartingWithBlack:(EnemyManager *)enemyManager {
    [self spawnCenterEight:enemyManager startingColor:kColorStateBlack];
    self._enemiesDeactivatedAction = @selector(spawnTwoInCornerStartingWithWhite:);
}

//
//
//
- (void)spawnTwoInCornerStartingWithWhite:(EnemyManager *)enemyManager {
    [self spawnTwoInCorners:enemyManager startingColor:kColorStateWhite startingCorner:kCornerLeftTop];
    self._enemiesDeactivatedAction = @selector(spawnTwoInCornerStartingWithBlack:);
}

//
//
//
- (void)spawnTwoInCornerStartingWithBlack:(EnemyManager *)enemyManager {
    [self spawnTwoInCorners:enemyManager startingColor:kColorStateBlack startingCorner:kCornerRightTop];
    self._enemiesDeactivatedAction = @selector(spawnFourInCornersStartingWithWhite:);
}

//
//
//
- (void)spawnFourInCornersStartingWithWhite:(EnemyManager *)enemyManager {
    [self spawnFourInCorners:enemyManager startingColor:kColorStateWhite];
    self._enemiesDeactivatedAction = @selector(spawnFourInCornersStartingWithBlack:);
    
}

//
//
//
- (void)spawnFourInCornersStartingWithBlack:(EnemyManager *)enemyManager {
    [self spawnFourInCorners:enemyManager startingColor:kColorStateBlack];
    _completedSpawn = true;
}

//
//
//
- (void)spawnCenterTwo:(EnemyManager *)enemyManager startingColor:(ColorState)startingColor {
    float spacing = [SoldierFactory radius] + 5.0f;
    ColorState colorState = startingColor;
    CGPoint spawnPoint = ccp(enemyManager._center.x,
                             enemyManager._center.y - spacing);
    
    for (int y=0; y < 2; y++) {
        [_trackingEnemies addObject:[enemyManager spawnSoldierFactoryWithSpawnPoint:spawnPoint
                                                                          enemyType:kEnemyTypeSoldierFactory
                                                                         colorState:colorState
                                                                      queueInterval:0.0f
                                                                    restingInterval:1.0f
                                                                   spawningInterval:0.5f
                                                                 spawnEmissionCount:5]];
        spawnPoint.y = enemyManager._center.y + spacing;
        colorState = [ColorStateManager nextColorState:colorState];
    }
}

//
//
//
- (void)spawnCenterFour:(EnemyManager *)enemyManager startingColor:(ColorState)startingColor {
    
    float spacing = [SoldierFactory radius] + 5.0f;
    
    CGPoint spawnPoint = ccp(enemyManager._center.x - spacing,
                             enemyManager._center.y - spacing);
    ColorState colorState = startingColor;
    
    for (int y=0; y < 2; y++) {
        spawnPoint.x = enemyManager._center.x - spacing;
        
        for (int x=0; x < 2; x++) {
            [_trackingEnemies addObject:[enemyManager spawnSoldierFactoryWithSpawnPoint:spawnPoint
                                                                              enemyType:kEnemyTypeSoldierFactory
                                                                             colorState:colorState
                                                                          queueInterval:0.0f
                                                                        restingInterval:1.0f
                                                                       spawningInterval:0.5f
                                                                     spawnEmissionCount:5]];
            
            spawnPoint.x = enemyManager._center.x + spacing;
        }
        
        colorState = [ColorStateManager nextColorState:colorState];
        spawnPoint.y = enemyManager._center.y + spacing;
    }
}

//
//
//
- (void)spawnCenterEight:(EnemyManager *)enemyManager startingColor:(ColorState)startingColor {
    float ySpacing = [SoldierFactory radius] + 5.0f;
    float xSpacing = CGRectGetWidth(enemyManager._rect) / 5.0f;
    CGPoint spawnPoint = ccp(CGRectGetMinX(enemyManager._rect) + xSpacing, enemyManager._center.y - ySpacing);
    ColorState colorState = startingColor;
    
    for (int y=0; y < 2; y++) {
        for (int x=0; x < 4; x++) {
            [_trackingEnemies addObject:[enemyManager spawnSoldierFactoryWithSpawnPoint:spawnPoint
                                                                              enemyType:kEnemyTypeSoldierFactory
                                                                             colorState:colorState
                                                                          queueInterval:(x * 0.1f)
                                                                        restingInterval:2.0f
                                                                       spawningInterval:1.0f
                                                                     spawnEmissionCount:3]];
            spawnPoint.x += xSpacing;
        }
        
        spawnPoint.x = CGRectGetMinX(enemyManager._rect) + xSpacing;
        spawnPoint.y = enemyManager._center.y + ySpacing;
        colorState = [ColorStateManager nextColorState:colorState];
    }
}

//
//
//
- (void)spawnTwoInCorners:(EnemyManager *)enemyManager startingColor:(ColorState)startingColor startingCorner:(Corner)startingCorner {
    [_trackingEnemies addObject:[enemyManager spawnSoldierFactoryWithSpawnPoint:[enemyManager fourthCorner:startingCorner]
                                                                      enemyType:kEnemyTypeSoldierFactory
                                                                     colorState:startingColor
                                                                  queueInterval:0.0f
                                                                restingInterval:1.0f
                                                               spawningInterval:0.5f
                                                             spawnEmissionCount:5]];
    
    Corner corner = (startingCorner == kCornerLeftTop) ? kCornerRightBottom : kCornerLeftBottom;
    [_trackingEnemies addObject:[enemyManager spawnSoldierFactoryWithSpawnPoint:[enemyManager fourthCorner:corner]
                                                                      enemyType:kEnemyTypeSoldierFactory
                                                                     colorState:[ColorStateManager nextColorState:startingColor]
                                                                  queueInterval:0.0f
                                                                restingInterval:1.0f
                                                               spawningInterval:0.5f
                                                             spawnEmissionCount:5]];
}

//
//
//
- (void)spawnFourInCorners:(EnemyManager *)enemyManager startingColor:(ColorState)startingColor {
    ColorState colorState = startingColor;
    for (int i=0; i < kCornerCount; i++) {
        [_trackingEnemies addObject:[enemyManager spawnSoldierFactoryWithSpawnPoint:[enemyManager fourthCorner:(Corner)i]
                                                                          enemyType:kEnemyTypeSoldierFactory
                                                                         colorState:colorState
                                                                      queueInterval:(i * 0.1f)
                                                                    restingInterval:1.0f
                                                                   spawningInterval:1.0f
                                                                 spawnEmissionCount:3]];
        colorState = [ColorStateManager nextColorState:colorState];
    }
}



@end
