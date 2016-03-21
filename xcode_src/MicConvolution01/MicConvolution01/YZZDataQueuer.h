//
//  YZZDataQueuer.h
//  MicConvolution01
//
//  Created by Kai Zou on 2012-10-23.
//  Copyright (c) 2012 Kai Zou. All rights reserved.
//

#ifndef __MicConvolution01__YZZDataQueuer__
#define __MicConvolution01__YZZDataQueuer__

#include <iostream>
#include <vector>

#include "CircularBuffer.h"

#define ACC_DATA_LEN 1000000
#define GYR_DATA_LEN 1000000
#define MIC_DATA_LEN 1000000

class YZZDataQueuer
{
//private:
    
public:
    int currLoc01AccDataLen;
    int currLoc01GyrDataLen;
    int currLoc01MicDataLen;
    
    int currLoc02AccDataLen;
    int currLoc02GyrDataLen;
    int currLoc02MicDataLen;
    
    int inputAccDataLen;
    int inputGyrDataLen;
    int inputMicDataLen;

    CircularBuffer *loc01AccData = new CircularBuffer(ACC_DATA_LEN);
    CircularBuffer *loc01GyrData = new CircularBuffer(GYR_DATA_LEN);
    CircularBuffer *loc01MicData = new CircularBuffer(MIC_DATA_LEN);
    
    CircularBuffer *loc02AccData = new CircularBuffer(ACC_DATA_LEN);
    CircularBuffer *loc02GyrData = new CircularBuffer(GYR_DATA_LEN);
    CircularBuffer *loc02MicData = new CircularBuffer(MIC_DATA_LEN);
    
    CircularBuffer *inputAccData = new CircularBuffer(ACC_DATA_LEN);
    CircularBuffer *inputGyrData = new CircularBuffer(GYR_DATA_LEN);
    CircularBuffer *inputMicData = new CircularBuffer(MIC_DATA_LEN);
    
/* bill did it
    std::vector<float> loc01AccData;
    std::vector<float> loc01GyrData;
    std::vector<float> loc01MicData;
    std::vector<float> loc02AccData;
    std::vector<float> loc02GyrData;
    std::vector<float> loc02MicData;
    std::vector<float> inputAccData;
    std::vector<float> inputGyrData;
    std::vector<float> inputMicData;
 */
    
//    YZZDataQueuer();
    
/* bill did it
    void enqueueLoc01AccData(float accData);
    void enqueueLoc01GyrData(float gyrData);
    void enqueueLoc01MicData(float micData);
    
    void enqueueLoc02AccData(float accData);
    void enqueueLoc02GyrData(float gyrData);
    void enqueueLoc02MicData(float micData);
    
    void enqueueInputAccData(float accData);
    void enqueueInputGyrData(float gyrData);
    void enqueueInputMicData(float micData);
*/
    /*
    - (void) clearLoc01TemplateData;
    - (void) clearLoc02TemplateData;
    
    - (NSMutableArray*) getLoc01MicData;
    - (NSMutableArray*) getLoc01AccData;
    - (NSMutableArray*) getLoc01GyrData;
    
    - (NSMutableArray*) getLoc02MicData;
    - (NSMutableArray*) getLoc02AccData;
    - (NSMutableArray*) getLoc02GyrData;
     */
    
};


#endif /* defined(__MicConvolution01__YZZDataQueuer__) */
