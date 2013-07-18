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
#import "BGSoundManager.h"
#import "CDAudioManager.h"
#import "StageScene.h"
#import "SimpleAudioEngine.h"
#import "SettingsManager.h"

//
// static globals
//
static BGSoundManager *_sharedBGSoundManager = nil;
static NSString *const _trackNames[] = { @"bg_bangos_jig.mp3.enc",
                                         @"bg_cowboy_coder.mp3.enc",
                                         @"bg_welcome_to_emission_control.mp3.enc" };
static const int _trackCount = 3;
static const ccTime _intermissionInterval = 5; // 5 second intermission

//
// @implementation BGSoundManager
//
@implementation BGSoundManager

//
// synthesize
//
@synthesize _active;
@synthesize _currentTrack;
@synthesize _intermissionTimer;
@synthesize _trackCompleted;
@synthesize _playTrackOperationQueue;

//
//
//
+ (BGSoundManager *)createSharedBGSoundManager {
    [BGSoundManager destroySharedBGSoundManager];
    _sharedBGSoundManager = [[BGSoundManager alloc] init];
    return _sharedBGSoundManager;
}

//
//
//
+ (BGSoundManager *)sharedBGSoundManager { return _sharedBGSoundManager; };

//
//
//
+ (void)destroySharedBGSoundManager {
    [_sharedBGSoundManager release];
    _sharedBGSoundManager = nil;
}

//
//
//
- (id)init {
    self = [super init];
    
    // init properties
    self._active = false;
    self._currentTrack = 0;
    self._intermissionTimer = 0.0f;
    self._trackCompleted = false;
	self._playTrackOperationQueue = [self setupPlayTrackOperationQueue];
    
    // init super class stuff
    [self scheduleUpdate];
    
    // set us as delegate for CDAudioManager
    [[CDAudioManager sharedManager] setBackgroundMusicCompletionListener:self selector:@selector(trackCompleted)];
    
    // attempt to pull settings from settings file first
    NSNumber *volume = [SettingsManager musicVolumeSetting];
    if (volume) {
        [self setVolume:[volume floatValue]];
    }
    else {
        [self setAdjustedVolume:0.66f];
    }
    
    volume = [SettingsManager sfxVolumeSetting];
    if (volume) {
        [self setSFXVolume:[volume floatValue]];
    }
    else {
        [self setAdjustedSFXVolume:1.0f];
    }
    
    [[BGSoundManager sharedBGSoundManager] setSFXVolume:[volume floatValue]];
    return self;
}

//
//
//
- (NSOperationQueue *)setupPlayTrackOperationQueue {
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue setMaxConcurrentOperationCount:1];
    return [operationQueue autorelease];
}

//
//
//
- (float)volume {
    return [CDAudioManager sharedManager].backgroundMusic.volume;
}

//
//
//
- (float)adjustedVolume {
    float adjustedVolume = powf([self volume], (1.0f/3.0f));
    return adjustedVolume;
}

//
//
//
- (void)setVolume:(float)volume {
    [CDAudioManager sharedManager].backgroundMusic.volume = volume;
}

//
//
//
- (void)setAdjustedVolume:(float)volume {
    float adjustVolume = powf(volume, 3.0f);
    [self setVolume:adjustVolume];
}

//
//
//
- (float)adjustedSFXVolume {
    return powf([[SimpleAudioEngine sharedEngine] effectsVolume], (1.0f/3.0f));
}

//
//
//
- (void)setSFXVolume:(float)volume {
    [[SimpleAudioEngine sharedEngine] setEffectsVolume:volume];
}

//
//
//
- (void)setAdjustedSFXVolume:(float)volume {
    float adjustVolume = powf(volume, 3.0f);
    [self setSFXVolume:adjustVolume];
    
}


//
//
//
- (int)activate {
    
    // if already active, then bail
    if (_active) {
        return 1;
    }
    
    // activate
    _active = true;
    [[StageScene sharedStageScene]._scene addChild:self];
    _currentTrack = arc4random() % _trackCount;
    [self playTrackAsync];
    
    return 0;
}

//
//
//
- (int)deactivate {
    
    // if already inactive, then bail
    if (!_active) {
        return 1;
    }
    
    // deactivate
    _active = false;
    [self removeFromParentAndCleanup:false];
    
    // stop bg music
    [[CDAudioManager sharedManager] stopBackgroundMusic];
    
    return 0;
}

//
//
//
- (void)playTrackAsync {
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(playTrackWithData:) object:nil];
    [operation setThreadPriority:0.0f]; // set to low priority
    [_playTrackOperationQueue addOperation:operation];
}

//
//
//
- (void)playTrackWithData:(id)data {
    [self playTrack];
}

//
//
//
- (void)playTrack {
    
    // stop whatever is playing
    [[CDAudioManager sharedManager] stopBackgroundMusic];
    
    // reset our flag
    _trackCompleted = false;
    
    // play current track
    NSString *trackName = _trackNames[_currentTrack];
    [[CDAudioManager sharedManager] playBackgroundMusic:trackName loop:false];
}

//
//
//
- (void)trackCompleted {
    
    // get ready to play next track
    _currentTrack++;
    if (_currentTrack >= _trackCount) {
        _currentTrack = 0;
    }
    
    // reset intermission timer
    _intermissionTimer = 0.0f;
    
    // set we completed
    _trackCompleted = true;
}

//
//
//
- (void)update:(ccTime)elapsedTime {
    
    // if track hasn't completed, then don't update intermission timer
    if (!_trackCompleted) {
        return;
    }
    
    // else update intermission timer
    _intermissionTimer += elapsedTime;
    if (_intermissionTimer >= _intermissionInterval) {
        [self playTrackAsync];
    }
}

//
//
//
- (void)dealloc {
    [self deactivate];
	self._playTrackOperationQueue = nil;
    [super dealloc];
}

@end
