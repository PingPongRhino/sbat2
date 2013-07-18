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
#import "PathSprite.h"
#import "PathSpriteManager.h"
#import "PathSegment.h"
#import "StageScene.h"
#import "SpriteFrameManager.h"

//
// static globals
//
static const float _widthVelocity = 250.0f;

//
// @implementation PathSprite
//
@implementation PathSprite

//
// synthesize
//
@synthesize _pathSpriteManager;
@synthesize _active;
@synthesize _state;
@synthesize _goalState;
@synthesize _pathSegment;
@synthesize _direction;
@synthesize _goalWidth;
@synthesize _width;
@synthesize _halfHeight;
@synthesize _pathSpriteWaiting;
@synthesize _pathSpriteGroup;
@synthesize _positionIsAligned;

//
//
//
+ (id)pathSpriteWithPathSpriteManager:(PathSpriteManager *)pathSpriteManager {
    PathSprite *pathSprite = [[PathSprite alloc] initWithPathSpriteManager:pathSpriteManager];
    return [pathSprite autorelease];
}

//
//
//
- (id)initWithPathSpriteManager:(PathSpriteManager *)pathSpriteManager {
    self = [super initWithSpriteFrame:[SpriteFrameManager pathSpriteFrame]];
    
    // init properties
    self._pathSpriteManager = pathSpriteManager;
    self._active = false;
    self._state = kPathSpriteStateUnknown;
    self._goalState = kPathSpriteStateUnknown;
    self._pathSegment = nil;
    self._direction = ccp(0.0f, 0.0f);
    self._goalWidth = 0.0f;
    self._width = 0.0f;
    self._halfHeight = self.textureRect.size.height / 2.0f;
    self._pathSpriteWaiting = nil;
    self._pathSpriteGroup = nil;
    self._positionIsAligned = false;
    
    // set super class stuff
    self.anchorPoint = ccp(0.0f, 0.5f);
    
    return self;
}

//
//
//
- (float)length {
    return _width;
}

//
//
//
- (CGPoint)unalignedPosition {
    
    if (!_positionIsAligned) {
        return self.position;
    }
    
    // unalign to position
    return ccpAdd(self.position, ccpMult(_direction, _halfHeight));
}

//
//
//
- (void)setVisibleWithNumber:(NSNumber *)value {
    self.visible = [value boolValue];
}

//
//
//
- (void)setTextureWidth:(float)width {
    CGRect newTextureRect = self.textureRect;
    newTextureRect.size.width = width;
    self.textureRect = newTextureRect;
}

//
//
//
- (NSComparisonResult)sortByLength:(PathSprite *)pathSprite {
    
    float length01 = self.textureRect.size.width;
    float length02 = pathSprite.textureRect.size.width;
    
    // if they are growing, use the goalWidth instead of current
    if (_state == kPathSpriteStateGrowing) {
        length01 = _goalWidth;
    }
    
    if (pathSprite._state == kPathSpriteStateGrowing) {
        length02 = pathSprite._goalWidth;
    }
    
    // if they are both growing and they have the same width
    // then go off their current width instead of their goal
    if (_state == kPathSpriteStateGrowing &&
        pathSprite._state == kPathSpriteStateGrowing &&
        _goalWidth == pathSprite._goalWidth)
    {
        length01 = self.textureRect.size.width;
        length02 = pathSprite.textureRect.size.width;
    }
    
    if (length01 > length02) {
        return NSOrderedAscending;
    }
    
    if (length01 < length02) {
        return NSOrderedDescending;
    }
            
    return NSOrderedSame;
}

//
//
//
- (int)activateWithPathSegment:(PathSegment *)pathSegment
              snapToPathSprite:(PathSprite *)pathSprite
{
    if (_active) {
        return 1;
    }
    
    // activate and add to scene
    _active = true;
    _positionIsAligned = false;
    int theZOrder = pathSprite ? ZORDER_PATH_SPRITE_HIGH : ZORDER_PATH_SPRITE_LOW;
    [[[StageScene sharedStageScene] spriteBatchNodeWithIndex:SPRITEBATCHNODE_INDEX_PATHING] addChild:self z:theZOrder];
    self.visible = false;
    
    // set path segment
    self._pathSegment = pathSegment;
        
    // reset goal state
    _goalState = kPathSpriteStateUnknown;
    
    // initialize waiting state, someone has to tell us to start growing
    [self enterStateWait];
    
    // calc direction
    CGPoint segment = ccpSub(_pathSegment._end, _pathSegment._start);
    _direction = ccpNormalize(segment);
    
    // if we need to snap to a path sprite then do it!
    [self alignWithPathSprite:pathSprite];
    pathSprite._pathSpriteWaiting = self; // let the guy we snapped to know that we are waiting on him
    
    // set widths
    _goalWidth = ccpDistance(_pathSegment._end, _pathSegment._start);
    _width = 0.0f;
    
    // set our rotation
    self.rotation = CC_RADIANS_TO_DEGREES(ccpAngleSigned(_direction, ccp(1.0f, 0.0f)));
    
    // set position
    self.position = _pathSegment._start;
    
    // init texture rect
    [self setTextureWidth:_width];
    
    return 0;
}

