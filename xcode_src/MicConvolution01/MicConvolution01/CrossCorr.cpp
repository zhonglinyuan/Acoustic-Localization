//
//  CrossCorr.cpp
//  MicConvolution01
//
//  Created by Kai Zou on 2012-10-23.
//  Copyright (c) 2012 Kai Zou. All rights reserved.
//

#include "CrossCorr.h"


float CrossCorr::doCrossCorr(float *A, float *B, float *C) {
    
    long size_B = sizeof(B);
    long size_C = sizeof(C);
    
    vDSP_conv(A, 1, B, 1, C, 1, size_C, size_B);
    
    int i;
    float largest = C[0];
    
    for(i=0;i<sizeof(C);i++)
    {
        if(C[i]>largest)
        {
            largest = C[i];
        }
    }
    
    return largest;

    
}