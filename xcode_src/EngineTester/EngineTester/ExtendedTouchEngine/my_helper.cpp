//
//  my_helper.cpp
//  AudioData3
//
//  Created by ZhongLin Yuan on 2012-09-13.
//  Copyright (c) 2012 ZhongLin Yuan. All rights reserved.
//

#include "my_helper.h"

// This determines how slowly the oscilloscope lines fade away from the display.
// Larger numbers = slower fade (and more strain on the graphics processing)
SInt8 *drawBuffers[kNumDrawBuffers];
UInt64 *clockTime;

int drawBufferIdx = 0;
int drawBufferLen = kDefaultDrawSamples;
int drawBufferLen_alloced = 0;
int audioBufferHasNewData = 0;

int SetupRemoteIO (AudioUnit& inRemoteIOUnit, AURenderCallbackStruct inRenderProc, CAStreamBasicDescription& outFormat)
{
	try {
		// Open the output unit
		AudioComponentDescription desc;
		desc.componentType = kAudioUnitType_Output;
		desc.componentSubType = kAudioUnitSubType_RemoteIO;
		desc.componentManufacturer = kAudioUnitManufacturer_Apple;
		desc.componentFlags = 0;
		desc.componentFlagsMask = 0;
		
		AudioComponent comp = AudioComponentFindNext(NULL, &desc);
		
		XThrowIfError(AudioComponentInstanceNew(comp, &inRemoteIOUnit), "couldn't open the remote I/O unit");
        
		UInt32 one = 1;
		XThrowIfError(AudioUnitSetProperty(inRemoteIOUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 1, &one, sizeof(one)), "couldn't enable input on the remote I/O unit");
        
		XThrowIfError(AudioUnitSetProperty(inRemoteIOUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &inRenderProc, sizeof(inRenderProc)), "couldn't set remote i/o render callback");
		
        // set our required format - LPCM non-interleaved 32 bit floating point
        outFormat = CAStreamBasicDescription(44100, kAudioFormatLinearPCM, 4, 1, 4, 2, 32, kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked | kAudioFormatFlagIsFloat | kAudioFormatFlagIsNonInterleaved);
		XThrowIfError(AudioUnitSetProperty(inRemoteIOUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &outFormat, sizeof(outFormat)), "couldn't set the remote I/O unit's output client format");
		XThrowIfError(AudioUnitSetProperty(inRemoteIOUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &outFormat, sizeof(outFormat)), "couldn't set the remote I/O unit's input client format");
        
		XThrowIfError(AudioUnitInitialize(inRemoteIOUnit), "couldn't initialize the remote I/O unit");
	}
	catch (CAXException &e) {
		char buf[256];
		fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
		return 1;
	}
	catch (...) {
		fprintf(stderr, "An unknown error occurred\n");
		return 1;
	}
	
	return 0;
}

void SilenceData(AudioBufferList *inData)
{
	for (UInt32 i=0; i < inData->mNumberBuffers; i++)
		memset(inData->mBuffers[i].mData, 0, inData->mBuffers[i].mDataByteSize);
}


const Float32 DCRejectionFilter::kDefaultPoleDist = 0.975f;

DCRejectionFilter::DCRejectionFilter(Float32 poleDist)
{
	Reset();
}

void DCRejectionFilter::Reset()
{
	mY1 = mX1 = 0;
}

void DCRejectionFilter::InplaceFilter(Float32* ioData, UInt32 numFrames)
{
	for (UInt32 i=0; i < numFrames; i++)
	{
        Float32 xCurr = ioData[i];
		ioData[i] = ioData[i] - mX1 + (kDefaultPoleDist * mY1);
        mX1 = xCurr;
        mY1 = ioData[i];
	}
}
