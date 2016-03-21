//
//  YZZDataCapturer.m
//  MicConvolution01
//
//  Created by Kai Zou on 2012-10-23.
//  Copyright (c) 2012 Kai Zou. All rights reserved.
//

#import "YZZDataCapturer.h"

@implementation YZZDataCapturer
{
    int maxMicQueueLength, currentMicQueueLengthLoc01, currentMicQueueLengthLoc02;
    int maxAccQueueLength, currentAccQueueLengthLoc01, currentAccQueueLengthLoc02;
    int maxGyrQueueLength, currentGyrQueueLengthLoc01, currentGyrQueueLengthLoc02;
}

- (YZZDataCapturer*) initWithMicQueueLen:(int)_maxMicQueueLength AccQueueLen:(int)_maxAccQueueLength GyrQueueLen:(int)_maxGyrQueueLength {
    self = [super init];
    
    self->maxMicQueueLength = _maxMicQueueLength;
    self->maxAccQueueLength = _maxAccQueueLength;
    self->maxGyrQueueLength = _maxGyrQueueLength;
    
    self->currentAccQueueLengthLoc01 = 0;
    self->currentGyrQueueLengthLoc01 = 0;
    self->currentMicQueueLengthLoc01 = 0;
    
    self->currentAccQueueLengthLoc02 = 0;
    self->currentGyrQueueLengthLoc02 = 0;
    self->currentMicQueueLengthLoc02 = 0;
    
    self->loc01AccData = [[NSMutableArray alloc]init];
    self->loc01GyrData = [[NSMutableArray alloc]init];
    self->loc01MicData = [[NSMutableArray alloc]init];
    
    self->loc02AccData = [[NSMutableArray alloc]init];
    self->loc02GyrData = [[NSMutableArray alloc]init];
    self->loc02MicData = [[NSMutableArray alloc]init];
    
    return self;
}

- (void) enqueueLoc01AccData:(id)accData {
    if (self->currentAccQueueLengthLoc01 >= self->maxAccQueueLength) {
        [self->loc01AccData dequeueCustom];
    } else {
        self->currentAccQueueLengthLoc01++;
    }
    [self->loc01AccData enqueueCustom:accData];
}

- (void) enqueueLoc01GyrData:(id)gyrData {
    if (self->currentGyrQueueLengthLoc01 >= self->maxAccQueueLength) {
        [self->loc01GyrData dequeueCustom];
    } else {
        self->currentGyrQueueLengthLoc01++;
    }
    [self->loc01GyrData enqueueCustom:gyrData];
}

- (void) enqueueLoc01MicData:(id)micData {
    if (self->currentMicQueueLengthLoc01 >= self->maxMicQueueLength) {
        [self->loc01MicData dequeueCustom];
    } else {
        self->currentMicQueueLengthLoc01++;
    }
    [self->loc01MicData enqueueCustom:micData];
}

- (void) enqueueLoc02AccData:(id)accData {
    if (self->currentAccQueueLengthLoc02 >= self->maxAccQueueLength) {
        [self->loc02AccData dequeueCustom];
    } else {
        self->currentAccQueueLengthLoc02++;
    }
    [self->loc02AccData enqueueCustom:accData];
}

- (void) enqueueLoc02GyrData:(id)gyrData {
    if (self->currentGyrQueueLengthLoc02 >= self->maxAccQueueLength) {
        [self->loc02GyrData dequeueCustom];
    } else {
        self->currentGyrQueueLengthLoc02++;
    }
    [self->loc02GyrData enqueueCustom:gyrData];
}

- (void) enqueueLoc02MicData:(id)micData {
    if (self->currentMicQueueLengthLoc02 >= self->maxMicQueueLength) {
        [self->loc02MicData dequeueCustom];
    } else {
        self->currentMicQueueLengthLoc02++;
    }
    [self->loc02MicData enqueueCustom:micData];
}

- (void) clearLoc01TemplateData {
    [self->loc01AccData removeAllObjects];
    [self->loc01GyrData removeAllObjects];
    [self->loc01MicData removeAllObjects];
    self->currentAccQueueLengthLoc01 = 0;
    self->currentGyrQueueLengthLoc01 = 0;
    self->currentMicQueueLengthLoc01 = 0;
}

- (void) clearLoc02TemplateData {
    [self->loc02AccData removeAllObjects];
    [self->loc02GyrData removeAllObjects];
    [self->loc02MicData removeAllObjects];
    self->currentAccQueueLengthLoc02 = 0;
    self->currentGyrQueueLengthLoc02 = 0;
    self->currentMicQueueLengthLoc02 = 0;
}

- (NSMutableArray*) getLoc01AccData {
    return self->loc01AccData;
}
- (NSMutableArray*) getLoc01GyrData {
    return self->loc01GyrData;
}
- (NSMutableArray*) getLoc01MicData {
    return self->loc01MicData;
}
- (NSMutableArray*) getLoc02AccData {
    return self->loc02AccData;
}
- (NSMutableArray*) getLoc02GyrData {
    return self->loc02GyrData;
}
- (NSMutableArray*) getLoc02MicData {
    return self->loc02MicData;
}

@end
