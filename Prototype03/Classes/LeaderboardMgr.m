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
#import "LeaderboardMgr.h"
#import "CryptUtils.h"
#import "cocos2d.h"

//
// static globals
//
static LeaderboardMgr *_sharedLeaderboardMgr = nil;
static NSString * const kHighScoreFilename = @"HighScore";
static NSString * const kPendingGKScoreFilename = @"PendingGKScores";

//
// @implementation LeaderboardMgr
//
@implementation LeaderboardMgr

@synthesize _appleGameCenterSupported;
@synthesize _viewController;
@synthesize _fileLock;

//
//
//
+ (id)createSharedLeaderboardMgr {
    [LeaderboardMgr destroySharedLeaderboardMgr];
    _sharedLeaderboardMgr = [[LeaderboardMgr alloc] init];
    return _sharedLeaderboardMgr;
}

//
//
//
+ (id)sharedLeaderboardMgr { return _sharedLeaderboardMgr; }

//
//
//
+ (void)destroySharedLeaderboardMgr {
    if (_sharedLeaderboardMgr) {
        [_sharedLeaderboardMgr release];
        _sharedLeaderboardMgr = nil;
    }
}

//
//
//
+ (NSString *)highScoreFilename {
    return [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), kHighScoreFilename];
}

//
//
//
+ (NSString *)pendingGKScoreFilename {
    return [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), kPendingGKScoreFilename];
}

//
//
//
- (id)init {
    self = [super init];
    self._appleGameCenterSupported = [self isGameCenterAPIAvailable];
    self._viewController = nil;
    self._fileLock = [[[NSLock alloc] init] autorelease];
    return self;
}

//
//
//
- (void)archiveAndEncryptRootObject:(id)rootObject toFilename:(NSString *)filename {
    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:rootObject];
    unsigned char *encryptedDataPtr = NULL;
    int length = CCEncryptMemory((unsigned char *)[archivedData bytes], [archivedData length], &encryptedDataPtr);
    
    if (!encryptedDataPtr) {
        return;
    }
    
    NSData *encryptedData = [NSData dataWithBytes:encryptedDataPtr length:length];
    [encryptedData writeToFile:filename atomically:false];
    free(encryptedDataPtr);
    encryptedDataPtr = NULL;
}
//
//
//
- (id)unarchiveEncryptedDataWithFilename:(NSString *)filename {
    // get encyprted pending gk scores that failed to send
    NSData *encData = [NSData dataWithContentsOfFile:filename];
    
    // no pending gk scores, so we are done
    if (!encData) {
        return nil;
    }
    
    // decrypt data
    unsigned char *decryptedData = NULL;
    int length = CCDecryptMemory((unsigned char *)[encData bytes], [encData length], &decryptedData);
    if (!decryptedData) {
        NSLog(@"Failed to load %@, failed to decrypt.", filename);
        return nil;
    }
    
    // stick in nsdata and cleanup memory
    NSData *archivedData = [NSData dataWithBytes:decryptedData length:length];
    free(decryptedData);
    decryptedData = NULL;
    
    // generate dictionary from plist data
    return [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];
}

//
//
//
- (void)setHighScore:(int64_t)highScore {
    [_fileLock lock];
    [[NSFileManager defaultManager] removeItemAtPath:[LeaderboardMgr highScoreFilename] error:nil];
    [self archiveAndEncryptRootObject:[NSNumber numberWithUnsignedLongLong:highScore] toFilename:[LeaderboardMgr highScoreFilename]];
    [_fileLock unlock];
}

//
//
//
- (int64_t)highScore {
    [_fileLock lock];
    NSNumber *number = [self unarchiveEncryptedDataWithFilename:[LeaderboardMgr highScoreFilename]];
    [_fileLock unlock];
    return [number unsignedLongLongValue];
}

//
//
//
- (bool)isGameCenterAPIAvailable {
    
    // Check for presence of GKLocalPlayer class.
    BOOL localPlayerClassAvailable = (NSClassFromString(@"GKLocalPlayer")) != nil;
    
    // The device must be running iOS 4.1 or later.    
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    return (localPlayerClassAvailable && osVersionSupported);
}

//
//
//
- (void)authenticateLocalPlayer:(bool)logError {
    
    // is game center isn't supported, then bail
    if (!_appleGameCenterSupported) {
        return;
    }
    
    __block bool blockLogError = logError;
    
    // else try to authenticate player
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    [localPlayer authenticateWithCompletionHandler:^(NSError *error) {
        
        if (error && blockLogError) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
            [alert show];
            [alert autorelease];
        }
        
        if ([error code] == GKErrorNotSupported) {
            self._appleGameCenterSupported = false;
            return;
        }
        
        // if not error, then try sending any pending scores we got laying around
        if (error == nil) {
            [self sendPendingGKScores];
        }
    }];
}

