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
#import "WaveManager01.h"
#import "EnemyManager.h"
#import "Soldier.h"

//
// globals
//
static const int _verticalLineCount = 6;


//
// @implementation WaveManager01
//
@implementation WaveManager01

//
//
//
- (int)activate {
    if ([super activate] == 1) {
        return 1;
    }
    
    _verticalLineCounter = 0;
    _verticalLineSpacing = CGRectGetWidth([EnemyManager sharedEnemyManager]._rect) / (_verticalLineCount - 1);
    [self spawnBlack:[EnemyManager sharedEnemyManager]];
    
    return 0;
}

//
//
//
- (void)spawnBlack:(EnemyManager *)enemyManager {
    [_trackingEnemies addObject:[enemyManager spawnSoldierWithSpawnPoint:ccp(enemyManager._center.x, CGRectGetMaxY(enemyManager._rect))
                                                              colorState:kColorStateBlack
                                                           queueInterval:0.0f
                                                            idleInterval:2.0f]];
    
    self._enemiesDeactivatedAction = @selector(spawnWhiteSmileyFace:);
}

//
//
//
- (void)spawnWhiteSmileyFace:(EnemyManager *)enemyManager {
    float idleInterval = 2.0f;
    
    // draw mouth
    CGPoint spawnPoint;
    CGPoint vector = ccpNormalize(ccp(0.0f, -1.0f));
    int smileCount = 6;
    float angle = -90.0f;
    float angleIncrement = 180.0f / (float)(smileCount - 1);
    for (int x=0; x < smileCount; x++) {
        CGPoint rotatedVector = ccpRotateByAngle(vector, cpvzero, CC_DEGREES_TO_RADIANS(angle));
        spawnPoint = ccpAdd(enemyManager._center, ccpMult(rotatedVector, 60.0f));
        [_trackingEnemies addObject:[enemyManager spawnSoldierWithSpawnPoint:spawnPoint
                                                                  colorState:kColorStateWhite
                                                               queueInterval:0.0f
                                                                idleInterval:idleInterval]];
        angle += angleIncrement;
    }
    
    // draw eyes
    spawnPoint.y = CGRectGetMaxY(enemyManager._rect) - [Soldier radius];
    spawnPoint.x = enemyManager._center.x - [Soldier spawnSpacing];
    [_trackingEnemies addObject:[enemyManager spawnSoldierWithSpawnPoint:spawnPoint
                                                              colorState:kColorStateWhite
                                                           queueInterval:0.0f
                                                            idleInterval:idleInterval]];
    
    spawnPoint.x = enemyManager._center.x + [Soldier spawnSpacing];
    [_trackingEnemies addObject:[enemyManager spawnSoldierWithSpawnPoint:spawnPoint
                                                              colorState:kColorStateWhite
                                                           queueInterval:0.0f
                                                            idleInterval:idleInterval]];
    
    self._enemiesDeactivatedAction = @selector(spawnBlackInX:);
}

//
//
//
- (void)spawnBlackInX:(EnemyManager *)enemyManager {
    [self spawnX:enemyManager withColor:kColorStateBlack];
    self._enemiesDeactivatedAction = @selector(spawnWhiteInX:);
}

//
//
//
- (void)spawnWhiteInX:(EnemyManager *)enemyManager {
    [self spawnX:enemyManager withColor:kColorStateWhite];
    self._enemiesDeactivatedAction = @selector(spawnBlackInCircle:);
}

//
//
//
- (void)spawnBlackInCircle:(EnemyManager *)enemyManager {
    [self spawnCircle:enemyManager withColor:kColorStateBlack];
    self._enemiesDeactivatedAction = @selector(spawnWhiteInCircle:);
}

//
//
//
- (void)spawnWhiteInCircle:(EnemyManager *)enemyManager {
    [self spawnCircle:enemyManager withColor:kColorStateWhite];
    self._enemiesDeactivatedAction = @selector(spawnBlackLineAlongTop:);
}

//
//
//
- (void)spawnBlackLineAlongTop:(EnemyManager *)enemyManager {
    
    CGPoint spawnPoint = [enemyManager corner:kCornerLeftTop];
    CGPoint vector = ccpMult(ccp(1.0f, 0.0f), [Soldier spawnSpacing]);
    for (int i=0; i < 10; i++) {
        [_trackingEnemies addObject:[enemyManager spawnSoldierWithSpawnPoint:spawnPoint
                                                                  colorState:kColorStateBlack
                                                               queueInterval:(i * 0.1f)
                                                                idleInterval:2.0f]];
        spawnPoint = ccpAdd(spawnPoint, vector);
    }
    
    self._enemiesDeactivatedAction = @selector(spawnWhiteLineAlongBottom:);
}

