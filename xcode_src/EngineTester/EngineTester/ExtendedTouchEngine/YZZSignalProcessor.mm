//
//  YZZSignalProcessor.m
//  EngineTester
//
//  Created by Kai Zou on 2013-01-26.
//  Copyright (c) 2013 YZZ. All rights reserved.
//

#import "YZZSignalProcessor.h"

@interface YZZSignalProcessor ()
    
@property (nonatomic) FFTSetup fftSetup;

@end

@implementation YZZSignalProcessor {

}

@synthesize fftSetup = _fftSetup;


-(id)initWithSetupLength:(int)lenInput {
    self = [super init];
    
    const int log2n = (int)(log10(lenInput)/log10(2));//4;
    self.fftSetup = vDSP_create_fftsetup (log2n, kFFTRadix2); //need to call destroy
    
    
    return self;
}

-(void)dealloc {
    if (self.fftSetup !=NULL) {
        vDSP_destroy_fftsetup(self.fftSetup);
    }
}

#pragma mark TIME DOMAIN XCORR

//-(float)crosscorrelateTapRecording1:(YZZTapRecording *)L1 andTapRecording2:(YZZTapRecording *)L2 {
-(float)crosscorrelateMicInput:(float *)micInput WithMicRef:(float *)micRef ofLength:(int)length {
    
//    float *micRef;
//    float *micInput;
    float          *signal, *filter, *result;
    uint32_t        lenSignal, filterLength, resultLength;
    
    filterLength = length;
    resultLength = filterLength*2-1;
    lenSignal = ((filterLength + 3) & 0xFFFFFFFC) + resultLength;
    
    //printf("\nConvolution(resultLength = %d,filterLength=%d,lenSignal=%d)\n\n", resultLength, filterLength, lenSignal);
//    micInput = L1->SensorFifo[0]->getDataLinearNormalized();//this is alloc mem, need to free later
//    micRef = L2->SensorFifo[0]->getDataLinearNormalized(); //this is alloc mem, need to free later
    
    /* Allocate memory for the input operands and check its availability. */
    signal = (float *) malloc(lenSignal * sizeof(float));
    filter = (float *) malloc(filterLength * sizeof(float));
    result = (float *) malloc(resultLength * sizeof(float));
    memset(signal, 0, lenSignal*sizeof(float));
    memset(filter, 0, filterLength*sizeof(float));
    memset(result, 0, resultLength*sizeof(float));
    
    for (int i = 0; i < filterLength; i++)
        filter[i] = micInput[i];
//    free(micInput);
    for (int i = 0; i < resultLength; i++)
        if (i >=resultLength-filterLength)
            signal[i] = micRef[i-filterLength+1];//filter[i - filterLength+1];
//    free(micRef);
    
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


#pragma mark FFT XCORR

//-(float)fftxcorr_TapRecording:(YZZTapRecording *)tapRecording withTapTemplate:(YZZTapRecording *)tapTemplate {
-(float)fftxcorr_TapRecording:(DSPSplitComplex *)tapRecording_micFreqDomForward withTapTemplate:(DSPSplitComplex *)tapTemplate_micFreqDomReversed ofLen:(int)complex_array_len {

//    int complex_array_len = tapRecording->micFreqDomForwardLen;
    
    //get complex multiplication of A and B
    DSPSplitComplex *complex_multiply = [self malloc_DSPSplitComplexWithLength:complex_array_len];
    [self complex_array_multiply_A:tapRecording_micFreqDomForward ofLen:complex_array_len withB:tapTemplate_micFreqDomReversed ofLen:complex_array_len output:complex_multiply];
    
    //get time domain result
    DSPSplitComplex *ifft_output = [self malloc_DSPSplitComplexWithLength:complex_array_len];
    [self ifft_wrap:complex_multiply ofInputLen:complex_array_len output:ifft_output];
    
    //find max xcorr value (this is a time domain array stored in freq dom)
    float maxCorr = ifft_output->realp[0];
    if (maxCorr<ifft_output->imagp[0]) {
        maxCorr = ifft_output->imagp[0];
    }
    for (int i=1; i<complex_array_len; i++) {
        if (maxCorr<ifft_output->realp[i]) {
            maxCorr=ifft_output->realp[i];
        }
        if (maxCorr<ifft_output->imagp[i]) {
            maxCorr=ifft_output->imagp[i];
        }
    }
    
    [self free_DSPSplitComplex:complex_multiply];
    [self free_DSPSplitComplex:ifft_output];
    
//    NSLog(@"complex_array_len:%d",complex_array_len);
//    NSLog(@"maccorr:%f", maxCorr);
    
    return maxCorr;
}

#pragma mark FFT XCORR helper functions

//DSPSplitComplex* malloc_DSPSplitComplex(int length) {
-(DSPSplitComplex *) malloc_DSPSplitComplexWithLength:(int) length {
    DSPSplitComplex *myComplexArray = (DSPSplitComplex *) malloc(sizeof(DSPSplitComplex));
    myComplexArray->realp = (float *) malloc(length * sizeof(float));
    myComplexArray->imagp = (float *) malloc(length * sizeof(float));
    return myComplexArray;
}

//void free_DSPSplitComplex(DSPSplitComplex *myComplexArray) {
-(void) free_DSPSplitComplex:(DSPSplitComplex *)myComplexArray {
    free(myComplexArray->realp);
    free(myComplexArray->imagp);
    free(myComplexArray);
    myComplexArray=NULL;
}

//void reverse_array(float *array, int arrayLen) {
-(void) reverse_array:(float *)array ofLen:(int)arrayLen {
    float temp = 0;
    for (int i=0; i<arrayLen/2; i++) {
        temp = array[i];
        array[i] = array[(arrayLen-1)-i];
        array[(arrayLen-1)-i] = temp;
    }
}

//void fft_print_output(DSPSplitComplex *fft_data, int fft_data_len) {
-(void) fft_print_output:(DSPSplitComplex *)fft_data ofLen:(int)fft_data_len {
    printf("FFT output\n");
    int nOver2 = fft_data_len;
    for (int i = 0; i < nOver2; ++i)
        printf("%d: %8g %8g\n", i, fft_data->realp[i], fft_data->imagp[i]);
}

//void scale_fft_result(DSPSplitComplex *fft_data, int fft_data_len) {
-(void) scale_fft_result:(DSPSplitComplex *)fft_data ofLen:(int)fft_data_len {
    for (int i = 0; i<fft_data_len; i++) {
        fft_data->realp[i] = fft_data->realp[i]*0.5;
        fft_data->imagp[i] = fft_data->imagp[i]*0.5;
    }
}

//void scale_ifft_result(DSPSplitComplex *fft_data, int fft_data_len)
-(void) scale_ifft_result:(DSPSplitComplex *)fft_data ofLen:(int)fft_data_len {
    const int log2n = (int)(log10(fft_data_len*2)/log10(2));
    int scale = (double)pow(2, log2n);
    //    int scale_by_len = fft_data_len*2;
    for (int i = 0; i<fft_data_len; i++) {
        fft_data->realp[i] = fft_data->realp[i]/scale;
        fft_data->imagp[i] = fft_data->imagp[i]/scale;
    }
}

//void complex_array_multiply(DSPSplitComplex *A, int lenA, DSPSplitComplex *B, int lenB, DSPSplitComplex *output) {
-(void) complex_array_multiply_A:(DSPSplitComplex *)A ofLen:(int)lenA withB:(DSPSplitComplex *)B ofLen:(int)lenB output:(DSPSplitComplex*)output {

    //for each complex number in array: if A=a+bi and B=c+di then output=(ac-bd)+(ad+bc)i
    for (int i=0; i<lenA; i++) {
        if (i==0) {
            output->realp[0] = A->realp[0] * B->realp[0];
            output->imagp[0] = A->imagp[0] * B->imagp[0];
        } else {
            output->realp[i]=((A->realp[i] * B->realp[i]) - (A->imagp[i] * B->imagp[i]));
            output->imagp[i]=((A->realp[i] * B->imagp[i]) + (A->imagp[i] * B->realp[i]));
        }
    }
    
}

//void ifft_wrap(DSPSplitComplex *ifft_in, int inLen, DSPSplitComplex *ifft_out) {
-(void) ifft_wrap:(DSPSplitComplex*)ifft_in ofInputLen:(int)inLen output:(DSPSplitComplex*)ifft_out {
    const int log2n = (int)(log10(inLen*2)/log10(2));
        
    for (int i=0; i<inLen; i++) {
        ifft_out->realp[i] = ifft_in->realp[i];
        ifft_out->imagp[i] = ifft_in->imagp[i];
    }
    
    
//    FFTSetup fftSetup = vDSP_create_fftsetup (log2n, kFFTRadix2); //need to call destroy
    
    vDSP_fft_zrip (self.fftSetup, ifft_out, 1, log2n, kFFTDirection_Inverse);
    
    [self scale_ifft_result:ifft_out ofLen:inLen];
//    scale_ifft_result(ifft_out, inLen);
    
//    vDSP_destroy_fftsetup(fftSetup);
    
}

//void fft_wrap(float *input, int lenInput, DSPSplitComplex *output, int fftOutputLen)
-(void) fft_wrap:(float*)input ofInputLen:(int)lenInput toGetOutput:(DSPSplitComplex*)output ofOutputLen:(int)fftOutputLen {
    //    int i;
    const int log2n = (int)(log10(lenInput)/log10(2));//4;
//    printf("ASDF log2n:%d\n", log2n);
    //    const int n = 1 << log2n;
    //    const int lenInputOver2 = lenInput / 2;
    
    //first argument must equal exceed the passed in length
//    FFTSetup fftSetup = vDSP_create_fftsetup (log2n, kFFTRadix2); //need to call destroy
    
    vDSP_ctoz((DSPComplex *)input, 2, output, 1, fftOutputLen);
    
    vDSP_fft_zrip (self.fftSetup, output, 1, log2n, kFFTDirection_Forward);
    
    [self scale_fft_result:output ofLen:fftOutputLen];
//    scale_fft_result(output, fftOutputLen);
    
//    vDSP_destroy_fftsetup(fftSetup);
    
}



@end