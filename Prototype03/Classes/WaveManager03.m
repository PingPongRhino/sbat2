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
#import "WaveManager03.h"
#import "EnemyManager.h"
#import "Soldier.h"
#import "ColorStateManager.h"

//
// @implementation WaveManager03
//
@implementation WaveManager03

//
//
//
- (int)activate {
    if ([super activate] == 1) {
        return 1;
    }
    
    _spawnBlackCenterCounter = 0;
    _spawnLinesFromTop = false;
    [self spawnBlackAndWhiteOppositeEachOther:[EnemyManager sharedEnemyManager]];
    return 0;
}

//
//
//
- (void)spawnBlackAndWhiteOppositeEachOther:(EnemyManager *)enemyManager {
    [self spawnBlackAndWhiteOppositeEachOther:enemyManager withBlackOnLeft:true];
    self._enemiesDeactivatedAction = @selector(spawnBlackAndWhiteCrosses:);
}

//
//
//
- (void)spawnBlackAndWhiteCrosses:(EnemyManager *)enemyManager {
    [self spawnCrosses:enemyManager leftColor:kColorStateBlack rightColor:kColorStateWhite];
    self._enemiesDeactivatedAction = @selector(spawnBlackAndWhiteSlashes:);
}

//
//
//
- (void)spawnBlackAndWhiteSlashes:(EnemyManager *)enemyManager {
    [self spawnSlashes:enemyManager leftColor:kColorStateBlack rightColor:kColorStateWhite startAtTop:true];
    self._enemiesDeactivatedAction = @selector(spawnBlackAndWhiteSlashesInReverse:);
}

//
//
//
- (void)spawnBlackAndWhiteSlashesInReverse:(EnemyManager *)enemyManager {
    [self spawnSlashes:enemyManager leftColor:kColorStateBlack rightColor:kColorStateWhite startAtTop:false];
    self._enemiesDeactivatedAction = @selector(spawnBlackAndWhiteOppositeArcs:);
}

//
//
//
- (void)spawnBlackAndWhiteOppositeArcs:(EnemyManager *)enemyManager {
    [self spawnArcs:enemyManager leftColor:kColorStateBlack rightColor:kColorStateWhite centerPointInside:false];
    self._enemiesDeactivatedAction = @selector(spawnBlackAndWhiteArcsFromInside:);
}

//
//
//
- (void)spawnBlackAndWhiteArcsFromInside:(EnemyManager *)enemyManager {
    [self spawnArcs:enemyManager leftColor:kColorStateBlack rightColor:kColorStateWhite centerPointInside:true];
    self._enemiesDeactivatedAction = @selector(spawnWhiteAndBlackOppositeEachOther:);
}

//
//
//
- (void)spawnWhiteAndBlackOppositeEachOther:(EnemyManager *)enemyManager {
    [self spawnBlackAndWhiteOppositeEachOther:enemyManager withBlackOnLeft:false];
    self._enemiesDeactivatedAction = @selector(spawnWhiteAndBlackCrosses:);
}

//
//
//
- (void)spawnWhiteAndBlackCrosses:(EnemyManager *)enemyManager {
    [self spawnCrosses:enemyManager leftColor:kColorStateWhite rightColor:kColorStateBlack];
    self._enemiesDeactivatedAction = @selector(spawnWhiteAndBlackSlashes:);
}

//
//
//
- (void)spawnWhiteAndBlackSlashes:(EnemyManager *)enemyManager {
    [self spawnSlashes:enemyManager leftColor:kColorStateWhite rightColor:kColorStateBlack startAtTop:true];
    self._enemiesDeactivatedAction = @selector(spawnWhiteAndBlackSlashesInReverse:);
}

//
//
//
- (void)spawnWhiteAndBlackSlashesInReverse:(EnemyManager *)enemyManager {
    [self spawnSlashes:enemyManager leftColor:kColorStateWhite rightColor:kColorStateBlack startAtTop:false];
    self._enemiesDeactivatedAction = @selector(spawnWhiteAndBlackOppositeArcs:);
}

