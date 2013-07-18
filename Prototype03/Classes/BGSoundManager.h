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
// @interface BGSoundManager
//
@interface BGSoundManager : CCNode {
    bool _active;
    int _currentTrack;
    ccTime _intermissionTimer;
    bool _trackCompleted;
	NSOperationQueue *_playTrackOperationQueue;
}

//
// properties
//
@property (nonatomic, assign) bool _active;
@property (nonatomic, assign) int _currentTrack;
@property (nonatomic, assign) ccTime _intermissionTimer;
@property (nonatomic, assign) bool _trackCompleted;
@property (nonatomic, retain) NSOperationQueue *_playTrackOperationQueue;

//
// static functions
//
+ (BGSoundManager *)createSharedBGSoundManager;
+ (BGSoundManager *)sharedBGSoundManager;
+ (void)destroySharedBGSoundManager;

//
// functions
//
- (id)init;
- (NSOperationQueue *)setupPlayTrackOperationQueue;
- (float)volume;
- (void)setVolume:(float)volume;
- (void)setAdjustedVolume:(float)volume;
- (float)adjustedVolume;
- (void)setSFXVolume:(float)volume;
- (void)setAdjustedSFXVolume:(float)volume;
- (float)adjustedSFXVolume;
- (int)activate;
- (int)deactivate;
- (void)playTrackAsync;
- (void)playTrackWithData:(id)data;
- (void)playTrack;
- (void)trackCompleted;
- (void)update:(ccTime)elapsedTime;
- (void)dealloc;

@end
