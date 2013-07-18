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
#import "PathSpriteGroup.h"
#import "PathSpriteManager.h"
#import "PathSprite.h"
#import "PathSegment.h"
#import "PathSpriteParticle.h"
#import "NSArray+Extended.h"
#import "StageScene.h"

//
// static globals
//
static const ccTime _particleSpawnInterval = 0.5f;

//
// @implementation PathSpriteGroup
//
@implementation PathSpriteGroup

//
// synthesize
//
@synthesize _pathSpriteManager;
@synthesize _matchingEndPoint;
@synthesize _pathSprites;
@synthesize _visiblePathSprites;
@synthesize _pathSpriteParticles;
@synthesize _active;
@synthesize _timer;
@synthesize _direction;
@synthesize _runsAlongXAxis;
@synthesize _pathSpriteEnds;

//
//
//
+ (id)pathSpriteGroupWithPathSpriteManager:(PathSpriteManager *)pathSpriteManager
                          matchingEndPoint:(CGPoint)matchingEndPoint
{
    PathSpriteGroup *pathSpriteGroup = [[PathSpriteGroup alloc] initWithPathSpriteManager:pathSpriteManager
                                                                         matchingEndPoint:matchingEndPoint];
    return [pathSpriteGroup autorelease];
}

//
//
//
- (id)initWithPathSpriteManager:(PathSpriteManager *)pathSpriteManager
               matchingEndPoint:(CGPoint)matchingEndPoint
{
    self = [super init];
    
    // init properties
    self._pathSpriteManager = pathSpriteManager;
    self._matchingEndPoint = matchingEndPoint;
    self._pathSprites = [NSMutableArray array];
    self._visiblePathSprites = [NSMutableSet set];
    self._pathSpriteParticles = [NSMutableSet set];
    self._active = false;
    self._timer = 0.0f;
    self._direction = ccp(0.0f, 0.0f);
    self._runsAlongXAxis = false;
    self._pathSpriteEnds = [NSMutableSet set];
    
    // activate
    [self activate];
    
    return self;
}

//
//
//
- (int)activate {
    if (_active) {
        return 1;
    }
    
    _active = true;
    _timer = 0.0f;
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
    
    // copy the set so that we can drain it when the particles deactivate
    NSSet *particles = [NSSet setWithSet:_pathSpriteParticles];
    [particles makeObjectsPerformSelector:@selector(deactivate)];
    
    // deactivate path sprite ends
    [self deactivateAllPathSpriteEnds];
    
    // tell manager we are outta here
    [_pathSpriteManager removePathSpriteGroup:self];

    return 0;
}

//
//
//
- (void)deactivateAllPathSpriteEnds {
    // kill all our path sprite ends first
    for (CCSprite *sprite in _pathSpriteEnds) {
        [sprite removeFromParentAndCleanup:false];
        [_pathSpriteManager deactivatePathSpriteEnd:sprite];
    }
    [_pathSpriteEnds removeAllObjects];
}

//
//
//
- (int)addPathSprite:(PathSprite *)pathSprite {
    
    PathSegment *pathSegment = pathSprite._pathSegment;

    // if path sprite does not match our group
    if (CGPointEqualToPoint(_matchingEndPoint, pathSegment._end) == false) {
        return -1;
    }
    
    // calculate direction
    _direction = ccpNormalize(ccpSub(pathSegment._end, pathSegment._start));
    
    // calc axis we run along
    _runsAlongXAxis = true;
    if (pathSegment._start.x == pathSegment._end.x) {
        _runsAlongXAxis = false;
    }
    
    // else welcome him ot the fold
    [_pathSprites addObject:pathSprite];
    pathSprite._pathSpriteGroup = self;
    return 0;
}

//
//
//
- (void)removePathSprite:(PathSprite *)pathSprite {
    [_pathSprites removeObject:pathSprite];
    pathSprite._pathSpriteGroup = nil;
    
    // if we are out of sprites, kill us
    if ([_pathSprites count] <= 0) {
        
        // deactivate
        [self deactivate];
    }
}

//
//
//
- (int)checkPoint:(CGPoint)point {
    
    // see if this has gone past the end
    CGPoint direction = ccpNormalize(ccpSub(_matchingEndPoint, point));
    if (ccpDot(direction, _direction) <= 0.0f) {
        return -1;
    }
    
    // go through each segment and see if this point lies along
    for (PathSprite *pathSprite in _visiblePathSprites) {
        
        // get end points for displayed texture
        CGPoint start = pathSprite.position;
        CGPoint end = ccpAdd(start, ccpMult(pathSprite._direction, pathSprite.textureRect.size.width));
        
        // check x axis
        if (_runsAlongXAxis &&
            ((point.x >= start.x && point.x <= end.x) ||
             (point.x >= end.x && point.x <= start.x)))
        {
            return 0;
        }
        
        // check y axis
        if (!_runsAlongXAxis &&
            ((point.y >= start.y && point.y <= end.y) ||
             (point.y >= end.y && point.y <= start.y)))
        {
            return 0;
        }
    }
    
    // does not lie within any of the segments
    return 1;
}

