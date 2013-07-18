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

#import "NSMutableArray+Extended.h"


@implementation NSMutableArray (Extended)

//
//
//
+ (NSMutableArray *)arrayWithSize:(int)size {
	NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:size];
	for (int i=0; i < size; i++)
		[tempArray addObject:[NSNull null]];
	return tempArray;
}

//
//
//
- (id)popLastObject {
    
    // if array is empty, then return
    if ([self count] <= 0)
        return nil;
    
    // else get last object and delete it from queue
    id object = [self lastObject];
    [self removeLastObject];
    return object; // return the object
}

@end
