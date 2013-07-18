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
@class PathSpriteGroup;

//
// @interface PathSpriteParticle
//
@interface PathSpriteParticle : NSObject {
    PathSpriteManager *_pathSpriteManager;
    CCSprite *_topSprite;
    CCSprite *_bottomSprite;
    PathSpriteGroup *_pathSpriteGroup;
    bool _active;
}

//
// properties
//
@property (nonatomic, assign) PathSpriteManager *_pathSpriteManager;
@property (nonatomic, retain) CCSprite *_topSprite;
@property (nonatomic, retain) CCSprite *_bottomSprite;
@property (nonatomic, assign) PathSpriteGroup *_pathSpriteGroup;
@property (nonatomic, assign) bool _active;

//
// static functions
//
+ (id)pathSpriteParticleWithPathSpriteManager:(PathSpriteManager *)pathSpriteManager;

//
// functions
//
- (id)initWithPathSpriteManager:(PathSpriteManager *)pathSpriteManager;
- (CCSprite *)createPathParticleSpriteFlipped:(bool)flipped;
- (int)activateWithPathSpriteGroup:(PathSpriteGroup *)pathSpriteGroup elapsedTime:(ccTime)elapsedTime;
- (int)deactivate;
- (void)updateWithNumber:(NSNumber *)number;
- (void)dealloc;

@end
