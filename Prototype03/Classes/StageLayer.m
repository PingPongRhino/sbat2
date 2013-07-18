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
#import "StageLayer.h"
#import "StageScene.h"
#import "LaserGrid.h"
#import "PlayerShip.h"
#import "GamePlayManager.h"
#import "TriangleStripParticleBatchNode.h"
#import "ChipmunkCallbacks.h"
#import "NotificationStrings.h"
#import "MainMenuLayer.h"
#import "CCEncryptedTextureCache.h"
#import "SpriteFrameManager.h"

//
// static globals
//
static StageLayer *_sharedStageLayer = nil;
static const float _invisibleWallSegmentThickness = 100.0f;

//
// @implementation StageLayer
//
@implementation StageLayer

//
// synthesize
//
@synthesize _space;
@synthesize _invisibleWallCount;
@synthesize _backgroundSprite;
@synthesize _borderSprite;
@synthesize _currentGamePlayManager;
@synthesize _active;
@synthesize _paused;

//
//
//
+ (StageLayer *)createSharedStageLayer {
    [StageLayer destroySharedStageLayer];
    _sharedStageLayer = [[StageLayer alloc] init];
    return _sharedStageLayer;
}

//
//
//
+ (StageLayer *)sharedStageLayer { return _sharedStageLayer; }

//
//
//
+ (void)destroySharedStageLayer {
    [_sharedStageLayer release];
    _sharedStageLayer = nil;
}

//
// desc: init
//
- (id)init {
    
    // init object
    self = [super init];

    [self setContentSize:CGSizeMake(480, 320)];
    
    // init variables
    self._space = [self space];
    self._invisibleWallCount = 4;
    memset(_insideInvisibleWallShapes, 0, sizeof(_insideInvisibleWallShapes));
    memset(_outsideInvisibleWallShapes, 0, sizeof(_outsideInvisibleWallShapes));
    self._backgroundSprite = [self backgroundSprite];
    self._borderSprite = [self borderSprite];
    self._currentGamePlayManager = nil;
    self._active = false;
    self._paused = false;
    
    // setup chipmunk collision handlers
    [self setupChipmunkCollisionHandlers];
    
    // schedule update
    [self scheduleUpdate];
        
    // setup touch stuff
	self.isTouchEnabled = YES;
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self
													 priority:1
											  swallowsTouches:YES];
    
    // return self
    return self;
}

//
//
//
- (CCSprite *)backgroundSprite {
    CCTexture2D *texture = [[CCEncryptedTextureCache sharedTextureCache] addImage:@"background.jpg.enc"];
    CCSprite *backgroundSprite = [CCSprite spriteWithTexture:texture];
    backgroundSprite.position = ccp(self.contentSize.width / 2.0f, self.contentSize.height / 2.0f);
    return backgroundSprite;
}

//
//
//
- (CCSprite *)borderSprite {
    
    CCSprite *borderSprite = nil;
    
#if TARGET_IPAD
    CCTexture2D *texture = [[CCEncryptedTextureCache sharedTextureCache] addImage:@"border.png.enc"];
    borderSprite = [CCSprite spriteWithTexture:texture];
    borderSprite.position = ccp(self.contentSize.width / 2.0f, self.contentSize.height / 2.0f);
#endif
    
    return borderSprite;
}

//
//
//
- (CCLabelTTF *)versionLabel {
    CCLabelTTF *versionLabel = [CCLabelTTF labelWithString:VERSION_STRING fontName:@"Arial" fontSize:10];
    versionLabel.anchorPoint = ccp(1.0f, 0.0f);
    versionLabel.position = ccp(self.contentSize.width, 0.0f);
    return versionLabel;
}

//
//
//
- (cpSpace *)space {
    cpSpace *space = cpSpaceNew();
    cpSpaceResizeStaticHash(space, 42, 500);
    cpSpaceResizeActiveHash(space, 42, 500);
    return space;
}

