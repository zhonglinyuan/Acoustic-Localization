//
//  NSMutableArray+FixedSizeQueueAdditions.m
//  MicConvolution01
//
//  Created by Kai Zou on 2012-10-23.
//  Copyright (c) 2012 Kai Zou. All rights reserved.
//

#import "NSMutableArray+FixedSizeQueueAdditions.h"

@implementation NSMutableArray (FixedSizeQueueAdditions)

- (id) dequeueCustom {
    if ([self count] == 0) return nil;
    id headObject = [self objectAtIndex:0];
    if (headObject != nil) {
        [self removeObjectAtIndex:0];
    }
    return headObject;
}

// Add to the tail of the queue (no one likes it when people cut in line!)
- (void) enqueueCustom:(id)anObject {
    [self addObject:anObject];
    //this method automatically adds to the end of the array
}
@end