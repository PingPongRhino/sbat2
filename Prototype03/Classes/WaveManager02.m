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
#import "WaveManager02.h"
#import "EnemyManager.h"
#import "Soldier.h"

//
// @implementation WaveManager02
//
@implementation WaveManager02

//
//
//
- (int)activate {
    if ([super activate] == 1) {
        return 1;
    }
    
    _spawnBlackCenterCounter = 0;
    _spawnWhiteVerticalLinesFromTop = false;
    [self spawnTopHorizontalLineWhiteInside:[EnemyManager sharedEnemyManager]];
    return 0;
}

//
//
//
- (void)spawnTopHorizontalLineWhiteInside:(EnemyManager *)enemyManager {
    [self spawnHorizontalLine:enemyManager
                  insideColor:kColorStateWhite
                 outsideColor:kColorStateBlack
                       yCoord:[enemyManager fourthCorner:kCornerLeftTop].y];
    self._enemiesDeactivatedAction = @selector(spawnCenterHorizontalLineBlackInside:);
}

//
//
//
- (void)spawnCenterHorizontalLineBlackInside:(EnemyManager *)enemyManager {
    [self spawnHorizontalLine:enemyManager
                  insideColor:kColorStateBlack
                 outsideColor:kColorStateWhite
                       yCoord:enemyManager._center.y];
    self._enemiesDeactivatedAction = @selector(spawnBottomHorizontalLineWhiteInside:);
}

//
//
//
- (void)spawnBottomHorizontalLineWhiteInside:(EnemyManager *)enemyManager {
    [self spawnHorizontalLine:enemyManager
                  insideColor:kColorStateWhite
                 outsideColor:kColorStateBlack
                       yCoord:[enemyManager fourthCorner:kCornerLeftBottom].y];
    self._enemiesDeactivatedAction = @selector(spawnXWithBlackCenter:);
}

//
//
//
- (void)spawnXWithBlackCenter:(EnemyManager *)enemyManager {
    [self spawnX:enemyManager insideColor:kColorStateBlack outsideColor:kColorStateWhite];
    self._enemiesDeactivatedAction = @selector(spawnXWithWhiteCenter:);
}

//
//
//
- (void)spawnXWithWhiteCenter:(EnemyManager *)enemyManager {
    [self spawnX:enemyManager insideColor:kColorStateWhite outsideColor:kColorStateBlack];
    self._enemiesDeactivatedAction = @selector(spawnWhiteCircleWithBlackCenter:);
}

//
//
//
- (void)spawnWhiteCircleWithBlackCenter:(EnemyManager *)enemyManager {
    [self spawnCircleWithEnemyManager:enemyManager outsideColor:kColorStateWhite insideColor:kColorStateBlack];
    self._enemiesDeactivatedAction = @selector(spawnBlackCircleWithWhiteCenter:);
}

//
//
//
- (void)spawnBlackCircleWithWhiteCenter:(EnemyManager *)enemyManager {
    [self spawnCircleWithEnemyManager:enemyManager outsideColor:kColorStateBlack insideColor:kColorStateWhite];
    self._enemiesDeactivatedAction = @selector(spawnWhiteFourCenterProtectedByBlack:);
}

//
//
//
- (void)spawnWhiteFourCenterProtectedByBlack:(EnemyManager *)enemyManager {
    [self spawnFourCenterProtected:enemyManager insideColor:kColorStateWhite outsideColor:kColorStateBlack];
    self._enemiesDeactivatedAction = @selector(spawnBlackFourCenterProtectedByWhite:);
}

//
//
//
- (void)spawnBlackFourCenterProtectedByWhite:(EnemyManager *)enemyManager {
    [self spawnFourCenterProtected:enemyManager insideColor:kColorStateBlack outsideColor:kColorStateWhite];
    self._enemiesDeactivatedAction = @selector(spawnWhiteVerticalLines:);
}

//
//
//
- (void)spawnWhiteVerticalLines:(EnemyManager *)enemyManager {
    _spawnWhiteVerticalLinesFromTop = !_spawnWhiteVerticalLinesFromTop;
    [self spawnWhiteVerticalLines:enemyManager fromTop:_spawnWhiteVerticalLinesFromTop];
    
    _timerInterval = 3.5f;
    self._timerCompletedAction = @selector(spawnWhiteVerticalLines:);
}