//
//
//
- (CGPoint)getStartingPoint {
    PathSprite *pathSprite = [_pathSprites firstObject];
    return pathSprite._pathSegment._start;
}

//
//
//
- (int)findNextSpriteToTruncateToWithStartingIndex:(int)startIndex
                                        pathSprite:(PathSprite *)pathSprite
{
    // go through the sprites till we find the next one that isn't growing
    // and doesn't have the same length as us
    for (int i=startIndex+1; i < [_pathSprites count]; i++) {
        
        // get next sprite
        PathSprite *nextSprite = [_pathSprites objectAtIndex:i];
        
        // if sprite is in waiting state, don't worry about him
        if (nextSprite._state == kPathSpriteStateWait) {
            continue; // skip it
        }
        
        // if we are both growing and they have same width
        if (pathSprite._state == kPathSpriteStateGrowing &&
            nextSprite._state == kPathSpriteStateGrowing &&
            pathSprite._goalWidth == nextSprite._goalWidth)
        {
            continue; // skip it, keep it invisible since it is underneath our current sprite
        }
        
        // we need to truncate to this sprite
        [pathSprite truncateToPathSprite:nextSprite];
        return i; // return the index we left off at
    }
    
    return [_pathSprites count]+1; // send an invalid index
}

//
// desc: go through all of our sprites and see which ones should be visible
//       and which ones should be hidden.  all the sprites connected to the same
//       end point are sorted by their distance from the goal point.  so the first
//       object is the longest.
//
- (void)cullOverlappingPathSprites {
    
    // deactivate path sprite ends
    [self deactivateAllPathSpriteEnds];
    
    // sort the array
    [_pathSprites sortUsingSelector:@selector(sortByLength:)];
    
    // hide all of these
    [_pathSprites makeObjectsPerformSelector:@selector(setVisibleWithNumber:) withObject:[NSNumber numberWithBool:false]];
    
    // reset our visible set
    [_visiblePathSprites removeAllObjects];
    
    // go through path sprites with same end point
    for (int i=0; i < [_pathSprites count]; i++) {
        PathSprite *pathSprite = [_pathSprites objectAtIndex:i];
        
        // if this is growing, then display and truncate the length if we need to
        if (pathSprite._state == kPathSpriteStateGrowing) {
            i = [self findNextSpriteToTruncateToWithStartingIndex:i pathSprite:pathSprite];
            i--; // move back one in the list so we can truncate the guy we truncated to
            
            // display this sprite
            [self makePathSpriteVisible:pathSprite];
            continue;
        }
        
        // if this is active or shrinking, then set to visible and bail
        if (pathSprite._state == kPathSpriteStateActive ||
            pathSprite._state == kPathSpriteStateShrinking)
        {
            [self makePathSpriteVisible:pathSprite];
            break;
        }
    }
}

//
//
//
- (void)makePathSpriteVisible:(PathSprite *)pathSprite {
    
    // set to visible and add to our visible list
    pathSprite.visible = true;
    [_visiblePathSprites addObject:pathSprite];
    
    // fetch an end for this guy
    CCSprite *pathSpriteEnd = [_pathSpriteManager activateSpritePathEnd];
    if (!pathSpriteEnd) {
        return;
    }
    
    pathSpriteEnd.position = ccpAdd(pathSprite.position, ccpMult(pathSprite._direction, pathSprite._halfHeight));
    [[[StageScene sharedStageScene] spriteBatchNodeWithIndex:SPRITEBATCHNODE_INDEX_PATHING] addChild:pathSpriteEnd z:ZORDER_PATH_SPRITE_END];
    [_pathSpriteEnds addObject:pathSpriteEnd];
}

//
//
//
- (void)updateParticles:(ccTime)elapsedTime {
    
    _timer += elapsedTime;
    
    while (_timer >= _particleSpawnInterval) {
        
        _timer -= _particleSpawnInterval;
    
        // if no path sprites visible, then do nothing
        if ([_visiblePathSprites count] <= 0) {
            continue;
        }
        
        // spawn particle here
        PathSpriteParticle *particle = [_pathSpriteManager activateSpritePathParticleWithPathSpriteGroup:self elapsedTime:_timer];
        if (!particle) {
            continue;
        }
        
        [_pathSpriteParticles addObject:particle];        
    }
}

//
//
//
- (void)updateWithNumber:(NSNumber *)number {
    
    // cull overlappint path sprites
    [self cullOverlappingPathSprites];
    
    // tell particles to update themselve
    NSSet *set = [NSSet setWithSet:_pathSpriteParticles];
    [set makeObjectsPerformSelector:@selector(updateWithNumber:) withObject:number];
    
    // update particles
    [self updateParticles:[number floatValue]];
}

//
//
//
- (void)dealloc {
    self._pathSpriteManager = nil;
    self._pathSprites = nil;
    self._visiblePathSprites = nil;
    self._pathSpriteParticles = nil;
    self._pathSpriteEnds = nil;
    [super dealloc];
}

@end