//
//
//
- (void)setupInsideInvisibleWalls {
    
    // calc rect layout invisible wall
    CGRect rect = CGRectInset([LaserGrid sharedLaserGrid]._rect, -[PlayerShip radius], -[PlayerShip radius]);
    rect = CGRectInset(rect, -_invisibleWallSegmentThickness, -_invisibleWallSegmentThickness);
    float left = CGRectGetMinX(rect);
    float right = CGRectGetMaxX(rect);
    float bottom = CGRectGetMinY(rect);
    float top = CGRectGetMaxY(rect);
    
    // set up each wall
    _insideInvisibleWallShapes[0] = cpSegmentShapeNew(&_space->staticBody, cpv(left,  bottom), cpv(right, bottom), _invisibleWallSegmentThickness); // bottom side
    _insideInvisibleWallShapes[1] = cpSegmentShapeNew(&_space->staticBody, cpv(left,  bottom), cpv(left,  top   ), _invisibleWallSegmentThickness); // left side
    _insideInvisibleWallShapes[2] = cpSegmentShapeNew(&_space->staticBody, cpv(right, top   ), cpv(left,  top   ), _invisibleWallSegmentThickness); // top side
    _insideInvisibleWallShapes[3] = cpSegmentShapeNew(&_space->staticBody, cpv(right, top   ), cpv(right, bottom), _invisibleWallSegmentThickness); // right side
    
    // set shape group info
    for (int i=0; i < _invisibleWallCount; i++) {
        cpShape *shape = _insideInvisibleWallShapes[i];
        shape->e = 0.0f;
        shape->u = 0.0f;
        shape->group = GROUP_INVISIBLE_WALL;
        shape->collision_type = COLLISION_TYPE_INVISIBLE_WALL;
        cpSpaceAddStaticShape(_space, shape);
    }
    
    // set layer masks
    _insideInvisibleWallShapes[0]->layers = LAYER_MASK_INSIDE_INVISIBLE_WALL_BOTTOM;
    _insideInvisibleWallShapes[1]->layers = LAYER_MASK_INSIDE_INVISIBLE_WALL_LEFT;
    _insideInvisibleWallShapes[2]->layers = LAYER_MASK_INSIDE_INVISIBLE_WALL_TOP;
    _insideInvisibleWallShapes[3]->layers = LAYER_MASK_INSIDE_INVISIBLE_WALL_RIGHT;
}

//
//
//
- (void)setupOutsideInvisibleWalls {
    
    // for easier reference
    CGRect rect = CGRectInset([self boundingBox], -_invisibleWallSegmentThickness, -_invisibleWallSegmentThickness);
    float left = CGRectGetMinX(rect);
    float right = CGRectGetMaxX(rect);
    float bottom = CGRectGetMinY(rect);
    float top = CGRectGetMaxY(rect);
    
    // set up each wall
    _outsideInvisibleWallShapes[0] = cpSegmentShapeNew(&_space->staticBody, cpv(left,  bottom), cpv(right, bottom), _invisibleWallSegmentThickness); // bottom side
    _outsideInvisibleWallShapes[1] = cpSegmentShapeNew(&_space->staticBody, cpv(left,  bottom), cpv(left,  top   ), _invisibleWallSegmentThickness); // left side
    _outsideInvisibleWallShapes[2] = cpSegmentShapeNew(&_space->staticBody, cpv(right, top   ), cpv(left,  top   ), _invisibleWallSegmentThickness); // top side
    _outsideInvisibleWallShapes[3] = cpSegmentShapeNew(&_space->staticBody, cpv(right, top   ), cpv(right, bottom), _invisibleWallSegmentThickness); // right side
    
    // set shape group info
    for (int i=0; i < _invisibleWallCount; i++) {
        cpShape *shape = _outsideInvisibleWallShapes[i];
        shape->e = 0.0f;
        shape->u = 0.0f;
        shape->group = GROUP_INVISIBLE_WALL;
        shape->collision_type = COLLISION_TYPE_INVISIBLE_WALL;
        cpSpaceAddStaticShape(_space, shape);
    }
    
    // set layer masks
    _outsideInvisibleWallShapes[0]->layers = LAYER_MASK_OUTSIDE_INVISIBLE_WALL_BOTTOM;
    _outsideInvisibleWallShapes[1]->layers = LAYER_MASK_OUTSIDE_INVISIBLE_WALL_LEFT;
    _outsideInvisibleWallShapes[2]->layers = LAYER_MASK_OUTSIDE_INVISIBLE_WALL_TOP;
    _outsideInvisibleWallShapes[3]->layers = LAYER_MASK_OUTSIDE_INVISIBLE_WALL_RIGHT;
}

