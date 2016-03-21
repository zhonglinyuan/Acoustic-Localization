//
//  YZZSignalProcessor.h
//  EngineTester
//
//  Created by Kai Zou on 2013-01-26.
//  Copyright (c) 2013 YZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "YZZTapRecording.h"
#import <Accelerate/Accelerate.h>

//void fft_print_output(DSPSplitComplex *fft_data, int fft_data_len);
//void reverse_array(float *array, int arrayLen);
//void scale_fft_result(DSPSplitComplex *fft_data, int fft_data_len);
//void scale_ifft_result(DSPSplitComplex *fft_data, int fft_data_len);
//void complex_array_multiply(DSPSplitComplex *A, int lenA, DSPSplitComplex *B, int lenB, DSPSplitComplex *output);
//void fft_wrap(float *input, int lenInput, DSPSplitComplex *output, int fftOutputLen);
//void ifft_wrap(DSPSplitComplex *ifft_in, int inLen, DSPSplitComplex *ifft_out);

//DSPSplitComplex* malloc_DSPSplitComplex(int length);
//void free_DSPSplitComplex(DSPSplitComplex *myComplexArray);

@interface YZZSignalProcessor : NSObject

-(id)initWithSetupLength:(int)lenInput;

//xcorr function
//-(float)crosscorrelateTapRecording1:(YZZTapRecording *)L1 andTapRecording2:(YZZTapRecording *)L2;
-(float)crosscorrelateMicInput:(float *)micInput WithMicRef:(float *)micRef ofLength:(int)length;

//fft functions and helpers
-(DSPSplitComplex *) malloc_DSPSplitComplexWithLength:(int)length;
-(void) free_DSPSplitComplex:(DSPSplitComplex *)myComplexArray;
-(void) reverse_array:(float *)array ofLen:(int)arrayLen;
-(void) fft_print_output:(DSPSplitComplex *)fft_data ofLen:(int)fft_data_len;
-(void) scale_fft_result:(DSPSplitComplex *)fft_data ofLen:(int)fft_data_len;
-(void) scale_ifft_result:(DSPSplitComplex *)fft_data ofLen:(int)fft_data_len;
-(void) complex_array_multiply_A:(DSPSplitComplex *)A ofLen:(int)lenA withB:(DSPSplitComplex *)B ofLen:(int)lenB output:(DSPSplitComplex*)output;
-(void) ifft_wrap:(DSPSplitComplex*)ifft_in ofInputLen:(int)inLen output:(DSPSplitComplex*)ifft_out;
-(void) fft_wrap:(float*)input ofInputLen:(int)lenInput toGetOutput:(DSPSplitComplex*)output ofOutputLen:(int)fftOutputLen;

//-(float)fftxcorr_TapRecording:(YZZTapRecording *)tapRecording withTapTemplate:(YZZTapRecording *)tapTemplate;
-(float)fftxcorr_TapRecording:(DSPSplitComplex *)tapRecording_micFreqDomForward withTapTemplate:(DSPSplitComplex *)tapTemplate_micFreqDomReversed ofLen:(int)complex_array_len;

@end

