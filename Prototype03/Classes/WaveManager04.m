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
#import "WaveManager04.h"
#import "EnemyManager.h"
#import "Soldier.h"
#import "ColorStateManager.h"

//
// @implementation WaveManager04
//
@implementation WaveManager04

//
//
//
- (int)activate {
    if ([super activate] == 1) {
        return 1;
    }
    
    [self spawnBoxStartingWithWhite:[EnemyManager sharedEnemyManager]];
    return 0;
}

//
//
//
- (void)spawnBoxStartingWithWhite:(EnemyManager *)enemyManager {
    [self spawnBox:enemyManager withStartingColor:kColorStateWhite];
    self._enemiesDeactivatedAction = @selector(spawnBoxStartingWithBlack:);
}

//
//
//
- (void)spawnBoxStartingWithBlack:(EnemyManager *)enemyManager {
    [self spawnBox:enemyManager withStartingColor:kColorStateBlack];
    self._enemiesDeactivatedAction = @selector(spawnDiagonalStartingWithWhite:);
}

//
//
//
- (void)spawnDiagonalStartingWithWhite:(EnemyManager *)enemyManager {
    [self spawnDiagonal:enemyManager withStartingColor:kColorStateWhite reverse:false];
    self._enemiesDeactivatedAction = @selector(spawnDiagonalStartingWithBlack:);
}

//
//
//
- (void)spawnDiagonalStartingWithBlack:(EnemyManager *)enemyManager {
    [self spawnDiagonal:enemyManager withStartingColor:kColorStateBlack reverse:true];
    self._enemiesDeactivatedAction = @selector(spawnVerticalLinesStartingWithWhite:);
}

//
//
//
- (void)spawnVerticalLinesStartingWithWhite:(EnemyManager *)enemyManager {
    [self spawnVerticalLines:enemyManager withStartingColor:kColorStateWhite];
    self._enemiesDeactivatedAction = @selector(spawnVerticalLinesStartingWithBlack:);
}

//
//
//
- (void)spawnVerticalLinesStartingWithBlack:(EnemyManager *)enemyManager {
    [self spawnVerticalLines:enemyManager withStartingColor:kColorStateBlack];
    self._enemiesDeactivatedAction = @selector(spawnCircleStartingWithWhite:);
}

//
//
//
- (void)spawnCircleStartingWithWhite:(EnemyManager *)enemyManager {
    [self spawnCircle:enemyManager withStartingColor:kColorStateWhite];
    self._enemiesDeactivatedAction = @selector(spawnCircleStartingWithBlack:);
}

//
//
//
- (void)spawnCircleStartingWithBlack:(EnemyManager *)enemyManager {
    [self spawnCircle:enemyManager withStartingColor:kColorStateBlack];
    self._enemiesDeactivatedAction = @selector(spawnHorizontalLinesStartingWithWhite:);
}


//
//
//
- (void)spawnHorizontalLinesStartingWithWhite:(EnemyManager *)enemyManager {
    [self spawnHorizontalLines:enemyManager withStartingColor:kColorStateWhite];
    self._enemiesDeactivatedAction = @selector(spawnHorizontalLinesStartingWithBlack:);
}

//
//
//
- (void)spawnHorizontalLinesStartingWithBlack:(EnemyManager *)enemyManager {
    [self spawnHorizontalLines:enemyManager withStartingColor:kColorStateBlack];
    self._enemiesDeactivatedAction = @selector(spawnVerticalLines:);
}

//
//
//
- (void)spawnVerticalLines:(EnemyManager *)enemyManager {
    [self spawnWhiteAndBlackVerticalLines:enemyManager fromTop:true];
    
    _timerInterval = 4.5f;
    self._timerCompletedAction = @selector(spawnVerticalLines:);
}

