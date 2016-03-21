//
//  YZZSignalProcessor.m
//  SimpleTap
//
//  Created by Kai Zou on 2012-12-01.
//  Copyright (c) 2012 ZhongLin Yuan. All rights reserved.
//

#import "YZZSignalProcessor.h"

@implementation YZZSignalProcessor

-(float)crosscorrelateLocation1:(YZZLocation *)L1 andLocation2:(YZZLocation *)L2 {
    
    float *micRef;
    float *micInput;
    float          *signal, *filter, *result;
    uint32_t        lenSignal, filterLength, resultLength;
    
    filterLength = MIC_DATA_BUFF_SIZE;
    resultLength = filterLength*2-1;
    lenSignal = ((filterLength + 3) & 0xFFFFFFFC) + resultLength;
    
    //printf("\nConvolution(resultLength = %d,filterLength=%d,lenSignal=%d)\n\n", resultLength, filterLength, lenSignal);
    micInput = L1->SensorFifo[0]->getDataLinearNormalized();//this is alloc mem, need to free later
    micRef = L2->SensorFifo[0]->getDataLinearNormalized(); //this is alloc mem, need to free later
    
    /* Allocate memory for the input operands and check its availability. */
    signal = (float *) malloc(lenSignal * sizeof(float));
    filter = (float *) malloc(filterLength * sizeof(float));
    result = (float *) malloc(resultLength * sizeof(float));
    memset(signal, 0, lenSignal*sizeof(float));
    memset(filter, 0, filterLength*sizeof(float));
    memset(result, 0, resultLength*sizeof(float));
    
    for (int i = 0; i < filterLength; i++)
        filter[i] = micInput[i];
    free(micInput);
    for (int i = 0; i < resultLength; i++)
        if (i >=resultLength-filterLength)
            signal[i] = micRef[i-filterLength+1];//filter[i - filterLength+1];
    free(micRef);
    
    //xcorr
    vDSP_conv(signal, 1, filter, 1, result, 1, resultLength, filterLength);
    float maxCorr = result[0];
    for (int i=0; i<resultLength; i++) {
        if (maxCorr<result[i]) {
            maxCorr=result[i];
        }
    }
    
    free(signal);
    free(filter);
    free(result);
    return maxCorr;
}


@end
