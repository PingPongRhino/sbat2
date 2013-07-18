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
#import "TerminalMenuCredits.h"
#import "MainMenuLayer.h"
#import "LabelAnimateType.h"
#import "SimpleAudioEngine.h"
#import "TerminalWindow.h"

//
// @implementation TerminalMenuCredits
//
@implementation TerminalMenuCredits

//
// synthesize
//
@synthesize _optionsLabel;
@synthesize _pingPongRhinoLink;
@synthesize _brianLangevinLink;
@synthesize _touch;
@synthesize _selectedLabel;

//
//
//
+ (id)terminalMenuWithMainMenuLayer:(MainMenuLayer *)mainMenulayer
{
    TerminalMenuCredits *terminalMenuCredits = [[TerminalMenuCredits alloc] initWithMainMenuLayer:mainMenulayer];
    return [terminalMenuCredits autorelease];
}

//
//
//
- (void)addTextToTerminal {
    
    // command line text for main menu
    [_terminalWindow addCommandLineText:@"emscntrl: credits"];
    [_terminalWindow addCommandLineText:@"->  Designer/Developer/Artist  <-"];
    [_terminalWindow addCommandLineText:@"->         Cody Sandel         <-"];
    self._pingPongRhinoLink =   [_terminalWindow addCommandLineText:@"->      pingpongrhino.com      <-"];
    [_terminalWindow addCommandLineText:@" "];
    [_terminalWindow addCommandLineText:@"->         Music/Sound         <-"];
    [_terminalWindow addCommandLineText:@"->        Brian Langevin       <-"];
    self._brianLangevinLink =   [_terminalWindow addCommandLineText:@"-> brianlangevin.com/void-star <-"];
    [_terminalWindow addCommandLineText:@" "];
    [_terminalWindow addCommandLineText:@"Powered by Cocos2d and Chipmunk"];
    [_terminalWindow addCommandLineText:@" "];
    self._optionsLabel =        [_terminalWindow addCommandLineText:@"[ Back to Options             ]"];
    [_terminalWindow addCommandLineText:@"_"];
    
    // add to label list
    self._labelList = [NSArray arrayWithObjects:_pingPongRhinoLink, _brianLangevinLink, _optionsLabel, nil];
}

//
//
//
- (void)handleTouchBegan:(UITouch *)touch {
    
    // if not active
    if (!_active || _touch) {
        return;
    }
    
    self._selectedLabel = [self getHitLabel:touch];
    
    // if no label was hit, then bail
    if (!_selectedLabel) {
        self._touch = nil;
        return;
    }
    
    // highlight selected label
    [_selectedLabel setHighlighted:true];
    
    // save off touch
    self._touch = touch;
}

//
//
//
- (void)handleTouchEnded:(UITouch *)touch {
    
    if (!_active || touch != _touch) {
        return;
    }
    
    // play sound effect
    [[SimpleAudioEngine sharedEngine] playEffect:SFX_MENU_CLICK pitch:1.0f pan:0.0f gain:SFX_MENU_CLICK_GAIN];
    
    // unhighlight selected text
    [_selectedLabel setHighlighted:false];
    
    // clear touch
    self._touch = nil;
    
    // get label touch ended on
    LabelAnimateType *label = [self getHitLabel:touch];
    
    // if doens't end on same label then bail
    if (label != _selectedLabel) {
        return;
    }
    
    if (_selectedLabel == _pingPongRhinoLink) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.pingpongrhino.com/sbat2gxotheos/"]];
        return;
    }
    
    if (_selectedLabel == _brianLangevinLink) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://brianlangevin.com/void-star/"]];
        return;
    }
    
    // do action based on item that was selected
    if (_selectedLabel == _optionsLabel) {
        [_mainMenuLayer openMenu:kMenuScreenOptions];
        return;
    }
}

@end
