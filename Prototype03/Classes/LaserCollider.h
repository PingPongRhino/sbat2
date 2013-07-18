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
#import "chipmunk.h"

//
// forward declarations
//
@class LaserEmitter;

//
// @interface LaserCollider
//
@interface LaserCollider : NSObject {
    LaserEmitter *_laserEmitter;
    int _index;
    float _distanceTraveled;
    cpBody *_body;
    cpShape *_shape;
    bool _active;
    bool _lethal; // this is to keep all enemies from getting hit
                  // at the same time if they are stacked close to each other.
                  // if this collider is not lethal, then the enemy shouldn't
                  // take any damage
    
    // for debugging
    CCSprite *_sprite;
    CCLabelTTF *_label;
}

//
// properties
//
@property (nonatomic, assign) LaserEmitter *_laserEmitter;
@property (nonatomic, assign) int _index;
@property (nonatomic, assign) float _distanceTraveled;
@property (nonatomic, assign) cpBody *_body;
@property (nonatomic, assign) cpShape *_shape;
@property (nonatomic, assign) bool _active;
@property (nonatomic, assign) bool _lethal;
@property (nonatomic, retain) CCSprite *_sprite;
@property (nonatomic, retain) CCLabelTTF *_label;

//
// static functions
//
+ (float)radius;
+ (float)diameter;
+ (id)laserColliderWithLaserEmitter:(LaserEmitter *)laserEmitter index:(int)index;

//
// initialization
//
- (id)initWithLaserEmitter:(LaserEmitter *)laserEmitter index:(int)index;
- (void)setupShape;

//
// activate/deactivate
//
- (void)activate;
- (void)deactivate;

//
// BezierObjectProtocol
//
- (void)updatePosition:(CGPoint)worldPosition;

//
// cleanup
//
- (void)dealloc;


@end
