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
// c/c++ headers
//
#include "ChipmunkCallbacks.h"

//
// objective-c headers
//
#import "StageLayer.h"
#import "LaserCollider.h"
#import "LaserEmitter.h"
#import "LaserTower.h"
#import "EnemySpawn.h"
#import "Soldier.h"
#import "PlayerShip.h"
#import "EnemyDrop.h"

//
//
//
void ChipmunkUpdate(void *ptr, void *data)
{
    cpShape *shape = (cpShape *)ptr;
    
    // if data is null, then bail out
    if (!shape->data)
        return;
    
    // see if we can notify the object to update
    NSObject *object = (NSObject *)shape->data;
    if ([object respondsToSelector:@selector(chipmunkUpdate:)]) {
        [object performSelector:@selector(chipmunkUpdate:) withObject:data];
    }
}

//
//
//
int CollisionBeginIgnore(cpArbiter *arb, struct cpSpace *space, void *data)
{
    return 0; // ignore collision
}

//
//
//
int CollisionBeginLaserWithLaser(cpArbiter *arb, struct cpSpace *space, void *data)
{
    // get the shapes involved in collision
    cpShape *a = NULL;
    cpShape *b = NULL;
    cpArbiterGetShapes(arb, &a, &b);
        
    // get colliders
    LaserCollider *colliderA = (LaserCollider *)a->data;
    LaserCollider *colliderB = (LaserCollider *)b->data;
    
    // if a has more energy than b, aka is closer to it's origin, then destroy b
    if (colliderA._index < colliderB._index) {
        cpSpaceAddPostStepCallback(space, (cpPostStepFunc)PostStepDeactivateLaser, b, b->data);
        return 0;
    }
    
    // if b has more energy than a, then destroy a
    if (colliderB._index < colliderA._index) {
        cpSpaceAddPostStepCallback(space, (cpPostStepFunc)PostStepDeactivateLaser, a, a->data);
        return 0;
    }
    
    // else destroy both particles
    cpSpaceAddPostStepCallback(space, (cpPostStepFunc)PostStepDeactivateLaser, a, a->data);
    cpSpaceAddPostStepCallback(space, (cpPostStepFunc)PostStepDeactivateLaser, b, b->data);
    
    // don't process this collision, return false
    return 0;
}

//
//
//
int CollisionBeginLaserWithObject(cpArbiter *arb, struct cpSpace *space, void *data)
{
    // get the shapes involved in collision
    cpShape *a = NULL;
    cpShape *b = NULL;
    cpArbiterGetShapes(arb, &a, &b);
    
    // destory the laser collider
    cpSpaceAddPostStepCallback(space, (cpPostStepFunc)PostStepDeactivateLaser, a, a->data);
    
    // if this guy is not lethal, then do nothing
    LaserCollider *laserCollider = a->data;
    if (!laserCollider._lethal) {
        return 0;
    }
    
    // let this object handle it and neutralize it
    laserCollider._lethal = false;
    
    // tel the object they were hit by a lazar, pew pew
    if (b->data) {
        NSObject *object = (NSObject *)b->data;
        if ([object respondsToSelector:@selector(handleLaserCollision:)]) {
            [object performSelector:@selector(handleLaserCollision:) withObject:a->data];
        }
    }
    
    return 0;
}

//
//
//
int CollisionBeginLaserTowerWithSoldier(cpArbiter *arb, struct cpSpace *space, void *data)
{
    // get the shapes involved in collision
    cpShape *a = NULL;
    cpShape *b = NULL;
    cpArbiterGetShapes(arb, &a, &b);
    
    // notify tower
    LaserTower *laserTower = (LaserTower *)a->data;
    [laserTower handleSoldierCollision:b->data];
    
    // destory the soldier
    cpSpaceAddPostStepCallback(space, (cpPostStepFunc)PostStepDeactivateObject, b, b->data);
    
    return 0;
}

//
//
//
int CollisionBeginSoldierWithObject(cpArbiter *arb, struct cpSpace *space, void *data)
{
    // get the shapes involved in collision
    cpShape *a = NULL;
    cpShape *b = NULL;
    cpArbiterGetShapes(arb, &a, &b);
    
    // notify object of collision
    NSObject *object = (NSObject *)b->data;
    if ([object respondsToSelector:@selector(handleSoldierCollisionBegin:)]) {
        [object performSelector:@selector(handleSoldierCollisionBegin:) withObject:a->data];
    }
        
    return 0;
}

//
//
//
void CollisionSeparateSoldierWithObject(cpArbiter *arb, struct cpSpace *space, void *data)
{
    // get the shapes involved in collision
    cpShape *a = NULL;
    cpShape *b = NULL;
    cpArbiterGetShapes(arb, &a, &b);
    
    // notify object of seperation
    NSObject *object = (NSObject *)b->data;
    if ([object respondsToSelector:@selector(handleSoldierCollisionSeparate:)]) {
        [object performSelector:@selector(handleSoldierCollisionSeparate:) withObject:a->data];
    }
}

//
//
//
int CollisionBeginEnemyDropWithPlayer(cpArbiter *arb, struct cpSpace *space, void *data)
{
    // get the shapes involved in collision
    cpShape *a = NULL;
    cpShape *b = NULL;
    cpArbiterGetShapes(arb, &a, &b);
    
    // notify object of collision
    EnemyDrop *enemyDrop = (EnemyDrop *)a->data;
    [enemyDrop handleCollisionWithPlayer:b->data];
    
    // kill our enemy drop
    cpSpaceAddPostStepCallback(space, (cpPostStepFunc)PostStepDeactivateObject, a, a->data);
    
    return 0;
}

//
//
//
void PostStepDeactivateLaser(cpSpace *space, cpShape *shape, LaserCollider *collider)
{
    // deactivate collider
    [collider deactivate];
    
    // let parent emitter know that chipmunk deactivated him
    LaserEmitter *laserEmitter = collider._laserEmitter;
    [laserEmitter chipmunkDeactivatedCollider:collider];
}

//
//
//
void PostStepDeactivateObject(cpSpace *space, cpShape *shape, NSObject *object)
{
    // if object is null, then bail
    if (!object) {
        return;
    }
    
    // else tell him to deactivate
    if ([object respondsToSelector:@selector(chipmunkDeactivate)]) {
        [object performSelector:@selector(chipmunkDeactivate)];
    }
}