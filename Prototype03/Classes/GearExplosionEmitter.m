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
#import "GearExplosionEmitter.h"
#import "LaserTower.h"
#import "GearExplosion.h"
#import "StageLayer.h"
#import "StageScene.h"

//
// static globals
//
static const float _rotationOffset = 10.0f;
static const float _rotationVelocity = 45.0f;

//
// @implementation GearExplosionEmitter
//
@implementation GearExplosionEmitter

//
// synthesize
//
@synthesize _laserTower;
@synthesize _gearExplosionBlue;
@synthesize _gearExplosionYellow;
@synthesize _active;

//
//
//
+ (id)gearExplosionEmitterWithLaserTower:(LaserTower *)laserTower {
    GearExplosionEmitter *gearExplosionEmitter = [[GearExplosionEmitter alloc] initWithLaserTower:laserTower];
    return [gearExplosionEmitter autorelease];
}

//
//
//
- (id)initWithLaserTower:(LaserTower *)laserTower {
    self = [super init];
    
    // init properties
    self._laserTower = laserTower;
    self._gearExplosionBlue = [GearExplosion gearExplosionWithLaserTower:laserTower glowColor:@"blue"];
    self._gearExplosionYellow = [GearExplosion gearExplosionWithLaserTower:laserTower glowColor:@"yellow"];
    self._active = false;
    
    return self;
}

//
//
//
- (int)activateWithFullSequence:(bool)fullSequence {
    
    // this stuff we just want to reset if something else is already running
    if (_active) {
        [self deactivate];
    }
    
    _active = true;
    [_gearExplosionBlue activateWithFullSequence:fullSequence];
    [_gearExplosionYellow activateWithFullSequence:fullSequence];
    
    // set initial position
    _gearExplosionBlue.position = _laserTower.position;
    _gearExplosionYellow.position = _laserTower.position;
    
    // set initial rotations
    float rotation = CC_RADIANS_TO_DEGREES(ccpAngleSigned(_laserTower._direction, ccp(0.0f, -1.0f)));
    _gearExplosionBlue.rotation = rotation + _rotationOffset;
    _gearExplosionYellow.rotation = rotation - _rotationOffset;
        
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
    [_gearExplosionBlue deactivate];
    [_gearExplosionYellow deactivate];
    return 0;
}

//
//
//
- (void)update:(ccTime)elapsedTime {
    
    // if not active, then bail
    if (!_active) {
        return;
    }
    
    // calc rotation delta
    float delta = elapsedTime * _rotationVelocity;
    
    // update rotation
    _gearExplosionBlue.rotation += delta;
    _gearExplosionYellow.rotation -= delta;    
}

//
//
//
- (void)dealloc {
    self._laserTower = nil;
    self._gearExplosionBlue = nil;
    self._gearExplosionYellow = nil;
    [super dealloc];
}

@end
