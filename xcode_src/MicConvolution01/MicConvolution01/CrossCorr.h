//
//  CrossCorr.h
//  MicConvolution01
//
//  Created by Kai Zou on 2012-10-23.
//  Copyright (c) 2012 Kai Zou. All rights reserved.
//

#ifndef __MicConvolution01__CrossCorr__
#define __MicConvolution01__CrossCorr__

#include <iostream>
#include <Accelerate/Accelerate.h>
//#include <Foundation/Foundation.h>

class CrossCorr {
public:
    float doCrossCorr(float* A, float* B, float* C);
};

#endif /* defined(__MicConvolution01__CrossCorr__) */
