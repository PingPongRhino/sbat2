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
#import <GameKit/GameKit.h>
#import "defines.h"

//
// @interface LeaderboardMgr
//
@interface LeaderboardMgr : NSObject <GKLeaderboardViewControllerDelegate> {
    bool _appleGameCenterSupported;
    UIViewController *_viewController;
    NSLock *_fileLock;
}

//
// properties
//
@property (atomic, assign) bool _appleGameCenterSupported;
@property (nonatomic, assign) UIViewController *_viewController;
@property (nonatomic, retain) NSLock *_fileLock;

//
// manager singleton
//
+ (id)createSharedLeaderboardMgr;
+ (id)sharedLeaderboardMgr;
+ (void)destroySharedLeaderboardMgr;

//
// filenames
//
+ (NSString *)highScoreFilename;
+ (NSString *)pendingGKScoreFilename;

//
// init
//
- (id)init;

//
// archive/unarchive functions
//
- (void)archiveAndEncryptRootObject:(id)rootObject toFilename:(NSString *)filename;
- (id)unarchiveEncryptedDataWithFilename:(NSString *)filename;

//
// manage high score device high score
//
- (void)setHighScore:(int64_t)highScore;
- (int64_t)highScore;

//
// apple game center stuff
//
- (bool)isGameCenterAPIAvailable;
- (void)authenticateLocalPlayer:(bool)logError;
- (void)reportScore:(int64_t)score forCategory:(NSString *)category;
- (void)reportScore:(GKScore *)score;
- (void)addPendingGKScore:(GKScore *)score;
- (NSMutableSet *)pendingGKScores;
- (void)sendPendingGKScores;
- (int64_t)getCurrentLeaderboardScore:(NSString *)category;
- (void)showLeaderboard;
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController;

//
// cleanup
//
- (void)dealloc;

@end