//
//
//
- (void)spawnCircle:(EnemyManager *)enemyManager withStartingColor:(ColorState)startingColor {
    CGPoint vector = ccp(0.0f, 1.0f);
    float rotation = CC_DEGREES_TO_RADIANS(-(360 / 10));
    ColorState colorState = startingColor;
    for (int i=0; i < 10; i++) {
        CGPoint spawnPoint = ccpAdd(enemyManager._center, ccpMult(vector, [Soldier spawnSpacing] * 2.0f));
        [_trackingEnemies addObject:[enemyManager spawnSoldierWithSpawnPoint:spawnPoint
                                                                  colorState:colorState
                                                               queueInterval:0.0f
                                                                idleInterval:3.5f]];
        vector = ccpRotateByAngle(vector, cpvzero, rotation);
        colorState = [ColorStateManager nextColorState:colorState];
    }
}

//
//
//
- (void)spawnVerticalLines:(EnemyManager *)enemyManager withStartingColor:(ColorState)startingColor {
    // draw top and bottom border
    CGPoint spawnPoint;
    spawnPoint.x = [enemyManager thirdCorner:kCornerLeftBottom].x;
    spawnPoint.y = enemyManager._center.y + ([Soldier spawnSpacing] * 2);
    
    ColorState colorState = startingColor;
    
    for (int x=0; x < 2; x++) {
        spawnPoint.y = enemyManager._center.y + ([Soldier spawnSpacing] * 2);
        for (int y=0; y < 5; y++) {
            float queueInterval = y * 0.1f;
            [_trackingEnemies addObject:[enemyManager spawnSoldierWithSpawnPoint:spawnPoint
                                                                      colorState:colorState
                                                                   queueInterval:queueInterval
                                                                    idleInterval:3.5f - queueInterval]];
            spawnPoint.y -= [Soldier spawnSpacing];
            colorState = [ColorStateManager nextColorState:colorState];
        }
        
        spawnPoint.x = [enemyManager thirdCorner:kCornerRightBottom].x;
    }
}

//
//
//
- (void)spawnHorizontalLines:(EnemyManager *)enemyManager withStartingColor:(ColorState)startingColor {
    // draw top and bottom border
    CGPoint spawnPoint;
    spawnPoint.x = enemyManager._center.x - ([Soldier spawnSpacing] * 4);
    spawnPoint.y = CGRectGetMaxY(enemyManager._rect);
    
    ColorState colorState = startingColor;
    
    for (int y=0; y < 2; y++) {
        spawnPoint.x = enemyManager._center.x - ([Soldier spawnSpacing] * 4);
        for (int x=0; x < 9; x++) {
            float queueInterval = x * 0.1f;
            [_trackingEnemies addObject:[enemyManager spawnSoldierWithSpawnPoint:spawnPoint
                                                                      colorState:colorState
                                                                   queueInterval:queueInterval
                                                                    idleInterval:4.0f - queueInterval]];
            spawnPoint.x += [Soldier spawnSpacing];
            colorState = [ColorStateManager nextColorState:colorState];
        }
        
        spawnPoint.y = CGRectGetMinY(enemyManager._rect);
    }
}

//
//
//
- (void)spawnDiagonal:(EnemyManager *)enemyManager withStartingColor:(ColorState)startingColor reverse:(bool)reverse {
    
    float xDistance = CGRectGetWidth(enemyManager._rect) / 8.0f;
    float yDistance = -CGRectGetHeight(enemyManager._rect) / 8.0f;
    ColorState colorState = startingColor;
    CGPoint spawnPoint;
    spawnPoint.x = (reverse) ? CGRectGetMaxX(enemyManager._rect) : CGRectGetMinX(enemyManager._rect);
    spawnPoint.y = CGRectGetMaxY(enemyManager._rect);
    
    if (reverse) {
        xDistance *= -1;
    }
    
    for (int i=0; i < 9; i++) {
        float queueInterval = i * 0.1f;
        [_trackingEnemies addObject:[enemyManager spawnSoldierWithSpawnPoint:spawnPoint
                                                                  colorState:colorState
                                                               queueInterval:queueInterval
                                                                idleInterval:4.0f - queueInterval]];
        colorState = [ColorStateManager nextColorState:colorState];
        spawnPoint.x += xDistance;
        spawnPoint.y += yDistance;
    }
}