//
//
//
- (void)setupChipmunkCollisionHandlers {
    // laser collision handlers
    cpSpaceAddCollisionHandler(_space, COLLISION_TYPE_LASER, COLLISION_TYPE_LASER,           CollisionBeginLaserWithLaser,  NULL, NULL, NULL, self);
    cpSpaceAddCollisionHandler(_space, COLLISION_TYPE_LASER, COLLISION_TYPE_INVISIBLE_WALL,  CollisionBeginLaserWithObject, NULL, NULL, NULL, self);
    cpSpaceAddCollisionHandler(_space, COLLISION_TYPE_LASER, COLLISION_TYPE_PLAYER,          CollisionBeginLaserWithObject, NULL, NULL, NULL, self);
    cpSpaceAddCollisionHandler(_space, COLLISION_TYPE_LASER, COLLISION_TYPE_SOLDIER,         CollisionBeginLaserWithObject, NULL, NULL, NULL, self);
    cpSpaceAddCollisionHandler(_space, COLLISION_TYPE_LASER, COLLISION_TYPE_LASER_TOWER,     CollisionBeginLaserWithObject, NULL, NULL, NULL, self);
    cpSpaceAddCollisionHandler(_space, COLLISION_TYPE_LASER, COLLISION_TYPE_SOLDIER_FACTORY, CollisionBeginLaserWithObject, NULL, NULL, NULL, self);
    cpSpaceAddCollisionHandler(_space, COLLISION_TYPE_LASER, COLLISION_TYPE_SOLDIER,         CollisionBeginLaserWithObject, NULL, NULL, NULL, self);
    cpSpaceAddCollisionHandler(_space, COLLISION_TYPE_LASER, COLLISION_TYPE_BARRIER,         CollisionBeginLaserWithObject, NULL, NULL, NULL, self);

    // laser tower collision handlers
    cpSpaceAddCollisionHandler(_space, COLLISION_TYPE_LASER_TOWER, COLLISION_TYPE_SOLDIER, CollisionBeginLaserTowerWithSoldier, NULL, NULL, NULL, self);
    
    // player ship collision handlers
    cpSpaceAddCollisionHandler(_space, COLLISION_TYPE_PLAYER, COLLISION_TYPE_BARRIER, CollisionBeginIgnore, NULL, NULL, NULL, self);
    cpSpaceAddCollisionHandler(_space, COLLISION_TYPE_PLAYER, COLLISION_TYPE_SOLDIER, CollisionBeginIgnore, NULL, NULL, NULL, self);
    
    // soldier collision handlers
    cpSpaceAddCollisionHandler(_space, COLLISION_TYPE_SOLDIER, COLLISION_TYPE_SOLDIER_FACTORY,      CollisionBeginSoldierWithObject, NULL, NULL, CollisionSeparateSoldierWithObject, self);
    cpSpaceAddCollisionHandler(_space, COLLISION_TYPE_SOLDIER, COLLISION_TYPE_SOLDIER_SPAWN_SENSOR, CollisionBeginSoldierWithObject, NULL, NULL, CollisionSeparateSoldierWithObject, self);
    cpSpaceAddCollisionHandler(_space, COLLISION_TYPE_SOLDIER, COLLISION_TYPE_BARRIER,              CollisionBeginIgnore,            NULL, NULL, NULL, self);
    
    // enemy drop collision
    cpSpaceAddCollisionHandler(_space, COLLISION_TYPE_ENEMY_DROP, COLLISION_TYPE_PLAYER, CollisionBeginEnemyDropWithPlayer, NULL, NULL, NULL, self);
}

