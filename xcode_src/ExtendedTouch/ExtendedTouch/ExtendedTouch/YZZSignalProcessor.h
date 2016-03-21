//
//  YZZSignalProcessor.h
//  SimpleTap
//
//  Created by Kai Zou on 2012-12-01.
//  Copyright (c) 2012 ZhongLin Yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZZLocation.h"
#import <Accelerate/Accelerate.h>

@interface YZZSignalProcessor : NSObject

-(float)crosscorrelateLocation1:(YZZLocation *)L1 andLocation2:(YZZLocation *)L2;

@end
