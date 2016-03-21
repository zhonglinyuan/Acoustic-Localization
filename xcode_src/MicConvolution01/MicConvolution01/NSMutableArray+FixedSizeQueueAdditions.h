//
//  NSMutableArray+FixedSizeQueueAdditions.h
//  MicConvolution01
//
//  Created by Kai Zou on 2012-10-23.
//  Copyright (c) 2012 Kai Zou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (FixedSizeQueueAdditions)

- (id) dequeueCustom;
- (void) enqueueCustom:(id)anObject;


@end
