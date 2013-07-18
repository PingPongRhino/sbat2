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
#import "WaveManager10.h"
#import "EnemyManager.h"
#import "SoldierFactory.h"
#import "ColorStateManager.h"
#import "NotificationStrings.h"

//
// @implementation WaveManager10
//
@implementation WaveManager10

//
// synthesize
//
@synthesize _quadrants;

//
//
//
- (id)initWithWaveNumber:(int)waveNumber {
    self = [super initWithWaveNumber:waveNumber];
    self._quadrants = [NSMutableArray arrayWithCapacity:kCornerCount];
    
    for (int i=0; i < kCornerCount; i++) {
        [_quadrants addObject:[NSNull null]];
    }
    
    return self;
}

//
//
//
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self._quadrants = nil;
    [super dealloc];
}

//
//
//
- (int)activate {
    if ([super activate] == 1) {
        return 1;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(enemyDeactivated:)
                                                 name:kNotificationSoldierFactoryDeactivated
                                               object:nil];

    
    _currentColorState = kColorStateWhite;
    _deactivatedCounter = 0;
    [self spawnSoldierFactory:[EnemyManager sharedEnemyManager]];
    [self spawnSoldierFactory:[EnemyManager sharedEnemyManager]];
    return 0;
}

//
//
//
- (void)spawnSoldierFactory:(EnemyManager *)enemyManager {
    
    if (_deactivatedCounter >= 37) {
        _completedSpawn = true;
        return;
    }
    
    EnemyType enemyType = kEnemyTypeSoldierFactory;
    if (_deactivatedCounter >= 10) {
        enemyType = kEnemyTypeBarrierFactory;
    }
    
    [self spawnFactory:enemyManager withEnemyType:enemyType];
}

//
//
//
- (void)spawnFactory:(EnemyManager *)enemyManager withEnemyType:(EnemyType)enemyType {
    // see if we got an empty corner
    NSSet *emptyCorners = [self findEmptyCorners];
    if ([emptyCorners count] <= 0) {
        return;
    }

    // spawn soldier factory in random location
    Corner corner = (Corner)[[[emptyCorners allObjects] objectAtIndex:(arc4random() % [emptyCorners count])] intValue];

    [self spawnRandomLocation:enemyManager
                    enemyType:enemyType
                queueInterval:(arc4random() % 3) * 0.1f
                   colorState:_currentColorState
                       corner:corner];

    _currentColorState = [ColorStateManager nextColorState:_currentColorState];
}

//
//
//
- (NSSet *)findEmptyCorners {
    
    NSMutableSet *emptyCorners = [NSMutableSet set];
    
    for (int i=0; i < [_quadrants count]; i++) {
        id object = [_quadrants objectAtIndex:i];
        if (object == [NSNull null]) {
            [emptyCorners addObject:[NSNumber numberWithInt:i]];
        }
    }
    
    return emptyCorners;
}

//
//
//
- (void)spawnRandomLocation:(EnemyManager *)enemyManager
                  enemyType:(EnemyType)enemyType
              queueInterval:(float)queueInterval
                 colorState:(ColorState)colorState
                     corner:(Corner)corner
{
    
    // random spawn point
    float offsetX = arc4random() % (int)(CGRectGetWidth(enemyManager._rect) /2.0f - [SoldierFactory diameter]);
    float offsetY = arc4random() % (int)((CGRectGetHeight(enemyManager._rect) / 2.0f) - [SoldierFactory diameter]);
    CGPoint spawnPoint = CGPointZero;
    
    if (corner == kCornerLeftBottom || corner == kCornerLeftTop) {
        spawnPoint.x = enemyManager._center.x - [SoldierFactory diameter] - offsetX;
    }
    else {
        spawnPoint.x = enemyManager._center.x + [SoldierFactory diameter] + offsetX;
    }
    
    if (corner == kCornerLeftTop || corner == kCornerRightTop) {
        spawnPoint.y = enemyManager._center.y + [SoldierFactory diameter] + offsetY;
    }
    else {
        spawnPoint.y = enemyManager._center.y - [SoldierFactory diameter] - offsetY;
    }
    
    // spawn soldier
    SoldierFactory *soldierFactory = [enemyManager spawnSoldierFactoryWithSpawnPoint:spawnPoint
                                                                           enemyType:enemyType
                                                                          colorState:colorState
                                                                       queueInterval:queueInterval
                                                                     restingInterval:1.0f
                                                                    spawningInterval:0.1f
                                                                  spawnEmissionCount:3];
    
    [_quadrants replaceObjectAtIndex:corner withObject:soldierFactory];
}

//
//
//
- (void)enemyDeactivated:(NSNotification *)notification {
    int index = [_quadrants indexOfObject:[notification object]];
    [_quadrants replaceObjectAtIndex:index withObject:[NSNull null]];
    
    _deactivatedCounter++;
    
    if (_deactivatedCounter == 9) {
        return;
    }
    
    if (_deactivatedCounter == 10) {
        [self spawnSoldierFactory:[EnemyManager sharedEnemyManager]];
        [self spawnSoldierFactory:[EnemyManager sharedEnemyManager]];
        return;
    }
    
    if (_deactivatedCounter == 19) {
        return;
    }
    
    if (_deactivatedCounter == 20) {
        [self spawnSoldierFactory:[EnemyManager sharedEnemyManager]];
        [self spawnSoldierFactory:[EnemyManager sharedEnemyManager]];
        [self spawnSoldierFactory:[EnemyManager sharedEnemyManager]];
        return;
    }
    
    if (_deactivatedCounter >= 28 && _deactivatedCounter <= 29) {
        return;
    }
    
    if (_deactivatedCounter == 30) {
        [self spawnSoldierFactory:[EnemyManager sharedEnemyManager]];
        [self spawnSoldierFactory:[EnemyManager sharedEnemyManager]];
        [self spawnSoldierFactory:[EnemyManager sharedEnemyManager]];
        [self spawnSoldierFactory:[EnemyManager sharedEnemyManager]];
        return;
    }
    
    if (_deactivatedCounter >= 37 && _deactivatedCounter <= 39) {
        return;
    }
        
    // just replace the guy that was killed
    [self spawnSoldierFactory:[EnemyManager sharedEnemyManager]];
}

@end
