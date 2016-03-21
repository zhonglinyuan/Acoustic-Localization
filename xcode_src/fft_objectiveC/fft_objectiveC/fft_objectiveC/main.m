//
//  main.m
//  fft_objectiveC
//
//  Created by Kai Zou on 2013-03-01.
//  Copyright (c) 2013 YZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <stdio.h>
#include <stdlib.h>
#include <Accelerate/Accelerate.h>
#include <math.h>

//    @autoreleasepool {
//    }

int main(void)
{
    int i;
    const int log2n = 4;
    const int n = 1 << log2n;
    const int nOver2 = n / 2;
    
    FFTSetupD fftSetup = vDSP_create_fftsetupD (log2n, kFFTRadix2); //need to call destroy
    
    DSPDoubleSplitComplex fft_data;
    fft_data.realp = malloc(nOver2 * sizeof(double)); //need to free
    fft_data.imagp = malloc(nOver2 * sizeof(double)); //need to free
    
    //-----
//    int inputLen = 15;
    double *input = malloc(n * sizeof(double)); //need to free
    for (i = 0; i < n; ++i)
        input[i] = (double)(i+1);
/*    input[0] = 1;
    input[1] = 2;
    input[2] = 3;
    input[3] = 4;
    input[4] = 5;
    input[5] = 6;
    input[6] = 7;
    input[7] = 8;
    input[8] = 0;
    input[9] = 0;
    input[10] = 0;
    input[11] = 0;
    input[12] = 0;
    input[13] = 0;
    input[14] = 0;*/
    
 
    printf("Input\n");
    for (i = 0; i < n; ++i)
        printf("%d: %8g\n", i, input[i]);
    
    
    //-----
    printf("FFT Input\n");
    vDSP_ctozD((DSPDoubleComplex *)input, 2, &fft_data, 1, nOver2);
    for (i = 0; i < nOver2; ++i)
        printf("%d: %8g%8g\n", i, fft_data.realp[i], fft_data.imagp[i]);
    
    
    //-----
    printf("FFT output\n");
    vDSP_fft_zripD (fftSetup, &fft_data, 1, log2n, kFFTDirection_Forward);
    for (i = 0; i < nOver2; ++i)
        printf("%d: %8g%8g\n", i, fft_data.realp[i], fft_data.imagp[i]);

    
    //-----inverse FFT
    printf("IFFT output\n");
    double scale = (double)pow(2, log2n+1);
    vDSP_fft_zripD (fftSetup, &fft_data, 1, log2n, kFFTDirection_Inverse);
    for (i = 0; i < nOver2; ++i) {
        printf("%d: %8g%8g %f\n", i, fft_data.realp[i]/scale, fft_data.imagp[i]/scale, scale);
        fft_data.realp[i] = fft_data.realp[i]/scale;
        fft_data.imagp[i] = fft_data.imagp[i]/scale;
    }
    
    //-----
    printf("FFT output\n");
    vDSP_fft_zripD (fftSetup, &fft_data, 1, log2n, kFFTDirection_Forward);
    for (i = 0; i < nOver2; ++i)
        printf("%d: %8g%8g\n", i, fft_data.realp[i], fft_data.imagp[i]);

    
    /*
    //-----
    printf("Scaled FFT output\n");
    for (i = 0; i < nOver2; ++i) {
        fft_data.realp[i] *= 0.5;
        fft_data.imagp[i] *= 0.5; }
    for (i = 0; i < nOver2; ++i)
        printf("%d: %8g%8g\n", i, fft_data.realp[i], fft_data.imagp[i]);
    
    
    //-----
    printf("Unpacked output (reversed +ve imaginary side only)\n");
    printf("%d: %8g%8g\n", 0, fft_data.realp[0], 0.0); // DC
    for (i = 1; i < nOver2; ++i)
        printf("%d: %8g%8g\n", i, fft_data.realp[i], fft_data.imagp[i]);
    printf("%d: %8g%8g\n", nOver2, fft_data.imagp[0], 0.0); // Nyquist
     */
    
    return 0;

}


//-(float)crosscorrelateTapRecording1:(double *)A andTapRecording2:(double *)B andLen:(int)len {
float* xcorr(float *A, float *B, int len, uint32_t *resultLen) {
    
    float *micRef;
    float *micInput;
    float          *signal, *filter, *result;
    uint32_t        lenSignal, filterLength, resultLength;
    
    filterLength = len;
    resultLength = filterLength*2-1;
    *resultLen = resultLength;
    lenSignal = ((filterLength + 3) & 0xFFFFFFFC) + resultLength;
    
    //printf("\nConvolution(resultLength = %d,filterLength=%d,lenSignal=%d)\n\n", resultLength, filterLength, lenSignal);
//    micInput = L1->SensorFifo[0]->getDataLinearNormalized();//this is alloc mem, need to free later
//    micRef = L2->SensorFifo[0]->getDataLinearNormalized(); //this is alloc mem, need to free later
    micInput = A;
    micRef = B;
    
    /* Allocate memory for the input operands and check its availability. */
    signal = (float *) malloc(lenSignal * sizeof(float));
    filter = (float *) malloc(filterLength * sizeof(float));
    result = (float *) malloc(resultLength * sizeof(float));
    memset(signal, 0, lenSignal*sizeof(float));
    memset(filter, 0, filterLength*sizeof(float));
    memset(result, 0, resultLength*sizeof(float));
    
    for (int i = 0; i < filterLength; i++)
        filter[i] = micInput[i];
    free(micInput);
    for (int i = 0; i < resultLength; i++)
        if (i >=resultLength-filterLength)
            signal[i] = micRef[i-filterLength+1];//filter[i - filterLength+1];
    free(micRef);
                
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
    return result;
}

