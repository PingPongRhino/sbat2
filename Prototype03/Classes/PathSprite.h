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
// forward declarations
//
@class PathSpriteManager;
@class PathSegment;
@class PathSpriteGroup;

//
// @interface PathSprite
//
@interface PathSprite : CCSprite {
    PathSpriteManager *_pathSpriteManager;
    bool _active;
    PathSpriteState _state;
    PathSpriteState _goalState;
    PathSegment *_pathSegment;
    CGPoint _direction;
    float _goalWidth;
    float _width;
    float _halfHeight;
    PathSprite *_pathSpriteWaiting;
    PathSpriteGroup *_pathSpriteGroup;
    bool _positionIsAligned;
}

//
// properties
//
@property (nonatomic, assign) PathSpriteManager *_pathSpriteManager;
@property (nonatomic, assign) bool _active;
@property (nonatomic, assign) PathSpriteState _state;
@property (nonatomic, assign) PathSpriteState _goalState;
@property (nonatomic, retain) PathSegment *_pathSegment;
@property (nonatomic, assign) CGPoint _direction;
@property (nonatomic, assign) float _goalWidth;
@property (nonatomic, assign) float _width;
@property (nonatomic, assign) float _halfHeight;
@property (nonatomic, assign) PathSprite *_pathSpriteWaiting;
@property (nonatomic, assign) PathSpriteGroup *_pathSpriteGroup;
@property (nonatomic, assign) bool _positionIsAligned;

//
// static functions
//
+ (id)pathSpriteWithPathSpriteManager:(PathSpriteManager *)pathSpriteManager;

//
// functions
//
- (id)initWithPathSpriteManager:(PathSpriteManager *)pathSpriteManager;
- (float)length;
- (CGPoint)unalignedPosition;
- (void)setVisibleWithNumber:(NSNumber *)value;
- (void)setTextureWidth:(float)width;
- (NSComparisonResult)sortByLength:(PathSprite *)pathSprite;
- (int)activateWithPathSegment:(PathSegment *)pathSegment
              snapToPathSprite:(PathSprite *)pathSprite;
- (int)deactivate;

//
// working with other path sprites
//
- (int)alignWithPathSprite:(PathSprite *)pathSprite;
- (void)truncateToPathSprite:(PathSprite *)pathSprite;

//
// state management stuff
//
- (void)enterStateWait;
- (void)enterStateGrowing;
- (void)updateStateGrowing:(ccTime)elapsedTime;
- (void)enterStateActive;
- (void)enterStateShrinking;
- (void)updateStateShrinking:(ccTime)elapsedTime;
- (void)updateWithNumber:(NSNumber *)number;
- (void)dealloc;

@end