//
//
//
- (GameMode)gameMode {
    return _currentGamePlayManager._gameMode;
}

//
//
//
- (void)registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMainMenuClosed:)
                                                 name:kNotificationMainMenuClosed
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleGamePlayManagerDeactivated:)
                                                 name:kNotificationGamePlayManagerDeactivated
                                               object:nil];
}

//
//
//
- (void)addSpriteBatchNodes {
    
    // get list
    NSArray *spriteBatchNodeList = [StageScene sharedStageScene]._spriteBatchNodeList;
    
    // add them
    [self addChild:[spriteBatchNodeList objectAtIndex:SPRITEBATCHNODE_INDEX_SPAWN]          z:ZORDER_SPRITEBATCHNODE_SPAWN];
    [self addChild:[spriteBatchNodeList objectAtIndex:SPRITEBATCHNODE_INDEX_PATHING]        z:ZORDER_SPRITEBATCHNODE_PATHING];
    [self addChild:[spriteBatchNodeList objectAtIndex:SPRITEBATCHNODE_INDEX_PLAYFIELD_01]   z:ZORDER_SPRITEBATCHNODE_PLAYFIELD_01];
    [self addChild:[spriteBatchNodeList objectAtIndex:SPRITEBATCHNODE_INDEX_PLAYFIELD_02]   z:ZORDER_SPRITEBATCHNODE_PLAYFIELD_02];
    [self addChild:[spriteBatchNodeList objectAtIndex:SPRITEBATCHNODE_INDEX_PLAYFIELD_03]   z:ZORDER_SPRITEBATCHNODE_PLAYFIELD_03];
    [self addChild:[spriteBatchNodeList objectAtIndex:SPRITEBATCHNODE_INDEX_PLAYFIELD_04]   z:ZORDER_SPRITEBATCHNODE_PLAYFIELD_04];
    [self addChild:[spriteBatchNodeList objectAtIndex:SPRITEBATCHNODE_INDEX_HUD_LOW]        z:ZORDER_SPRITEBATCHNODE_HUD_LOW];
    [self addChild:[spriteBatchNodeList objectAtIndex:SPRITEBATCHNODE_INDEX_HUD_HIGH]       z:ZORDER_SPRITEBATCHNODE_HUD_HIGH];
}

//
//
//
- (int)activate {
    if (_active) {
        return 1;
    }
    
    _active = true;
    
    // add in sprite batch nodes and any other sprites we need to worry about
    [self addChild:_backgroundSprite z:ZORDER_BACKGROUND];
    //[self addChild:_versionLabel z:ZORDER_HUD];
    [self addSpriteBatchNodes];
    
    // start displaying and set to active
    [[StageScene sharedStageScene]._scene addChild:self z:ZORDER_STAGE_LAYER];
    
    // setup and activate triangle strip patch node
    [TriangleStripParticleBatchNode createSharedTriangleStripParticleBatchNode];
    [[TriangleStripParticleBatchNode sharedTriangleStripParticleBatchNode] activate];
    
    // setup and activate laser grid since we keep it running all the time
    [LaserGrid createSharedLaserGrid];
    [[LaserGrid sharedLaserGrid] activate];
    
    // create our invisible walls
    [self setupInsideInvisibleWalls];
    [self setupOutsideInvisibleWalls];
    
    // register for notifications
    [self registerForNotifications];
    
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
    [_currentGamePlayManager deactivate];
    [self removeAllChildrenWithCleanup:false];
    [LaserGrid destroySharedLaserGrid];
    [TriangleStripParticleBatchNode destroySharedTriangleStripParticleBatchNode];
    [self destroyInvisibleWalls];
    [self removeFromParentAndCleanup:true];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    return 0;
}

//
//
//
- (int)pause {
    
    if (_paused) {
        return 1;
    }
    
    _paused = true;
    [self pauseSchedulerAndActionsRecursive:self];
    return 0;
}