//
//
//
- (void)spawnWhiteAndBlackOppositeArcs:(EnemyManager *)enemyManager {
    [self spawnArcs:enemyManager leftColor:kColorStateWhite rightColor:kColorStateBlack centerPointInside:false];
    self._enemiesDeactivatedAction = @selector(spawnWhiteAndBlackArcsFromInside:);
}

//
//
//
- (void)spawnWhiteAndBlackArcsFromInside:(EnemyManager *)enemyManager {
    [self spawnArcs:enemyManager leftColor:kColorStateWhite rightColor:kColorStateBlack centerPointInside:true];
    self._enemiesDeactivatedAction = @selector(spawnVerticalLines:);
}

//
//
//
- (void)spawnVerticalLines:(EnemyManager *)enemyManager {
    _spawnLinesFromTop = !_spawnLinesFromTop;
    [self spawnWhiteAndBlackVerticalLines:enemyManager fromTop:_spawnLinesFromTop];
    
    _timerInterval = 3.5f;
    self._timerCompletedAction = @selector(spawnVerticalLines:);
}

//
//
//
- (void)spawnBlackAndWhiteOppositeEachOther:(EnemyManager *)enemyManager withBlackOnLeft:(bool)blackOnLeft {
    
    CGPoint spawnPoint = ccp([enemyManager thirdCorner:kCornerLeftBottom].x, enemyManager._center.y);
    [_trackingEnemies addObject:[enemyManager spawnSoldierWithSpawnPoint:spawnPoint
                                                              colorState:(blackOnLeft) ? kColorStateBlack : kColorStateWhite
                                                           queueInterval:0.0f
                                                            idleInterval:3.0f]];
    
    spawnPoint = ccp([enemyManager thirdCorner:kCornerRightBottom].x, enemyManager._center.y);
    [_trackingEnemies addObject:[enemyManager spawnSoldierWithSpawnPoint:spawnPoint
                                                              colorState:(blackOnLeft) ? kColorStateWhite : kColorStateBlack
                                                           queueInterval:0.0f
                                                            idleInterval:3.0f]];
}

//
//
//
- (void)spawnArcs:(EnemyManager *)enemyManager leftColor:(ColorState)leftColor rightColor:(ColorState)rightColor centerPointInside:(bool)centerPointInside {
    [self spawnArc:enemyManager color:leftColor leftSide:true centerPointInside:centerPointInside];
    [self spawnArc:enemyManager color:rightColor leftSide:false centerPointInside:centerPointInside];
}
  
//
//
//
- (void)spawnArc:(EnemyManager *)enemyManager color:(ColorState)color leftSide:(bool)leftSide centerPointInside:(bool)centerPointInside {
    
    CGPoint centerPoint;
    float radius = CGRectGetHeight(enemyManager._rect) / 2.0f;
    float rotation = 0.0f;
    float rotationInterval = 180.0f / 4.0f;
    
    if (leftSide && !centerPointInside) {
        centerPoint = ccp(CGRectGetMinX(enemyManager._rect), enemyManager._center.y);
        rotationInterval *= -1;
    }
    else if (!leftSide && !centerPointInside) {
        centerPoint = ccp(CGRectGetMaxX(enemyManager._rect), enemyManager._center.y);
    }
    else if (leftSide && centerPointInside) {
        centerPoint = ccp((enemyManager._center.x - [Soldier diameter]), enemyManager._center.y);
    }
    else if (!leftSide && centerPointInside) {
        centerPoint = ccp((enemyManager._center.x + [Soldier diameter]), enemyManager._center.y);
        rotationInterval *= -1;
    }
                                       
    for (int i=0; i < 5; i++) {
        CGPoint vector = ccpNormalize(ccpRotateByAngle(ccp(0.0f, 1.0f), cpvzero, CC_DEGREES_TO_RADIANS(rotation)));
        CGPoint spawnPoint = ccpAdd(centerPoint, ccpMult(vector, radius));
        [_trackingEnemies addObject:[enemyManager spawnSoldierWithSpawnPoint:spawnPoint
                                                                  colorState:color
                                                               queueInterval:(i * 0.1f)
                                                                idleInterval:3.0f]];
        rotation += rotationInterval;
    }
}

