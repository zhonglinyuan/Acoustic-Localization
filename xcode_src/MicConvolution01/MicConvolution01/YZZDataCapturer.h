//
//  YZZDataCapturer.h
//  MicConvolution01
//
//  Created by Kai Zou on 2012-10-23.
//  Copyright (c) 2012 Kai Zou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSMutableArray+FixedSizeQueueAdditions.h"

@interface YZZDataCapturer : NSObject
{
    NSMutableArray *loc01AccData;
    NSMutableArray *loc01GyrData;
    NSMutableArray *loc01MicData;
    
    NSMutableArray *loc02AccData;
    NSMutableArray *loc02GyrData;
    NSMutableArray *loc02MicData;
}

- (YZZDataCapturer*) initWithMicQueueLen:(int)micQueueLength AccQueueLen:(int)accQueueLength GyrQueueLen:(int)gyrQueueLength;

- (void) enqueueLoc01AccData:(id)accData;
- (void) enqueueLoc01GyrData:(id)gyrData;
- (void) enqueueLoc01MicData:(id)micData;

- (void) enqueueLoc02AccData:(id)accData;
- (void) enqueueLoc02GyrData:(id)gyrData;
- (void) enqueueLoc02MicData:(id)micData;

- (void) clearLoc01TemplateData;
- (void) clearLoc02TemplateData;

- (NSMutableArray*) getLoc01MicData;
- (NSMutableArray*) getLoc01AccData;
- (NSMutableArray*) getLoc01GyrData;

- (NSMutableArray*) getLoc02MicData;
- (NSMutableArray*) getLoc02AccData;
- (NSMutableArray*) getLoc02GyrData;

@end
