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
#import "defines.h"

//
// forward declaration
//
@class PathSpriteManager;
@class PathSprite;

//
// @interface PathSpriteGroup
//
@interface PathSpriteGroup : NSObject {
    PathSpriteManager *_pathSpriteManager;
    CGPoint _matchingEndPoint;
    NSMutableArray *_pathSprites;
    NSMutableArray *_visiblePathSprites;
    NSMutableSet *_pathSpriteParticles;
    bool _active;
    ccTime _timer;
    CGPoint _direction;
    bool _runsAlongXAxis;
    NSMutableSet *_pathSpriteEnds;
}

//
// properties
//
@property (nonatomic, assign) PathSpriteManager *_pathSpriteManager;
@property (nonatomic, assign) CGPoint _matchingEndPoint;
@property (nonatomic, retain) NSMutableArray *_pathSprites;
@property (nonatomic, retain) NSMutableArray *_visiblePathSprites;
@property (nonatomic, retain) NSMutableSet *_pathSpriteParticles;
@property (nonatomic, assign) bool _active;
@property (nonatomic, assign) ccTime _timer;
@property (nonatomic, assign) CGPoint _direction;
@property (nonatomic, assign) bool _runsAlongXAxis;
@property (nonatomic, retain) NSMutableSet *_pathSpriteEnds;

//
//
//
+ (id)pathSpriteGroupWithPathSpriteManager:(PathSpriteManager *)pathSpriteManager
                          matchingEndPoint:(CGPoint)matchingEndPoint;

//
// initialization
//
- (id)initWithPathSpriteManager:(PathSpriteManager *)pathSpriteManager
               matchingEndPoint:(CGPoint)matchingEndPoint;

//
// activate/deactivate
//
- (int)activate;
- (int)deactivate;
- (void)deactivateAllPathSpriteEnds;

//
// functions
//
- (int)addPathSprite:(PathSprite *)pathSprite;
- (void)removePathSprite:(PathSprite *)pathSprite;
- (int)checkPoint:(CGPoint)point;
- (CGPoint)getStartingPoint;

//
// update
//
- (int)findNextSpriteToTruncateToWithStartingIndex:(int)startIndex
                                        pathSprite:(PathSprite *)pathSprite;
- (void)cullOverlappingPathSprites;
- (void)makePathSpriteVisible:(PathSprite *)pathSprite;
- (void)updateWithNumber:(NSNumber *)number;

//
// cleanup
//
- (void)dealloc;

@end
