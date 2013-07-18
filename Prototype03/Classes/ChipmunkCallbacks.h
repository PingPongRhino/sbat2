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
#import "chipmunk.h"

//
// forward declarations
//
@class LaserCollider;

//
// callback functions
//
void ChipmunkUpdate(void *ptr, void *data);

// generice one for ignoring a collision
int CollisionBeginIgnore(cpArbiter *arb, struct cpSpace *space, void *data);

// laser collision callbacks
int CollisionBeginLaserWithLaser(cpArbiter *arb, struct cpSpace *space, void *data);
int CollisionBeginLaserWithObject(cpArbiter *arb, struct cpSpace *space, void *data);

// laser tower collision callbacks
int CollisionBeginLaserTowerWithSoldier(cpArbiter *arb, struct cpSpace *space, void *data);

// soldier with soldier factory callbacks
int CollisionBeginSoldierWithObject(cpArbiter *arb, struct cpSpace *space, void *data);
void CollisionSeparateSoldierWithObject(cpArbiter *arb, struct cpSpace *space, void *data);

// enemy drop collision
int CollisionBeginEnemyDropWithPlayer(cpArbiter *arb, struct cpSpace *space, void *data);

// post steps
void PostStepDeactivateLaser(cpSpace *space, cpShape *shape, LaserCollider *collider);
void PostStepDeactivateObject(cpSpace *space, cpShape *shape, NSObject *object);