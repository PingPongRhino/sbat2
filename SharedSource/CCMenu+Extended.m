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
#import "CCMenu+Extended.h"
#import "chipmunk.h"

//
// @implementation CCMenu (Extended)
//
@implementation CCMenu (Extended)

//
// - (CGPoint)lowerLeftPointInLocalSpace {
//
- (CGPoint)lowerLeftPointInLocalSpace {

	CGPoint point = CGPointMake(0, 0);
	
	for (CCMenuItem *menuItem in self.children) {
		CGRect itemRect = menuItem.rect;
		if (itemRect.origin.x < point.x)
			point.x = itemRect.origin.x;
		
		if (itemRect.origin.y < point.y)
			point.y = itemRect.origin.y;
	}
	
	return point;
}

//
// desc: see header
//
- (CGPoint)inverseLowerLeftPointInLocalSpace {
	return cpvmult([self lowerLeftPointInLocalSpace], -1);
}

//
// desc: see header
//
- (CCMenuItemToggle *)addMenuItem:(int)tag
					 normalSprite:(CCSprite *)normalSprite 
				   selectedSprite:(CCSprite *)selectedSprite
		  highlightedNormalSprite:(CCSprite *)highlightedNormalSprite
		highlightedSelectedSprite:(CCSprite *)highlightedSelectedSprite
						   target:(id)target
						   action:(SEL)action
{
	// create normal image
	CCMenuItemSprite *normalItem = [CCMenuItemSprite itemFromNormalSprite:normalSprite 
														   selectedSprite:selectedSprite];
	
	// create highlighted image
	CCMenuItemSprite *highlightedItem = [CCMenuItemSprite itemFromNormalSprite:highlightedNormalSprite 
																selectedSprite:highlightedSelectedSprite];
	
	// create menu items
	CCMenuItemToggle *menuItem = [CCMenuItemToggle itemWithTarget:target 
														 selector:action 
															items:normalItem, highlightedItem, nil];
	menuItem.tag = tag;
	[self addChild:menuItem];
	return menuItem;
}

//
//
//
- (CCMenuItemToggle *)addMenuItem:(int)tag
					 normalSprite:(CCSprite *)normalSprite 
          highlightedNormalSprite:(CCSprite *)highlightedNormalSprite
						   target:(id)target
						   action:(SEL)action {
	
	CCMenuItemToggle *menuItem = [self addMenuItem:(int)tag
									  normalSprite:normalSprite 
									selectedSprite:nil
						   highlightedNormalSprite:highlightedNormalSprite
						 highlightedSelectedSprite:nil
											target:target
											action:action];
	return menuItem;
}

//
//
//
- (CCMenuItemToggle *)highlightSingleMenuItem:(CCMenuItemToggle *)itemToBeHighlighted {
	
	CCMenuItemToggle *prevHighlightedItem = nil;
	
	for (CCMenuItemToggle *menuItem in self.children) {
		
		// if item isn't highlighted
		if (menuItem.selectedIndex == CCMISelectedIndexNormal)
			continue; // then we don't care about it
		
		// set our previous highlighted item
		prevHighlightedItem = menuItem;
		if (menuItem == itemToBeHighlighted)
			continue; // if this guy was already highlighted then skip
		
		// unhilight this item
		[menuItem setSelectedIndex:CCMISelectedIndexNormal];
	}
	
	if (itemToBeHighlighted)
		[itemToBeHighlighted setSelectedIndex:CCMISelectedIndexHighlighted];
	
	return prevHighlightedItem;
}

//
//
//
- (float)heightOfFirstChild {
	CCMenuItem *menuItem = [self.children objectAtIndex:0];
	return menuItem.rect.size.height;
}

//
//
//
- (void)toggleVisibility:(bool)_visible {
	
	self.visible = _visible;
	
	for (CCMenuItem *menuItem in self.children)
		menuItem.visible = _visible;
}

//
//
//
- (void)enableMenu:(bool)enable {
	for (CCMenuItem *menuItem in self.children)
		[menuItem setIsEnabled:enable];
}

@end
