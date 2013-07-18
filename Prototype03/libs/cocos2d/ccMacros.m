//
//  ccMacros.m
//  Prototype03
//
//  Created by Cody Sandel on 8/13/12.
//  Copyright (c) 2012 Cody Sandel. All rights reserved.
//

//
// includes
//
#include "ccMacros.h"

//
//
//
CGRect CC_RECT_PIXELS_TO_POINTS(CGRect pixels) {
            
    if (CC_CONTENT_SCALE_FACTOR() == 1) {
        return pixels;
    }
    
    return CGRectMake(CGRectGetMinX(pixels) / CC_CONTENT_SCALE_FACTOR(),
                      CGRectGetMinY(pixels) / CC_CONTENT_SCALE_FACTOR(),
                      CGRectGetWidth(pixels) / CC_CONTENT_SCALE_FACTOR(),
                      CGRectGetHeight(pixels) / CC_CONTENT_SCALE_FACTOR());
}

//
//
//
CGRect CC_RECT_POINTS_TO_PIXELS(CGRect points) {
    
    if (CC_CONTENT_SCALE_FACTOR() == 1) {
        return points;
    }
    
    return CGRectMake(CGRectGetMinX(points) * CC_CONTENT_SCALE_FACTOR(),
                      CGRectGetMinY(points) * CC_CONTENT_SCALE_FACTOR(),
                      CGRectGetWidth(points) * CC_CONTENT_SCALE_FACTOR(),
                      CGRectGetHeight(points) * CC_CONTENT_SCALE_FACTOR());
}