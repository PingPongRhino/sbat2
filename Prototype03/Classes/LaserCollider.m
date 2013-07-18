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
#import "LaserCollider.h"
#import "LaserEmitter.h"
#import "StageLayer.h"
#import "defines.h"
#import "CCEncryptedTextureCache.h"

//
// defines
//
#define DEBUG_LASER_COLLIDER 0
#define LASER_COLLIDER_RADIUS 5.0f

//
// globals
//
static const float _radius = LASER_COLLIDER_RADIUS;
static const float _diameter = LASER_COLLIDER_RADIUS * 2.0f;

//
//
//
@implementation LaserCollider

//
// synthesize
//
@synthesize _laserEmitter;
@synthesize _index;
@synthesize _distanceTraveled;
@synthesize _body;
@synthesize _shape;
@synthesize _active;
@synthesize _lethal;
@synthesize _sprite;
@synthesize _label;

//
// get static variables
//
+ (float)radius { return _radius; }
+ (float)diameter { return _diameter; }

//
//
//
+ (id)laserColliderWithLaserEmitter:(LaserEmitter *)laserEmitter index:(int)index {
    LaserCollider *laserCollider = [[LaserCollider alloc] initWithLaserEmitter:laserEmitter index:index];
    return [laserCollider autorelease];
}

//
//
//
- (id)initWithLaserEmitter:(LaserEmitter *)laserEmitter index:(int)index {
    self = [super init];
    
    // init properties
    self._laserEmitter = laserEmitter;
    self._index = index;
    self._distanceTraveled = _radius + (index * _diameter);
    self._body = cpBodyNew(1.0f, INFINITY);
    self._shape = cpCircleShapeNew(_body, _radius, cpv(0.0f, 0.0f));
    self._active = false;
    self._lethal = false;
    
    [self setupShape];
    
#if DEBUG_LASER_COLLIDER == 1
    self._sprite = [CCSprite spriteWithTexture:[[CCEncryptedTextureCache sharedTextureCache] addImage:@"laser_collider.png.enc"]];
    self._label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%02d", _index] fontName:@"Arial" fontSize:10];

    // label stuff for debugging
    [_laserEmitter addChild:_sprite];
    //[_laserEmitter addChild:_label];
    _sprite.visible = false;
    _label.visible = false;
    _label.rotation = -90;
    _label.color = ccWHITE;
#endif
    
    return self;
}

//
//
//
- (void)setupShape {
    _shape->collision_type = COLLISION_TYPE_LASER;
    _shape->sensor = true;
    _shape->group = _laserEmitter._collisionGroup;
    _shape->layers = _laserEmitter._collisionLayerMask;
    _shape->data = self;
}

//
//
//
- (void)activate {
    
    // if already active, then bail out
    if (_active) {
        return;
    }
    
    cpSpace *space = [StageLayer sharedStageLayer]._space;
    cpSpaceAddBody(space, _body);
    cpSpaceAddShape(space, _shape);
    _active = true;
    _lethal = true;
    
#if DEBUG_LASER_COLLIDER == 1
    // for debugging
    _sprite.visible = true;
    _label.visible = true;
#endif
}

//
//
//
- (void)deactivate {
    
    // if already deactivated, then bail out
    if (!_active) {
        return;
    }

    cpSpace *space = [StageLayer sharedStageLayer]._space;
    cpSpaceRemoveBody(space, _body);
    cpSpaceRemoveShape(space, _shape);
    _active = false;
    
#if DEBUG_LASER_COLLIDER == 1
    // for debugging
    _sprite.visible = false;
    _label.visible = false;
#endif
}

//
//
//
- (void)chipmunkUpdate:(NSNumber *)elapsedTime {
    
#if DEBUG_LASER_COLLIDER == 1
    // for debugging
    _sprite.position = [_sprite.parent convertToNodeSpace:_body->p];
    _label.position = [_label.parent convertToNodeSpace:_body->p];
    _sprite.visible = true;
    _label.visible = true;
#endif
    
    _lethal = true; // rest our lethal flag for next chipmunk update

}

//
//
//
- (void)updatePosition:(CGPoint)worldPosition {
    _body->p = worldPosition;
    [self activate];
}

//
//
//
- (void)dealloc {
    
    // clean up pointers
    self._laserEmitter = nil;
    
    if (_shape) {
        cpShapeFree(_shape);
        _shape = NULL;
    }
    
    if (_body) {
        cpBodyFree(_body);
        _body = NULL;
    }
    
    // for debugging
    self._sprite = nil;
    self._label = nil;
    
    [super dealloc];
}

@end