//
//
//
- (void)spawnWhiteLineAlongBottom:(EnemyManager *)enemyManager {
    
    CGPoint spawnPoint = [enemyManager corner:kCornerRightBottom];
    CGPoint vector = ccpMult(ccp(-1.0f, 0.0f), [Soldier spawnSpacing]);
    for (int i=0; i < 10; i++) {
        [_trackingEnemies addObject:[enemyManager spawnSoldierWithSpawnPoint:spawnPoint
                                                                  colorState:kColorStateWhite
                                                               queueInterval:(i * 0.1f)
                                                                idleInterval:2.0f]];
        spawnPoint = ccpAdd(spawnPoint, vector);
    }
    
    self._enemiesDeactivatedAction = @selector(spawnBlackSineWave:);
}

//
//
//
- (void)spawnBlackSineWave:(EnemyManager *)enemyManager {
    [self spawnSineWaveWithEnemyManager:enemyManager color:kColorStateBlack reverse:false];
    self._enemiesDeactivatedAction = @selector(spawnWhiteBox:);
}

//
//
//
- (void)spawnWhiteBox:(EnemyManager *)enemyManager {
    float idleInterval = 3.0f;
    float queueInterval = 0.0f;
    float startingX = enemyManager._center.x - ([Soldier spawnSpacing] * 2);
    float endingX = enemyManager._center.x + ([Soldier spawnSpacing] * 2);
    
    // draw top and bottom border
    CGPoint spawnPoint;
    spawnPoint.y = CGRectGetMaxY(enemyManager._rect);
    for (int y=0; y < 2; y++) {
        spawnPoint.x = startingX;
        for (int x=0; x < 5; x++) {
            [_trackingEnemies addObject:[enemyManager spawnSoldierWithSpawnPoint:spawnPoint
                                                                      colorState:kColorStateWhite
                                                                   queueInterval:queueInterval
                                                                    idleInterval:idleInterval]];
            spawnPoint.x += [Soldier spawnSpacing];
            queueInterval += 0.1f;
        }
        
        spawnPoint.y = CGRectGetMinY(enemyManager._rect);
    }
    
    // draw side borders
    spawnPoint.x = startingX;
    for (int x=0; x < 2; x++) {
        spawnPoint.y = enemyManager._center.y - [Soldier spawnSpacing];
        for (int y=0; y < 3; y++) {
            [_trackingEnemies addObject:[enemyManager spawnSoldierWithSpawnPoint:spawnPoint
                                                                      colorState:kColorStateWhite
                                                                   queueInterval:queueInterval
                                                                    idleInterval:idleInterval]];
            spawnPoint.y += [Soldier spawnSpacing];
            queueInterval += 0.1f;
        }
        
        spawnPoint.x = endingX;
    }
    
    self._enemiesDeactivatedAction = @selector(spawnBlackReverseSineWave:);
}

//
//
//
- (void)spawnBlackReverseSineWave:(EnemyManager *)enemyManager {
    [self spawnSineWaveWithEnemyManager:enemyManager color:kColorStateBlack reverse:true];
    self._enemiesDeactivatedAction = @selector(spawnVerticalLine:);
}

//
//
//
- (void)spawnVerticalLine:(EnemyManager *)enemyManager {
    
    bool even = !(_verticalLineCounter % 2);
    
    [self spawnVerticalLineWithEnemyManager:enemyManager
                                      color:(even) ? kColorStateWhite : kColorStateBlack
                                     xCoord:CGRectGetMinX(enemyManager._rect) + (_verticalLineSpacing * _verticalLineCounter)
                                    reverse:!even];
    
    self._enemiesDeactivatedAction = @selector(spawnVerticalLine:);
    _verticalLineCounter++;
    if (_verticalLineCounter >= 6) {
        _completedSpawn = true;
        _enemiesDeactivatedAction = nil;
    }
}

