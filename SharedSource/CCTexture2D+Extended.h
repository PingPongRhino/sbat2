//
//  CCTexture2D+Extended.h
//  Prototype03
//
//  Created by Cody Sandel on 4/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//
// includes
//
#import <Foundation/Foundation.h>
#import "cocos2d.h"

//
// forward declarations
//
@class CubicBezier;

//
// @interface CCTexture2D (Extended)
//
@interface CCTexture2D (Extended)

//
//
//
- (void)drawAtPoint:(CGPoint)point texOffset:(CGPoint)texOffset;

//
//
//
- (void)drawInRect:(CGRect)rect texOffset:(CGPoint)texOffset;

@end