//
//
//
- (int)deactivate {
    if (!_active) {
        return 1;
    }
    
    _active = false;
    [self removeFromParentAndCleanup:false];
    
    // tell parent we are deactivating
    [_pathSpriteManager deactivatePathSprite:self];
    
    // clear our path segement and whoever was waiting on us, cause it an't gonna happen
    self._pathSegment = nil;
    self._pathSpriteWaiting = nil;
    
    return 0;
}

//
//
//
- (int)alignWithPathSprite:(PathSprite *)pathSprite {
    
    // if no sprite to snap to, then bail
    if (!pathSprite) {
        return -1;
    }
    
    _positionIsAligned = true;
    
    // generate new path segement
    PathSegment *newPathSegment = [PathSegment pathSegment];
    
    // get point we are snaping to
    CGPoint snapPoint = pathSprite._pathSegment._end;
    
    // calc new start point and set end point
    newPathSegment._start = ccpAdd(snapPoint, ccpMult(_direction, -_halfHeight));
    newPathSegment._end = _pathSegment._end;
    self._pathSegment = newPathSegment;
    return 0;
}

//
//
//
- (void)truncateToPathSprite:(PathSprite *)pathSprite {
    
    // else do normal truncation and make visible
    float truncatedWidth = _goalWidth - pathSprite.textureRect.size.height;
    
    // if width has gone past the truncated width, then cap it
    if (_width > truncatedWidth) {
        [self setTextureWidth:truncatedWidth];
    }
}

//
//
//
- (void)enterStateWait {
    _state = kPathSpriteStateWait;
}

//
//
//
- (void)enterStateGrowing {
    _state = kPathSpriteStateGrowing;
    self.visible = true;
    _width = 0.0f;
    [self setTextureWidth:_width];
}

//
//
//
- (void)updateStateGrowing:(ccTime)elapsedTime {
    
    // grow the width
    float delta = elapsedTime * _widthVelocity;
    _width += delta;
    
    // if we hit our goal or went past it
    if (_width >= _goalWidth) {
        [self enterStateActive]; // enter activate state will ensure the rect is set to goal width
        return;
    }
    
    [self setTextureWidth:_width];
}

//
//
//
- (void)enterStateActive {
        
    _state = kPathSpriteStateActive;
    
    // if someone is waiting on us, then tell them to start growing
    [_pathSpriteWaiting enterStateGrowing];
    
    // ensure we are set to our goal width
    _width = _goalWidth;
    [self setTextureWidth:_width];
    
    // check our goal state, if it's suppose to be shrinking, then
    // go straight to that state
    if (_goalState == kPathSpriteStateShrinking) {
        [self enterStateShrinking];
    }
}

//
//
//
- (void)enterStateShrinking {

    // if we are in active state, then move to shrinking state
    if (_state == kPathSpriteStateActive) {
        _state = kPathSpriteStateShrinking;
        return;
    }
    
    // if we are not yet in an active state, then set our goal
    // state to shrinking, and hold off until we become active
    _goalState = kPathSpriteStateShrinking;
}

//
//
//
- (void)updateStateShrinking:(ccTime)elapsedTime {
    
    float delta = elapsedTime * _widthVelocity;
    
    // shrink our texture rect
    _width -= delta;
    
    // move the position along the direction
    self.position = ccpAdd(self.position, ccpMult(_direction, delta));
    
    // check if we have finished shrinking
    if (_width <= 0) {
        _width = 0.0f;
        [_pathSpriteWaiting enterStateShrinking]; // tell guy depending on us to shrink
        [self deactivate];
    }
    
    [self setTextureWidth:_width];
}

//
//
//
- (void)updateWithNumber:(NSNumber *)number {
    
    float elapsedTime = [number floatValue];
    
    switch (_state) {
        case kPathSpriteStateGrowing:   [self updateStateGrowing:elapsedTime]; break;
        case kPathSpriteStateShrinking: [self updateStateShrinking:elapsedTime]; break;
        default: break;
    }
}

//
//
//
- (void)dealloc {
    self._pathSpriteManager = nil;
    self._active = nil;
    self._pathSegment = nil;
    self._pathSpriteWaiting = nil;
    self._pathSpriteGroup = nil;
    [super dealloc];
}

@end
