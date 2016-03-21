//
//  Location.h
//  SimpleTap
//
//  Created by ZhongLin Yuan on 2012-11-17.
//  Copyright (c) 2012 ZhongLin Yuan. All rights reserved.
//

#ifndef __SimpleTap__Location__
#define __SimpleTap__Location__

#include <iostream>
#include "FixedFifo.h"

#define kNumDrawBuffers 12
#define kDefaultDrawSamples 1024
#define kMinDrawSamples 256
#define kMaxDrawSamples 4096

#define DATA_BUFF_STRUCT_SIZE 40
#define DATA_BUFF_STRUCT_SIZE_TRIGGER DATA_BUFF_STRUCT_SIZE*0.5
#define MIC_DATA_BUFF_SIZE DATA_BUFF_STRUCT_SIZE*kMinDrawSamples
#define MIC_DATA_BUFF_SIZE_TRIGGER DATA_BUFF_STRUCT_SIZE*kMinDrawSamples*0.5

class Location{
  
public:
    FixedFifo *MicFifo;
    FixedFifo *AccZFifo;
    FixedFifo *GyroXFifo;
    FixedFifo *GyroYFifo;
    Location *nextLocation;
    
    Location();
    ~Location();
    
    void ClearAllBuffers();
};
#endif /* defined(__SimpleTap__Location__) */