//
//
//
- (void)spawnBox:(EnemyManager *)enemyManager withStartingColor:(ColorState)startingColor {
    CGPoint spawnPoint = ccp(enemyManager._center.x - [Soldier diameter],
                             enemyManager._center.y - [Soldier diameter]);
    ColorState colorState = startingColor;
    
    for (int x=0; x < 2; x++) {
        for (int y=0; y < 2; y++) {
            [_trackingEnemies addObject:[enemyManager spawnSoldierWithSpawnPoint:spawnPoint
                                                                      colorState:colorState
                                                                   queueInterval:0.0f
                                                                    idleInterval:3.0f]];
            colorState = [ColorStateManager nextColorState:colorState];
            spawnPoint.y = enemyManager._center.y + [Soldier diameter];
        }
        
        spawnPoint.x = enemyManager._center.x + [Soldier diameter];
        spawnPoint.y = enemyManager._center.y - [Soldier diameter];
        colorState = [ColorStateManager nextColorState:colorState]; // flip it twice
    }
}

//
//
//
- (void)spawnWhiteAndBlackVerticalLines:(EnemyManager *)enemyManager fromTop:(bool)top {
    
    // if we should stop
    if (![self spawnCenterMix:enemyManager]) {
        return;
    }
    
    float bottomY = enemyManager._center.y - ([Soldier spawnSpacing] * 2);
    float topY = enemyManager._center.y + ([Soldier spawnSpacing] * 2);
    float startingY = top ? topY : bottomY;
    float yInterval = top ? -[Soldier spawnSpacing] : [Soldier spawnSpacing];
    
    // draw top and bottom border
    ColorState colorState = kColorStateWhite;
    CGPoint spawnPoint;
    spawnPoint.x = [enemyManager thirdCorner:kCornerLeftBottom].x;
    
    for (int x=0; x < 2; x++) {
        spawnPoint.y = startingY;
        for (int y=0; y < 5; y++) {
            float queueInterval = y * 0.1f;
            [enemyManager spawnSoldierWithSpawnPoint:spawnPoint
                                          colorState:colorState
                                       queueInterval:queueInterval
                                        idleInterval:2.0f - queueInterval];
            spawnPoint.y += yInterval;
        }
        
        spawnPoint.x = [enemyManager thirdCorner:kCornerRightBottom].x;
        colorState = [ColorStateManager nextColorState:colorState];
    }
}

//
//
//
- (bool)spawnCenterMix:(EnemyManager *)enemyManager {
    
    // if we are still waiting for them to destroy current black guy
    if ([_trackingEnemies count] > 0) {
        return true;
    }
    
    _spawnCenterCounter++;
    
    // see if we are done
    if (_spawnCenterCounter > 5) {
        self._timerCompletedAction = nil; // kill spawning the white guys
        _completedSpawn = true;
        return false;
    }
    
    // spawn soldiers
    CGPoint spawnPoint = ccp(enemyManager._center.x, enemyManager._center.y + [Soldier diameter]);
    [_trackingEnemies addObject:[enemyManager spawnSoldierWithSpawnPoint:spawnPoint
                                                              colorState:kColorStateWhite
                                                           queueInterval:0.0f
                                                            idleInterval:MAXFLOAT]];
    
    spawnPoint = ccp(enemyManager._center.x, enemyManager._center.y - [Soldier diameter]);
    [_trackingEnemies addObject:[enemyManager spawnSoldierWithSpawnPoint:spawnPoint
                                                              colorState:kColorStateBlack
                                                           queueInterval:0.0f
                                                            idleInterval:MAXFLOAT]];
    return true;
}
@end
