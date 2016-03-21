//
//  my_helper.h
//  AudioData3
//
//  Created by ZhongLin Yuan on 2012-09-13.
//  Copyright (c) 2012 ZhongLin Yuan. All rights reserved.
//


#if !defined(__rio_helper_h__)
#define __rio_helper_h__

#include <AudioToolbox/AudioToolbox.h>
#include <AudioUnit/AudioUnit.h>
#include <stdio.h>

#include "CAXException.h"
#include "CAStreamBasicDescription.h"

#include "FixedFifo.h"


#define kNumDrawBuffers 12
#define kDefaultDrawSamples 1024
#define kMinDrawSamples 256
#define kMaxDrawSamples 4096

//IMPORTANT?#define DATA_BUFF_STRUCT_SIZE 40
//IMPORTANT?#define DATA_BUFF_STRUCT_SIZE_TRIGGER DATA_BUFF_STRUCT_SIZE*0.5
//IMPORTANT?#define MIC_DATA_BUFF_SIZE DATA_BUFF_STRUCT_SIZE*kMinDrawSamples
//IMPORTANT?#define MIC_DATA_BUFF_SIZE_TRIGGER DATA_BUFF_STRUCT_SIZE*kMinDrawSamples*0.5
//#define OUTPUT_MIC_CONV_SIZE DATA_BUFF_STRUCT_SIZE*2

extern int drawBufferIdx;
extern int drawBufferLen;
extern int drawBufferLen_alloced;
extern int audioBufferHasNewData;

extern volatile int global_readingSensors;

extern SInt8 *drawBuffers[];
extern UInt64 *clockTime;

int SetupRemoteIO (AudioUnit& inRemoteIOUnit, AURenderCallbackStruct inRenderProcm, CAStreamBasicDescription& outFormat);
void SilenceData(AudioBufferList *inData);

class DCRejectionFilter
{
public:
	DCRejectionFilter(Float32 poleDist = DCRejectionFilter::kDefaultPoleDist);
    
	void InplaceFilter(Float32* ioData, UInt32 numFrames);
	void Reset();
    
protected:
	
	// State variables
	Float32 mY1;
	Float32 mX1;
	
	static const Float32 kDefaultPoleDist;
};

#endif