//
//
//
- (void)spawnHorizontalLine:(EnemyManager *)enemyManager
                insideColor:(ColorState)insideColor
               outsideColor:(ColorState)outsideColor
                     yCoord:(float)yCoord
{
    CGPoint spawnPoint = ccp(enemyManager._center.x - ([Soldier spawnSpacing] * 4.5f), yCoord);
    ColorState currentColor = outsideColor;
    float queueInterval = 0.0f;
    for (int i=0; i < 10; i++) {
        
        if (i >= 4 && i <= 5) {
            currentColor = insideColor;
            queueInterval = 0.2f;
        }
        else {
            currentColor = outsideColor;
            queueInterval = 0.0f;
        }
        
        [_trackingEnemies addObject:[enemyManager spawnSoldierWithSpawnPoint:spawnPoint
                                                                  colorState:currentColor
                                                               queueInterval:queueInterval
                                                                idleInterval:3.0f]];
        spawnPoint.x += [Soldier spawnSpacing];
    }
}

//
//
//
- (void)spawnX:(EnemyManager *)enemyManager
   insideColor:(ColorState)insideColor
  outsideColor:(ColorState)outsideColor
{
    float idleInterval = 2.0f;
    float addedSpacing = 10.0f;
    [_trackingEnemies addObject:[enemyManager spawnSoldierWithSpawnPoint:enemyManager._center
                                                              colorState:insideColor
                                                           queueInterval:0.0f
                                                            idleInterval:idleInterval]];
    CGPoint vector = ccpNormalize(ccp(-1.0f, 1.0f));
    for (int i=0; i < 2; i++) {
        for (int x=1; x <= 2; x++) {
            CGPoint spawnPoint = ccpAdd(enemyManager._center, ccpMult(vector, (addedSpacing + [Soldier spawnSpacing]) * x));
            [_trackingEnemies addObject:[enemyManager spawnSoldierWithSpawnPoint:spawnPoint
                                                                      colorState:outsideColor
                                                                   queueInterval:(x * 0.1f)
                                                                    idleInterval:idleInterval]];
        }
        vector = ccpNeg(vector);
    }
    
    vector = ccpNormalize(ccp(-1.0f, -1.0f));
    for (int i=0; i < 2; i++) {
        for (int x=1; x <= 2; x++) {
            CGPoint spawnPoint = ccpAdd(enemyManager._center, ccpMult(vector, (addedSpacing + [Soldier spawnSpacing]) * x));
            [_trackingEnemies addObject:[enemyManager spawnSoldierWithSpawnPoint:spawnPoint
                                                                      colorState:outsideColor
                                                                   queueInterval:(x * 0.1f)
                                                                    idleInterval:idleInterval]];
        }
        vector = ccpNeg(vector);
    }
}

//
//
//
- (void)spawnCircleWithEnemyManager:(EnemyManager *)enemyManager
                       outsideColor:(ColorState)outsideColor
                        insideColor:(ColorState)insideColor
{
                        
    float idleInterval = 2.0f;
    [_trackingEnemies addObject:[enemyManager spawnSoldierWithSpawnPoint:enemyManager._center
                                                              colorState:insideColor
                                                           queueInterval:0.0f
                                                            idleInterval:idleInterval]];
    
    CGPoint vector = ccp(0.0f, 1.0f);
    float rotation = CC_DEGREES_TO_RADIANS(-(360 / 10));
    for (int i=0; i < 10; i++) {
        CGPoint spawnPoint = ccpAdd(enemyManager._center, ccpMult(vector, [Soldier spawnSpacing] * 2.0f));
        [_trackingEnemies addObject:[enemyManager spawnSoldierWithSpawnPoint:spawnPoint
                                                                  colorState:outsideColor
                                                               queueInterval:0.0f
                                                                idleInterval:idleInterval]];
        vector = ccpRotateByAngle(vector, cpvzero, rotation);
    }
}

