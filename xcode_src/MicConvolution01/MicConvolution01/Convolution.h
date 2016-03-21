//
//  Convolution.h
//  Convolution
//
//  Created by ZhongLin Yuan on 2012-10-23.
//  Copyright (c) 2012 ZhongLin Yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>


@interface Convolution : NSObject

-(float)doCorrelationWithSignal:(float *)signal ofSignalLength:(int)lenSignal AndFilter:(float *)filter ofFilterLength:(int)filterLength AndResult:(float *)result ofResultLength:(int)resultLength;

@end
