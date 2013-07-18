//
//  EnemySpawn.m
//  Prototype03
//
//  Created by Cody Sandel on 3/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//
// includes
//
#import "EnemySpawn.h"
#import "EnemySpawnManager.h"
#import "StageLayer.h"
#import "defines.h"

//
// @implementation EnemySpawn
//
@implementation EnemySpawn

//
// synthesize
//
@synthesize _enemySpawnManager;
@synthesize _spawnBoxSize;
@synthesize _row;
@synthesize _col;
@synthesize _active;
@synthesize _centerPoint;

//
//
//
+ (id)enemySpawnWithEnemySpawnManager:(EnemySpawnManager *)enemySpawnManager {
    EnemySpawn *enemySpawn = [[EnemySpawn alloc] initWithEnemySpawnManager:enemySpawnManager];
    return [enemySpawn autorelease];
}

//
//
//
- (id)initWithEnemySpawnManager:(EnemySpawnManager *)enemySpawnManager {
    self = [super init];
    
    // init properties
    self._enemySpawnManager = enemySpawnManager;
    self._spawnBoxSize = _enemySpawnManager._spawnBoxSize;
    self._row = -1;
    self._col = -1;
    self._active = false;
    self._centerPoint = ccp(0.0f, 0.0f);
    
    return self;
}

//
//
//
- (int)activateWithRow:(int)row col:(int)col {
    
    // if already active bail
    if (_active)
        return 1;
    
    // set to active
    _active = true;
    
    // set row and column
    _row = row;
    _col = col;
    
    // calc center of spawn area
    CGSize halfSize;
    halfSize.width = _spawnBoxSize.width / 2.0f;
    halfSize.height = _spawnBoxSize.height / 2.0f;
    _centerPoint.x = _enemySpawnManager._left + (_spawnBoxSize.width * _row) + halfSize.width;
    _centerPoint.y = _enemySpawnManager._bottom + (_spawnBoxSize.height * _col) + halfSize.height;
    
    return 0;
}

//
//
//
- (int)deactivate {
    
    // if not active, then bail
    if (!_active)
        return 1;
    
    // set to inactive
    _active = false;
    
    // reset variables
    _row = -1;
    _col = -1;
    
    return 0;
}

//
//
//
- (void)dealloc {
    self._enemySpawnManager = nil;
    [super dealloc];
}


@end
