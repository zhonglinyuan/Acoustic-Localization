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
#define kMinDrawSamples 64
#define kMaxDrawSamples 4096

extern int drawBufferIdx;
extern int drawBufferLen;
extern int drawBufferLen_alloced;

extern SInt8 *drawBuffers[];

extern Float64 *deltaTime;
extern UInt64 *clockTime;
extern UInt32 *numberOfFrames;
//extern Float32 *audioBuffers[];
//extern SInt8 *my_AudioData;

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
