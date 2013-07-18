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
#import "defines.h"

//
// forward declarations
//
@class GamePlayManager;

//
// @interface StageLayer : CCLayer
//
@interface StageLayer : CCLayer {
    
    // chipmunk stuff
    cpSpace *_space;
    int _invisibleWallCount;
    cpShape *_insideInvisibleWallShapes[4];
    cpShape *_outsideInvisibleWallShapes[4];
    
    // sprites
    CCSprite *_backgroundSprite;
    CCSprite *_borderSprite;
    
    // game play manager
    GamePlayManager *_currentGamePlayManager;
    
    // state stuff
    bool _active;
    bool _paused;
}

//
// properties
//
@property (nonatomic, assign) cpSpace *_space;
@property (nonatomic, assign) int _invisibleWallCount;
@property (nonatomic, retain) CCSprite *_backgroundSprite;
@property (nonatomic, retain) CCSprite *_borderSprite;
@property (nonatomic, retain) GamePlayManager *_currentGamePlayManager;
@property (nonatomic, assign) bool _active;
@property (nonatomic, assign) bool _paused;

//
// static functions
//
+ (StageLayer *)createSharedStageLayer;
+ (StageLayer *)sharedStageLayer;
+ (void)destroySharedStageLayer;

//
// initialization
//
- (id)init;

// create sprites
- (CCSprite *)backgroundSprite;
- (CCSprite *)borderSprite;
- (CCLabelTTF *)versionLabel;

// create chipmunk stuff
- (cpSpace *)space;
- (void)setupInsideInvisibleWalls;
- (void)setupOutsideInvisibleWalls;
- (void)setupChipmunkCollisionHandlers;

// status/info
- (GameMode)gameMode;

//
// activate
//
- (void)registerForNotifications;
- (void)addSpriteBatchNodes;
- (int)activate;
- (int)deactivate;

//
// pause/resume
//
- (int)pause;
- (void)pauseSchedulerAndActionsRecursive:(CCNode *)node;
- (int)resume;
- (void)resumeSchedulerAndActionsRecursive:(CCNode *)node;

//
// manage gameplay manager
//
- (void)deactivateCurrentGamePlayManager;

//
// reset
//
- (void)reset;

//
// update
//
- (void)update:(ccTime)elapsedTime;

//
// handle touch input
//
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event;

//
// notification handlers
//
- (void)handleMainMenuClosed:(NSNotification *)notification;
- (void)handleGamePlayManagerDeactivated:(NSNotification *)notification;

//
// cleanup
//
- (void)destroySpace;
- (void)destroyInvisibleWalls;
- (void)dealloc;

@end
