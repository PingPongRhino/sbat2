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
#import "PathSpriteManager.h"
#import "PathSprite.h"
#import "PathSegment.h"
#import "NSMutableSet+Extended.h"
#import "NSArray+Extended.h"
#import "PathSpriteGroup.h"
#import "PathSpriteParticle.h"
#import "SpriteFrameManager.h"
#import "StageLayer.h"

//
// static globals
//
static PathSpriteManager *_sharedPathSpriteManager;

//
// @implementation PathSpriteManager
//
@implementation PathSpriteManager

//
// synthesize
//
@synthesize _active;
@synthesize _pathSprites;
@synthesize _activePathSprites;
@synthesize _inactivePathSprites;
@synthesize _pathSpriteParticles;
@synthesize _inactivePathSpriteParticles;
@synthesize _pathSpriteEnds;
@synthesize _inactivePathSpriteEnds;
@synthesize _pathSpriteGroups;

//
//
//
+ (PathSpriteManager *)createSharedPathSpriteManager {
    [PathSpriteManager destroySharedPathSpriteManager];
    _sharedPathSpriteManager = [[PathSpriteManager alloc] init];
    return _sharedPathSpriteManager;
}

//
//
//
+ (PathSpriteManager *)sharedPathSpriteManager { return _sharedPathSpriteManager; }

//
//
//
+ (void)destroySharedPathSpriteManager {
    [_sharedPathSpriteManager deactivate];
    [_sharedPathSpriteManager release];
    _sharedPathSpriteManager = nil;
}

//
//
//
- (id)init {
    self = [super init];
    
    // init properties
    self._active = false;
    self._pathSprites = [NSMutableSet set];
    self._activePathSprites = [NSMutableSet set];
    self._inactivePathSprites = [NSMutableSet set];
    self._pathSpriteParticles = [NSMutableSet set];
    self._inactivePathSpriteParticles = [NSMutableSet set];
    self._pathSpriteEnds = [NSMutableSet set];
    self._inactivePathSpriteEnds = [NSMutableSet set];
    self._pathSpriteGroups = [NSMutableArray array];
        
    // init ccnode junk
    [self scheduleUpdate];
    
    return self;
}

//
//
//
- (PathSprite *)inactivePathSprite {
    PathSprite *pathSprite = [_inactivePathSprites popItem];
    if (!pathSprite) {
        pathSprite = [PathSprite pathSpriteWithPathSpriteManager:self];
        [_pathSprites addObject:pathSprite];
    }
    [_activePathSprites addObject:pathSprite];
    return pathSprite;    
}

//
//
//
- (PathSpriteParticle *)inactivePathSpriteParticle {
    PathSpriteParticle *pathSpriteParticle = [_inactivePathSpriteParticles popItem];
    if (!pathSpriteParticle) {
        pathSpriteParticle = [PathSpriteParticle pathSpriteParticleWithPathSpriteManager:self];
        [_pathSpriteParticles addObject:pathSpriteParticle];
    }
    return pathSpriteParticle;
}

//
//
//
- (CCSprite *)inactivePathSpriteEnd {
    CCSprite *pathSpriteEnd = [_inactivePathSpriteEnds popItem];
    if (!pathSpriteEnd) {
        pathSpriteEnd = [CCSprite spriteWithSpriteFrame:[SpriteFrameManager pathSpriteEndSpriteFrame]];
        [_pathSpriteEnds addObject:pathSpriteEnd];
    }
    return pathSpriteEnd;
}

//
//
//
- (int)activate {
    if (_active) {
        return 1;
    }
    
    // activate and add to stage layer so we get updates
    _active = true;
    [[StageLayer sharedStageLayer] addChild:self];
    
    // reset groups
    [_pathSpriteGroups removeAllObjects];
    
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
    
    // deactivate all the path sprites
    [_pathSprites makeObjectsPerformSelector:@selector(deactivate)];
    
    return 0;
}

