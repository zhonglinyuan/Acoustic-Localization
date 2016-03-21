//
//  my_helper.h
//  AudioData3
//
//  Created by ZhongLin Yuan on 2012-09-13.
//  Copyright (c) 2012 ZhongLin Yuan. All rights reserved.
//


#if !defined(__rio_helper_h__)
#define __rio_helper_h__

#include "CAStreamBasicDescription.h"


#define kNumDrawBuffers 12
#define kDefaultDrawSamples 1024
#define kMinDrawSamples 256
#define kMaxDrawSamples 4096

#define DATA_BUFF_STRUCT_SIZE 1000000

extern int drawBufferIdx;
extern int drawBufferLen;
extern int drawBufferLen_alloced;
extern int audioBufferHasNewData;

extern volatile int global_readingSensors;

extern SInt8 *drawBuffers[];
extern UInt64 *clockTime;

struct AudioDataStruct {
    SInt8 audioValue[kMinDrawSamples];
//    Float64 audioDeltaTime;
    double audioTime;
};
extern struct AudioDataStruct myAudioData[DATA_BUFF_STRUCT_SIZE];
extern int audioArrayCounter;
extern UInt64 initialTimeInNanos;

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
