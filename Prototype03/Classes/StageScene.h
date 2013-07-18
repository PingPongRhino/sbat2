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

//
// @interface StageScene : NSObject
//
@interface StageScene : NSObject {
    CCScene *_scene;
    bool _active;
    NSMutableArray *_spriteBatchNodeList;
}

//
// properties
//
@property (nonatomic, retain) CCScene *_scene;
@property (nonatomic, assign) bool _active;
@property (nonatomic, retain) NSMutableArray *_spriteBatchNodeList;

//
// static functions
//
+ (StageScene *)createSharedStageScene;
+ (StageScene *)sharedStageScene;
+ (void)destroySharedStageScene;

//
// initialization
//
- (id)init;

//
// activate/deactivate
//
- (int)activate;
- (int)deactivate;

//
// manage sprite sheet and batch nodes
//
- (void)createSpriteSheets;
- (NSMutableArray *)createSpriteBatchNodes;
- (CCSpriteBatchNode *)spriteBatchNodeWithIndex:(int)index;
- (void)destroySpriteSheets;

//
// cleanup
//
- (void)dealloc;

@end