//
//
//
- (void)spawnFourCenterProtected:(EnemyManager *)enemyManager
                     insideColor:(ColorState)insideColor
                    outsideColor:(ColorState)outsideColor
{
    float idleInterval = 2.0f;
    
    // spawn four center guys
    float centerSpacing = 15.0f;
    CGPoint spawnPoint;
    spawnPoint.y = enemyManager._center.y - centerSpacing;
    
    for (int y=0; y < 2; y++) {
        
        spawnPoint.x = enemyManager._center.x - centerSpacing;
        
        for (int x=0; x < 2; x++) {
            [_trackingEnemies addObject:[enemyManager spawnSoldierWithSpawnPoint:spawnPoint
                                                                      colorState:insideColor
                                                                   queueInterval:0.3f
                                                                    idleInterval:idleInterval]];
            spawnPoint.x = enemyManager._center.x + centerSpacing;
        }
        spawnPoint.y = enemyManager._center.y + centerSpacing;
    }
    
    // spawn lines
    idleInterval = 3.0f;
    CGPoint spawnPointLeft = ccp([enemyManager fourthCorner:kCornerLeftBottom].x,
                                 enemyManager._center.y + ([Soldier spawnSpacing] * 2));
    CGPoint spawnPointRight = ccp([enemyManager fourthCorner:kCornerRightBottom].x,
                                  enemyManager._center.y - ([Soldier spawnSpacing] * 2));
    
    for (int i=0; i < 5; i++) {
        [_trackingEnemies addObject:[enemyManager spawnSoldierWithSpawnPoint:spawnPointLeft
                                                                  colorState:outsideColor
                                                               queueInterval:(i * 0.1f)
                                                                idleInterval:idleInterval]];
        
        [_trackingEnemies addObject:[enemyManager spawnSoldierWithSpawnPoint:spawnPointRight
                                                                  colorState:outsideColor
                                                               queueInterval:(i * 0.1f)
                                                                idleInterval:idleInterval]];
        
        spawnPointLeft.y -= [Soldier spawnSpacing];
        spawnPointRight.y += [Soldier spawnSpacing];
    }
}

//
//
//
- (void)spawnWhiteVerticalLines:(EnemyManager *)enemyManager fromTop:(bool)top {
    
    // if we should stop
    if (![self spawnBlackInCenter:enemyManager]) {
        return;
    }
    
    float bottomY = enemyManager._center.y - ([Soldier spawnSpacing] * 2);
    float topY = enemyManager._center.y + ([Soldier spawnSpacing] * 2);
    float startingY = top ? topY : bottomY;
    float yInterval = top ? -[Soldier spawnSpacing] : [Soldier spawnSpacing];
    
    // draw top and bottom border
    CGPoint spawnPoint;
    spawnPoint.x = [enemyManager thirdCorner:kCornerLeftBottom].x;
    
    for (int x=0; x < 2; x++) {
        spawnPoint.y = startingY;
        for (int y=0; y < 5; y++) {
            float queueInterval = y * 0.1f;
            [enemyManager spawnSoldierWithSpawnPoint:spawnPoint
                                           colorState:kColorStateWhite
                                        queueInterval:queueInterval
                                         idleInterval:1.0f - queueInterval];
            spawnPoint.y += yInterval;
        }
        
        spawnPoint.x = [enemyManager thirdCorner:kCornerRightBottom].x;
    }
}

//
//
//
- (bool)spawnBlackInCenter:(EnemyManager *)enemyManager {
    
    // if we are still waiting for them to destroy current black guy
    if ([_trackingEnemies count] > 0) {
        return true;
    }
    
    _spawnBlackCenterCounter++;
    
    // see if we are done
    if (_spawnBlackCenterCounter > 5) {
        self._timerCompletedAction = nil; // kill spawning the white guys
        _completedSpawn = true;
        return false;
    }
    
    // spawn soldier
    [_trackingEnemies addObject:[enemyManager spawnSoldierWithSpawnPoint:enemyManager._center
                                                              colorState:kColorStateBlack
                                                           queueInterval:0.0f
                                                            idleInterval:MAXFLOAT]];
    return true;
}

@end
