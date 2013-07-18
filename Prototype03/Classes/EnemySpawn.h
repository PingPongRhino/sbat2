//
//  EnemySpawn.h
//  Prototype03
//
//  Created by Cody Sandel on 3/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//
// includes
//
#import <Foundation/Foundation.h>

//
// forward declarations
//
@class EnemySpawnManager;

//
// @interface EnemySpawn
//
@interface EnemySpawn : NSObject {
    EnemySpawnManager *_enemySpawnManager;
    CGSize _spawnBoxSize;
    int _row;
    int _col;
    bool _active;
    CGPoint _centerPoint;
}

//
// properties
//
@property (nonatomic, assign) EnemySpawnManager *_enemySpawnManager;
@property (nonatomic, assign) CGSize _spawnBoxSize;
@property (nonatomic, assign) int _row;
@property (nonatomic, assign) int _col;
@property (nonatomic, assign) bool _active;
@property (nonatomic, assign) CGPoint _centerPoint;

//
// static functions
//
+ (id)enemySpawnWithEnemySpawnManager:(EnemySpawnManager *)enemySpawnManager;

//
// functions
//
- (id)initWithEnemySpawnManager:(EnemySpawnManager *)enemySpawnManager;
- (int)activateWithRow:(int)row col:(int)col;
- (int)deactivate;
- (void)dealloc;

@end