//
//
//
- (void)pauseSchedulerAndActionsRecursive:(CCNode *)node {
    [node pauseSchedulerAndActions];
    for (CCNode *child in [node children]) {
        [self pauseSchedulerAndActionsRecursive:child];
    }
}

//
//
//
- (int)resume {
    if (!_paused) {
        return 1;
    }
    
    _paused = false;
    [self resumeSchedulerAndActionsRecursive:self];
    return 0;
}

//
//
//
- (void)resumeSchedulerAndActionsRecursive:(CCNode *)node {
    [node resumeSchedulerAndActions];
    for (CCNode *child in [node children]) {
        [self resumeSchedulerAndActionsRecursive:child];
    }
}

//
//
//
- (void)deactivateCurrentGamePlayManager {
    [_currentGamePlayManager deactivate];
}

//
//
//
- (void)reset {
    [self deactivateCurrentGamePlayManager];
    [[LaserGrid sharedLaserGrid] reset];
    [self resume];
}

//
//
//
- (void)update:(ccTime)elapsedTime {
    // update chipmunk stuff
    cpSpaceStep(_space, elapsedTime);
    cpSpaceHashEach(_space->staticShapes, &ChipmunkUpdate, [NSNumber numberWithFloat:elapsedTime]);
    cpSpaceHashEach(_space->activeShapes, &ChipmunkUpdate, [NSNumber numberWithFloat:elapsedTime]);
}

//
// desc: delegate for handling touch began
//
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if (!_currentGamePlayManager) {
        return false;
    }

    return [_currentGamePlayManager ccTouchBegan:touch withEvent:event];
}

//
// desc: delegate for handling touch moved
//
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    [_currentGamePlayManager ccTouchMoved:touch withEvent:event];
}

//
// desc: delegate for handling touch ended
//
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    [_currentGamePlayManager ccTouchEnded:touch withEvent:event];
}

//
//
//
- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    [_currentGamePlayManager ccTouchCancelled:touch withEvent:event];
}

//
//
//
- (void)handleMainMenuClosed:(NSNotification *)notification {
    // activate which ever game mode we need to
    GameMode gameMode = [[[notification userInfo] objectForKey:kNotificationKeyMainMenuGameMode] intValue];
    
    // if unpausing the game
    if (gameMode == kGameModeResume) {
        [[StageLayer sharedStageLayer] resume];
        return;
    }
    
    // create gameplaymanager for the game mode
    GamePlayManager *gamePlayManager = [GamePlayManager gamePlayManagerWithGameMode:gameMode];
    if (!gamePlayManager) { // if failed to create, then bail
        return;
    }
    
    // set new gameplay manager and activate
    self._currentGamePlayManager = gamePlayManager;
    [_currentGamePlayManager activate];
}

//
//
//
- (void)handleGamePlayManagerDeactivated:(NSNotification *)notification {
    self._currentGamePlayManager = nil;
    
    // reset laser grid and resume (unpause if we are paused)
    [[LaserGrid sharedLaserGrid] reset];
    [self resume];
}

//
//
//
- (void)destroySpace {
    if (_space) {
        cpSpaceFree(_space);
        _space = NULL;
    }    
}

//
//
//
- (void)destroyInvisibleWalls {
    
    for (int i=0; i < _invisibleWallCount; i++) {
        cpShape *shape = _insideInvisibleWallShapes[i];
        if (shape) {
            cpShapeFree(shape);
            _insideInvisibleWallShapes[i] = NULL;
        }
        
        shape = _outsideInvisibleWallShapes[i];
        if (shape) {
            cpShapeFree(shape);
            _outsideInvisibleWallShapes[i] = NULL;
        }
    }
}

//
// desc: dealloc
//
- (void)dealloc {
    
    // deactivate if we haven't already
    [self deactivate];
            
    // cleanup chipmunk objects
    [self destroySpace];
    
    // cleanup invisible walls
    [self destroyInvisibleWalls];
        
    // cleanup other properties
    self._backgroundSprite = nil;
    self._borderSprite = nil;
    self._currentGamePlayManager = nil;
    
    [super dealloc];
}

@end