//
//
//
- (void)spawnCrosses:(EnemyManager *)enemyManager leftColor:(ColorState)leftColor rightColor:(ColorState)rightColor {
    [self spawnCross:enemyManager color:leftColor leftSide:true];
    [self spawnCross:enemyManager color:rightColor leftSide:false];
}

//
//
//
- (void)spawnCross:(EnemyManager *)enemyManager color:(ColorState)color leftSide:(bool)leftSide {
    
    float idleInterval = 2.0f;
    CGPoint centerPoint = (leftSide) ? ccp([enemyManager fourthCorner:kCornerLeftBottom].x, enemyManager._center.y) :
                                       ccp([enemyManager fourthCorner:kCornerRightBottom].x, enemyManager._center.y);
    
    [_trackingEnemies addObject:[enemyManager spawnSoldierWithSpawnPoint:centerPoint
                                                              colorState:color
                                                           queueInterval:0.0f
                                                            idleInterval:idleInterval]];
    
    // do vertical line
    CGPoint spawnPoint = centerPoint;
    spawnPoint.y += [Soldier spawnSpacing];
    for (int i=0; i < 2; i++) {
        [_trackingEnemies addObject:[enemyManager spawnSoldierWithSpawnPoint:spawnPoint
                                                                  colorState:color
                                                               queueInterval:0.0f
                                                                idleInterval:idleInterval]];
        spawnPoint.y = centerPoint.y - [Soldier spawnSpacing];
    }
    
    // do horizontal line
    spawnPoint = centerPoint;
    spawnPoint.x += [Soldier spawnSpacing];
    for (int i=0; i < 2; i++) {
        [_trackingEnemies addObject:[enemyManager spawnSoldierWithSpawnPoint:spawnPoint
                                                                  colorState:color
                                                               queueInterval:0.0f
                                                                idleInterval:idleInterval]];
        spawnPoint.x = centerPoint.x - [Soldier spawnSpacing];
    }
}

//
//
//
- (void)spawnSlashes:(EnemyManager *)enemyManager leftColor:(ColorState)leftColor rightColor:(ColorState)rightColor startAtTop:(bool)startAtTop {
    [self spawnSlash:enemyManager color:leftColor leftSide:true startAtTop:startAtTop];
    [self spawnSlash:enemyManager color:rightColor leftSide:false startAtTop:startAtTop];
}

//
//
//
- (void)spawnSlash:(EnemyManager *)enemyManager color:(ColorState)color leftSide:(bool)leftSide startAtTop:(bool)startAtTop {
    CGPoint spawnPoint;
    spawnPoint.x = (leftSide) ? CGRectGetMinX(enemyManager._rect) : CGRectGetMaxX(enemyManager._rect);
    spawnPoint.y = (startAtTop) ? CGRectGetMaxY(enemyManager._rect) : CGRectGetMinY(enemyManager._rect);
    
    float xInterval = ((CGRectGetWidth(enemyManager._rect) / 2.0f) - [Soldier diameter]) / 4;
    if (!leftSide) {
        xInterval *= -1;
    }
    
    float yInterval = (startAtTop) ? -[Soldier spawnSpacing] : [Soldier spawnSpacing];
    
    for (int i=0; i < 5; i++) {
        [_trackingEnemies addObject:[enemyManager spawnSoldierWithSpawnPoint:spawnPoint
                                                                  colorState:color
                                                               queueInterval:(i * 0.1f)
                                                                idleInterval:2.0f]];
        spawnPoint.x += xInterval;
        spawnPoint.y += yInterval;
    }
}

//
//
//
- (void)spawnWhiteAndBlackVerticalLines:(EnemyManager *)enemyManager fromTop:(bool)top {
    
    // if we should stop
    if (![self spawnBlackInCenter:enemyManager]) {
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
                                        idleInterval:1.0f - queueInterval];
            spawnPoint.y += yInterval;
        }
        
        spawnPoint.x = [enemyManager thirdCorner:kCornerRightBottom].x;
        colorState = [ColorStateManager nextColorState:colorState];
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