//
//
//
- (void)activatePathSpritesWithPathSpriteOwner:(id<PathSpriteOwnerProtocol>)pathSpriteOwner {
    
    // put any path sprites this guy owns into a shrinking state
    [self deactivatePathSpritesForPathSpriteOwner:pathSpriteOwner];
    
    // get path sprites array
    NSMutableArray *pathSprites = [pathSpriteOwner pathSprites];
    [pathSprites removeAllObjects];
    
    // create a path sprite for each segment
    PathSprite *prevPathSprite = nil;
    for (PathSegment *pathSegment in [pathSpriteOwner pathSegments]) {
        
        // setup path sprite
        PathSprite *pathSprite = [self inactivePathSprite];
        [pathSprite activateWithPathSegment:pathSegment snapToPathSprite:prevPathSprite];
        [self addToPathSpriteGroupWithPathSprite:pathSprite];
        [pathSprites addObject:pathSprite];
        prevPathSprite = pathSprite;
    }
    
    // activate first sprite
    [[pathSprites firstObject] enterStateGrowing];
}

//
// desc: put any path sprites this guy owns into a shrinking state
//
- (void)deactivatePathSpritesForPathSpriteOwner:(id<PathSpriteOwnerProtocol>)pathSpriteOwner {
    NSMutableArray *pathSprites = [pathSpriteOwner pathSprites];
    [[pathSprites firstObject] enterStateShrinking];
    [pathSprites removeAllObjects];
}

//
//
//
- (void)deactivatePathSprite:(PathSprite *)pathSprite {
    [pathSprite._pathSpriteGroup removePathSprite:pathSprite];
    [_activePathSprites removeObject:pathSprite];
    [_inactivePathSprites addObject:pathSprite];
}

//
//
//
- (int)addToPathSpriteGroupWithPathSprite:(PathSprite *)pathSprite {
    PathSegment *pathSegment = pathSprite._pathSegment;
    for (PathSpriteGroup *pathSpriteGroup in _pathSpriteGroups) {
        
        // if path was successfully added, then bail
        if ([pathSpriteGroup addPathSprite:pathSprite] >= 0) {
            return 1;
        }    
    }
    
    // no group wants this guy, so create new group for him
    PathSpriteGroup *pathSpriteGroup = [PathSpriteGroup pathSpriteGroupWithPathSpriteManager:self
                                                                            matchingEndPoint:pathSegment._end];
    [pathSpriteGroup addPathSprite:pathSprite];
    [_pathSpriteGroups addObject:pathSpriteGroup];
    return 0;
}

//
//
//
- (void)removePathSpriteGroup:(PathSpriteGroup *)pathSpriteGroup
{
    [_pathSpriteGroups removeObject:pathSpriteGroup];
}

//
//
//
- (PathSpriteParticle *)activateSpritePathParticleWithPathSpriteGroup:(PathSpriteGroup *)pathSpriteGroup elapsedTime:(ccTime)elapsedTime {
    PathSpriteParticle *particle = [self inactivePathSpriteParticle];
    [particle activateWithPathSpriteGroup:pathSpriteGroup elapsedTime:elapsedTime];
    return particle;
}

//
//
//
- (void)deactivatePathSpriteParticle:(PathSpriteParticle *)pathSpriteParticle {
    [_inactivePathSpriteParticles addObject:pathSpriteParticle];
    [pathSpriteParticle._pathSpriteGroup._pathSpriteParticles removeObject:pathSpriteParticle];
}

//
//
//
- (CCSprite *)activateSpritePathEnd {
    return [self inactivePathSpriteEnd];
}

//
//
//
- (void)deactivatePathSpriteEnd:(CCSprite *)sprite {
    [_inactivePathSpriteEnds addObject:sprite];
}

//
//
//
- (void)update:(ccTime)elapsedTime {
    
    // if not active, then bail
    if (!_active) {
        return;
    }
    
    // tell all active sprites to update
    [_pathSprites makeObjectsPerformSelector:@selector(updateWithNumber:) withObject:[NSNumber numberWithFloat:elapsedTime]];
    
    // tell groups to update
    [_pathSpriteGroups makeObjectsPerformSelector:@selector(updateWithNumber:) withObject:[NSNumber numberWithFloat:elapsedTime]];
 }

//
//
//
- (void)dealloc {
    self._pathSprites = nil;
    self._activePathSprites = nil;
    self._inactivePathSprites = nil;
    self._pathSpriteParticles = nil;
    self._inactivePathSpriteParticles = nil;
    self._pathSpriteEnds = nil;
    self._inactivePathSpriteEnds = nil;
    self._pathSpriteGroups = nil;
    [super dealloc];
}


@end
