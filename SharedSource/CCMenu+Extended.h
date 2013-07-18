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
// defines
//
typedef enum {
    CCMISelectedIndexUnknown = 0,
    CCMISelectedIndexNormal = 1,
    CCMISelectedIndexHighlighted = 2
} CCMISelectedIndex;

//
// @implementation CCMenu (Extended)
//
@interface CCMenu (Extended)

//
// desc: calculates lower left point of menu bar where x, y is the lower left in local space
//
// returns: returns lower left CGPoint in CCMenu's local space
//
- (CGPoint)lowerLeftPointInLocalSpace;

//
// desc: this just mutliples lowerLeftPointInLocalSpace by -1
//
// returns: lowerLeftPointInLocalSpace * -1
//
- (CGPoint)inverseLowerLeftPointInLocalSpace;

//
// desc: creates a menu item and adds it to the menu
//
// params: tag[in] - tag to associated with the item
//         normalImage[in] - image to be displayed when item is in it's normal state
//         selectedImage[in] - image to be displayed when item is in it's selected state
//         target[in] - delegate to handle event if button it tapped
//         action[in] - message to call on target when button is tapped
//
- (CCMenuItemToggle *)addMenuItem:(int)tag
					 normalSprite:(CCSprite *)normalSprite 
				   selectedSprite:(CCSprite *)selectedSprite
		  highlightedNormalSprite:(CCSprite *)highlightedNormalSprite
		highlightedSelectedSprite:(CCSprite *)highlightedSelectedSprite
						   target:(id)target
						   action:(SEL)action;

//
// desc: wrapper for addMenuItem function above, this is just to
//       cut down on params if you don't want to set the selected version
//       of each button
//
- (CCMenuItemToggle *)addMenuItem:(int)tag
					 normalSprite:(CCSprite *)normalSprite 
          highlightedNormalSprite:(CCSprite *)highlightedNormalSprite
						   target:(id)target
						   action:(SEL)action;

//
// desc: deselects all menu items and selects the itemToBeSelected
//
// params: itemToBeSelecteds[in] - item to be selected or set to nil
//                                 to unselect all items
//
// returns: returns the last item in the last that was currently selected
//
- (CCMenuItemToggle *)highlightSingleMenuItem:(CCMenuItemToggle *)itemToBeHighlighted;

//
// desc: toggle visibility on all children and the menu
//
// params: _visible[in] - true to make objects visible, false to make invisible
//
- (void)toggleVisibility:(bool)_visible;

//
// desc: enable or disable the menu
//
// params: enable[in] - if true, then menu is interactive
//                      if false, then menu is not interactive
//
- (void)enableMenu:(bool)enable;

//
// desc: gets the height of the first child object, this doesn't
//       check the array size, so it will blow up if you don't have
//       any children in the menu
//
// returns: returns height of the first child
//
- (float)heightOfFirstChild;

@end