//
//
//
- (void)reportScore:(int64_t)score forCategory:(NSString *)category {
    
    // update high score in file
    if (score > [self highScore]) {
        [self setHighScore:score];
    }
    
    if (!_appleGameCenterSupported) {
        return;
    }
    
    // send score
    GKScore *scoreReporter = [[[GKScore alloc] initWithCategory:category] autorelease];
    scoreReporter.value = score;
    [self reportScore:scoreReporter];
    
    // try sending any pending scores we had laying around
    [self sendPendingGKScores];
}

//
//
//
- (void)reportScore:(GKScore *)score {
    
    // if no apple game center support, then bail
    if (!_appleGameCenterSupported) {
        return;
    }
    
    [score reportScoreWithCompletionHandler:^(NSError *error) {
        if (error != nil) {
            [[LeaderboardMgr sharedLeaderboardMgr] addPendingGKScore:score];
        }
    }];
}

//
//
//
- (void)addPendingGKScore:(GKScore *)score {
    
    // if we don't have apple game center support, then forget about it
    if (!_appleGameCenterSupported) {
        return;
    }
    
    [_fileLock lock];
    
    // get current pending and add score to list
    NSMutableSet *pendingScores = [self pendingGKScores];
    [pendingScores addObject:score];
    
    // kill the old pending
    [[NSFileManager defaultManager] removeItemAtPath:[LeaderboardMgr pendingGKScoreFilename] error:nil];
    
    // generate new one
    [self archiveAndEncryptRootObject:pendingScores toFilename:[LeaderboardMgr pendingGKScoreFilename]];
    
    // unlock file
    [_fileLock unlock];
}

//
//
//
- (NSMutableSet *)pendingGKScores {
    NSMutableSet *pendingScores = [self unarchiveEncryptedDataWithFilename:[LeaderboardMgr pendingGKScoreFilename]];
    return (pendingScores) ? pendingScores : [NSMutableSet set];
}

//
//
//
- (void)sendPendingGKScores {
    
    if (!_appleGameCenterSupported) {
        return;
    }
    
    // lock file
    [_fileLock lock];
    
    // get pending scores
    NSSet *pendingScores = [self pendingGKScores];
    
    // if success, then delete old file
    [[NSFileManager defaultManager] removeItemAtPath:[LeaderboardMgr pendingGKScoreFilename] error:nil];
    
    // unlock file
    [_fileLock unlock];
    
    // try to send the scores that failed
    for (GKScore *score in pendingScores) {
        [self reportScore:score];
    }
}

//
//
//
- (int64_t)getCurrentLeaderboardScore:(NSString *)category {
    
    int64_t myScore = 0;
    
    if (!_appleGameCenterSupported) {
        // pull score from file instead of game center
        return myScore;
    }
    
    GKLeaderboard *leaderBoardRequest = [[[GKLeaderboard alloc] init] autorelease];
    if (!leaderBoardRequest) {
        return myScore;
    }
    
    leaderBoardRequest.timeScope = GKLeaderboardTimeScopeAllTime;
    leaderBoardRequest.range = NSMakeRange(1, 1);
    
    __block LeaderboardMgr *leaderboardMgr = self;
    [leaderBoardRequest loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error) {
        if (error != nil) {
            // handle the error.
            NSLog(@"Error retrieving score. %d: %@", [error code], [error description]);
        }
        
        if (scores != nil) {
            int64_t localPlayerHighScore = leaderBoardRequest.localPlayerScore.value;
            if (localPlayerHighScore > [leaderboardMgr highScore]) {
                [leaderboardMgr setHighScore:localPlayerHighScore];
            }
        }
    }];
    
    return myScore;
}

//
//
//
- (void)showLeaderboard {
    
    if (!_appleGameCenterSupported) {
        return;
    }
    
    // if we aren't authenticated, then authenticate first
    if (![GKLocalPlayer localPlayer].isAuthenticated) {
        [self authenticateLocalPlayer:true];
    }
    
    // bring up leaderboard
    GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
    if (leaderboardController != nil) {
        leaderboardController.leaderboardDelegate = self;
        [_viewController presentModalViewController:leaderboardController animated:YES];
    }
}

//
//
//
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController {
    [_viewController dismissModalViewControllerAnimated:YES];
}

//
//
//
- (void)dealloc {
    self._viewController = nil;
    self._fileLock = nil;
    [super dealloc];
}


@end
