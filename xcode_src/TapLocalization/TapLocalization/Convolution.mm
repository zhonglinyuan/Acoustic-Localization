//
//  Convolution.m
//  Convolution
//
//  Created by ZhongLin Yuan on 2012-10-23.
//  Copyright (c) 2012 ZhongLin Yuan. All rights reserved.
//

#import "Convolution.h"

@implementation Convolution

-(float)doCorrelationWithSignal:(float *)signal ofSignalLength:(int)lenSignal AndFilter:(float *)filter ofFilterLength:(int)filterLength AndResult:(float *)result ofResultLength:(int)resultLength
{
    
    vDSP_conv(signal, 1, filter, 1, result, 1, resultLength, filterLength);
    
    int i;
    float largest = result[0];
    for(i=0;i<resultLength;i++)
        if(result[i]>largest)
            largest = result[i];
    return largest;
}

@end