//
//
//
- (void)spawnX:(EnemyManager *)enemyManager withColor:(ColorState)colorState {
    float idleInterval = 3.0f;
    float addedSpacing = 10.0f;
    [_trackingEnemies addObject:[enemyManager spawnSoldierWithSpawnPoint:enemyManager._center
                                                              colorState:colorState
                                                           queueInterval:0.0f
                                                            idleInterval:idleInterval]];
    CGPoint vector = ccpNormalize(ccp(-1.0f, 1.0f));
    for (int i=0; i < 2; i++) {
        for (int x=1; x <= 2; x++) {
            CGPoint spawnPoint = ccpAdd(enemyManager._center, ccpMult(vector, (addedSpacing + [Soldier spawnSpacing]) * x));
            [_trackingEnemies addObject:[enemyManager spawnSoldierWithSpawnPoint:spawnPoint
                                                                      colorState:colorState
                                                                   queueInterval:0.0f
                                                                    idleInterval:idleInterval]];
        }
        vector = ccpNeg(vector);
    }
    
    vector = ccpNormalize(ccp(-1.0f, -1.0f));
    for (int i=0; i < 2; i++) {
        for (int x=1; x <= 2; x++) {
            CGPoint spawnPoint = ccpAdd(enemyManager._center, ccpMult(vector, (addedSpacing + [Soldier spawnSpacing]) * x));
            [_trackingEnemies addObject:[enemyManager spawnSoldierWithSpawnPoint:spawnPoint
                                                                      colorState:colorState
                                                                   queueInterval:0.0f
                                                                    idleInterval:idleInterval]];
        }
        vector = ccpNeg(vector);
    }
}

//
//
//
- (void)spawnCircle:(EnemyManager *)enemyManager withColor:(ColorState)colorState {
    float idleInterval = 3.0f;
    [_trackingEnemies addObject:[enemyManager spawnSoldierWithSpawnPoint:enemyManager._center
                                                              colorState:colorState
                                                           queueInterval:0.0f
                                                            idleInterval:idleInterval]];
    
    CGPoint vector = ccp(0.0f, 1.0f);
    float rotation = CC_DEGREES_TO_RADIANS(-(360 / 8));
    for (int i=0; i < 8; i++) {
        CGPoint spawnPoint = ccpAdd(enemyManager._center, ccpMult(vector, [Soldier spawnSpacing] * 2.0f));
        [_trackingEnemies addObject:[enemyManager spawnSoldierWithSpawnPoint:spawnPoint
                                                                  colorState:colorState
                                                               queueInterval:0.0f
                                                                idleInterval:idleInterval]];
        vector = ccpRotateByAngle(vector, cpvzero, rotation);
    }
}

//
//
//
- (void)spawnSineWaveWithEnemyManager:(EnemyManager *)enemyManager color:(ColorState)colorState reverse:(bool)reverse {
    int enemyCount = 12;
    
    float cosInterval = (2 * M_PI) / enemyCount;
    float cosAngle = 0;
    float amplitude = CGRectGetHeight(enemyManager._rect) / 2.0f;
    
    float xCoord = (reverse) ? [enemyManager corner:kCornerRightTop].x : [enemyManager corner:kCornerLeftTop].x;
    float xInterval = CGRectGetWidth(enemyManager._rect) / enemyCount;
    
    if (reverse) {
        xInterval *= -1;
    }
    
    for (int i=0; i < enemyCount; i++) {
        float yCoord = CGRectGetMidY(enemyManager._rect) + (amplitude * sinf(cosAngle));
        [_trackingEnemies addObject:[enemyManager spawnSoldierWithSpawnPoint:ccp(xCoord, yCoord)
                                                                  colorState:colorState
                                                               queueInterval:(i * 0.1f)
                                                                idleInterval:2.0f]];
        cosAngle += cosInterval;
        xCoord += xInterval;
    }
}

//
//
//
- (void)spawnVerticalLineWithEnemyManager:(EnemyManager *)enemyManager
                                    color:(ColorState)colorState
                                   xCoord:(float)xCoord
                                  reverse:(bool)reverse
{
    CGPoint spawnPoint;
    spawnPoint.x = xCoord;
    spawnPoint.y = (reverse) ? CGRectGetMinY(enemyManager._rect) : CGRectGetMaxY(enemyManager._rect);
    for (int i=0; i < 5; i++) {
        [_trackingEnemies addObject:[enemyManager spawnSoldierWithSpawnPoint:spawnPoint
                                                                  colorState:colorState
                                                               queueInterval:(i * 0.1f)
                                                                idleInterval:2.0f]];
        spawnPoint.y += (reverse) ? [Soldier spawnSpacing] : -[Soldier spawnSpacing];
    }
}

@end
