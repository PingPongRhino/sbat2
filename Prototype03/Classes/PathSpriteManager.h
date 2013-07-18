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
#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "protocols.h"

//
// forward declarations
//
@class PathSprite;
@class PathSegment;
@class PathSpriteGroup;
@class PathSpriteParticle;

//
// @interface PathSpriteManager
//
@interface PathSpriteManager : CCNode {
    bool _active;
    NSMutableSet *_pathSprites;
    NSMutableSet *_activePathSprites;
    NSMutableSet *_inactivePathSprites;
    NSMutableSet *_pathSpriteParticles;
    NSMutableSet *_inactivePathSpriteParticles;
    NSMutableSet *_pathSpriteEnds;
    NSMutableSet *_inactivePathSpriteEnds;
    NSMutableArray *_pathSpriteGroups;
}

//
// properties
//
@property (nonatomic, assign) bool _active;
@property (nonatomic, retain) NSMutableSet *_pathSprites;
@property (nonatomic, retain) NSMutableSet *_activePathSprites;
@property (nonatomic, retain) NSMutableSet *_inactivePathSprites;
@property (nonatomic, retain) NSMutableSet *_pathSpriteParticles;
@property (nonatomic, retain) NSMutableSet *_inactivePathSpriteParticles;
@property (nonatomic, retain) NSMutableSet *_pathSpriteEnds;
@property (nonatomic, retain) NSMutableSet *_inactivePathSpriteEnds;
@property (nonatomic, retain) NSMutableArray *_pathSpriteGroups;

//
// static properties
//
+ (PathSpriteManager *)createSharedPathSpriteManager;
+ (PathSpriteManager *)sharedPathSpriteManager;
+ (void)destroySharedPathSpriteManager;

//
// initialization
//
- (id)init;

//
// fetch inactive stuff
//
- (PathSprite *)inactivePathSprite;
- (PathSpriteParticle *)inactivePathSpriteParticle;
- (CCSprite *)inactivePathSpriteEnd;

//
// activate/deactivate
//
- (int)activate;
- (int)deactivate;

//
// activate/deactivate path segment
//
- (void)activatePathSpritesWithPathSpriteOwner:(id<PathSpriteOwnerProtocol>)pathSpriteOwner;
- (void)deactivatePathSpritesForPathSpriteOwner:(id<PathSpriteOwnerProtocol>)pathSpriteOwner;
- (void)deactivatePathSprite:(PathSprite *)pathSprite;

//
// activate/deactive path sprite particles
//
- (PathSpriteParticle *)activateSpritePathParticleWithPathSpriteGroup:(PathSpriteGroup *)pathSpriteGroup
                                                          elapsedTime:(ccTime)elapsedTime;
- (void)deactivatePathSpriteParticle:(PathSpriteParticle *)pathSpriteParticle;

//
// activate/deactivate path sprite ends
//
- (CCSprite *)activateSpritePathEnd;
- (void)deactivatePathSpriteEnd:(CCSprite *)sprite;

//
// managed path groups
//
- (int)addToPathSpriteGroupWithPathSprite:(PathSprite *)pathSprite;
- (void)removePathSpriteGroup:(PathSpriteGroup *)pathSpriteGroup;

//
// update
//
- (void)update:(ccTime)elapsedTime;

//
// cleanup
//
- (void)dealloc;

@end
