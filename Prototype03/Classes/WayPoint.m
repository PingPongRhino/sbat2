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
#import "WayPoint.h"
#import "StageScene.h"
#import "StageLayer.h"
#import "PlayerShip.h"
#import "NotificationStrings.h"
#import "SpriteFrameManager.h"

//
// static const
//
static const float _hitRadius = 11.0f;
static const float _rotationVelocity = -360.0f;

//
// @implementation PlayerPositionSensor
//
@implementation WayPoint

//
// synthesize
//
@synthesize _activate;
@synthesize _playerShipsInWayPoint;

//
//
//
+ (id)wayPoint {
    WayPoint *wayPoint = [[WayPoint alloc] initWithSpriteFrame:[SpriteFrameManager wayPointSpriteFrame]];
    return [wayPoint autorelease];
}

//
//
//
- (id)initWithSpriteFrame:(CCSpriteFrame *)spriteFrame {
    self = [super initWithSpriteFrame:spriteFrame];
    
    self._activate = false;
    self._playerShipsInWayPoint = [NSMutableSet set];
    
    [self scheduleUpdate];

    return self;
}

//
//
//
- (void)refreshWayPointWithPlayerShip:(PlayerShip *)playerShip {
    
    // save off old so we can see if stuff changed
    NSSet *prevPlayerShipsInWayPoint = [[NSSet alloc] initWithSet:_playerShipsInWayPoint];
        
    // if this ship isn't in our hit area
    if (ccpDistance(playerShip.position, self.position) > _hitRadius) {
        [_playerShipsInWayPoint removeObject:playerShip];        
    }
    // else it is in our hit area
    else {
        [_playerShipsInWayPoint addObject:playerShip];
    }
    
    // if sets changed
    if (![_playerShipsInWayPoint isEqualToSet:prevPlayerShipsInWayPoint]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationWayPointShipsInWayPointChanged object:self];
    }
    
    [prevPlayerShipsInWayPoint release];
}

//
//
//
- (int)activateWithSpawnPosition:(CGPoint)spawnPosition {
    if (_activate) {
        return 1;
    }
    
    _activate = true;
    [_playerShipsInWayPoint removeAllObjects];
    
    self.rotation = arc4random() % 360;
    self.position = spawnPosition;
    CCSpriteBatchNode *spriteBatchNode = [[StageScene sharedStageScene]._spriteBatchNodeList objectAtIndex:SPRITEBATCHNODE_INDEX_PLAYFIELD_01];
    [spriteBatchNode addChild:self z:ZORDER_WAYPOINT];
    
    // register with player ships so we can see when they hit our way point
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePlayerShipPositionChanged:)
                                                 name:kNotificationPlayerShipPositionChanged
                                               object:nil];
    return 0;
}

//
//
//
- (int)deactivate {
    if (!_activate) {
        return 1;
    }
    
    _activate = false;
    [_playerShipsInWayPoint removeAllObjects];
    [self removeFromParentAndCleanup:false];
    
    // unregister from notification center
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    return 0;
}

//
//
//
- (void)update:(ccTime)elapsedTime {
    
    // if not active or if there is no player ships inside us, then do nothing
    if (!_activate || [_playerShipsInWayPoint count] <= 0) {
        return;
    }
    
    // update rotation
    self.rotation += elapsedTime * _rotationVelocity;
}

//
//
//
- (void)handlePlayerShipPositionChanged:(NSNotification *)notification {
    [self refreshWayPointWithPlayerShip:[notification object]];
}

//
// dealloc
//
- (void)dealloc {
    [self deactivate];
    self._playerShipsInWayPoint = nil;
    [super dealloc];
}

@end
