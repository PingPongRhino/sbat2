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
#import "SFAttackStreamManager.h"
#import "StageScene.h"
#import "StageLayer.h"
#import "LaserGrid.h"
#import "LaserTower.h"
#import "SFAttackStream.h"
#import "NSMutableSet+Extended.h"
#import "chipmunk.h"
#import "SoldierFactory.h"
#import "SFAttackManager.h"

//
// static globals
//
static const int _sfAttackStreamCount = 3;

//
// @implementation SFAttackStreamManager
//
@implementation SFAttackStreamManager

//
// synthesize
//
@synthesize _attackManager;
@synthesize _soldierFactory;
@synthesize _attackStreams;
@synthesize _inactiveAttackStreams;
@synthesize _streamsThatAreGrowing;

//
//
//
+ (id)sfAttackStreamManagerWithAttackManager:(SFAttackManager *)attackManager {
    SFAttackStreamManager *attackStreamManager = [[SFAttackStreamManager alloc] initWithAttackManager:attackManager];
    return [attackStreamManager autorelease];
}

//
// methods
//
- (id)initWithAttackManager:(SFAttackManager *)attackManager {
    self = [super init];
    
    self._attackManager = attackManager;
    self._soldierFactory = _attackManager._soldierFactory;
    self._attackStreams = [NSMutableSet setWithCapacity:_sfAttackStreamCount];
    self._inactiveAttackStreams = [NSMutableSet setWithCapacity:_sfAttackStreamCount];
    self._streamsThatAreGrowing = 0;
    
    // init streams
    [self createAttackStreamsWithSoldierFactory:_soldierFactory];
    
    return self;
}

//
//
//
- (void)createAttackStreamsWithSoldierFactory:(SoldierFactory *)soldierFactory {
    for (int i=0; i < _sfAttackStreamCount; i++) {
        SFAttackStream *attackStream = [SFAttackStream sfAttackStreamWithSoldierFactory:soldierFactory sfAttackStreamManager:self];
        [_attackStreams addObject:attackStream];
        [_inactiveAttackStreams addObject:attackStream];
    }
}

//
//
//
- (int)activateWithColorState:(ColorState)colorState {
    
    // only if everyone is deactivated
    if ([_inactiveAttackStreams count] != _sfAttackStreamCount) {
        return 1;
    }
    
    // get towers to attack
    NSArray *laserTowers = [[LaserGrid sharedLaserGrid] towersSortedByHealth];
    
    _streamsThatAreGrowing = 0;
    for (int i=0; i < _sfAttackStreamCount; i++) {
            
        // make sure tower is alive
        LaserTower *laserTower = [laserTowers objectAtIndex:i];
        if ([laserTower isDead]) {
            break;
        }
        
        SFAttackStream *attackStream = [_inactiveAttackStreams popItem];
        [attackStream activateWithColorState:colorState laserTower:laserTower];
        _streamsThatAreGrowing++;
    }
    return 0;
}

//
//
//
- (int)deactivate {
    [_attackStreams makeObjectsPerformSelector:@selector(deactivate)];
    return 0;
}

//
//
//
- (void)deactivateAttackStream:(SFAttackStream *)attackStream {
    [_inactiveAttackStreams addObject:attackStream];    
}

//
//
//
- (void)streamIsShrinking:(SFAttackStream *)attackStream {
    _streamsThatAreGrowing--;
    if (_streamsThatAreGrowing <= 0) {
        [_attackManager startEndingAnimation];
    }
}
//
//
//
- (void)dealloc {
    self._soldierFactory = nil;
    self._attackStreams = nil;
    self._inactiveAttackStreams = nil;
    [super dealloc];
}

@end
