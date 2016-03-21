//
//  main.m
//  fft_xcorr_objC
//
//  Created by Kai Zou on 2013-03-03.
//  Copyright (c) 2013 YZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <stdio.h>
#include <stdlib.h>
#include <Accelerate/Accelerate.h>
#include <math.h>

//    @autoreleasepool {
//    }

void fft_print_output(DSPSplitComplex *fft_data, int fft_data_len);
void fft_print_scaled_output(DSPSplitComplex *fft_data, int fft_data_len);
void reverse_array(float *array, int arrayLen);
void scale_fft_result(DSPSplitComplex *fft_data, int fft_data_len);
void scale_ifft_result(DSPSplitComplex *fft_data, int fft_data_len);
void complex_array_multiply(DSPSplitComplex *A, int lenA, DSPSplitComplex *B, int lenB, DSPSplitComplex *output);
void fft_wrap(float *input, int lenInput, DSPSplitComplex *output, int fftOutputLen);
void ifft_wrap(DSPSplitComplex *ifft_in, int inLen, DSPSplitComplex *ifft_out);
float* xcorr(float *A, float *B, int len, uint32_t *resultLen);

DSPSplitComplex * malloc_DSPSplitComplex(int length);
void free_DSPSplitComplex(DSPSplitComplex *myComplexArray);

int main(void)
{
    //create mic input A and B
    const int inputLen = 10;
    float *A = malloc(inputLen * sizeof(float)); //need to free
    for (int i=0; i<inputLen; i++) {
        A[i] = (float)(i+1);
    }
    float *B = malloc(inputLen * sizeof(float));
    for (int i=0; i<inputLen; i++) {
        B[i] = (float)(i+1);
    }
    
    
    //resize A and B with zeros to length that's power of 2 and then reverse B
    const int resizedLen = 16;
    float *resizedA = malloc(resizedLen * sizeof(float));
    for (int i=0; i<resizedLen; i++) {
        if (i<inputLen) {
            resizedA[i] = A[i];
        } else { resizedA[i] = 0; }
    }
    float *resizedB = malloc(resizedLen * sizeof(float));
    for (int i=0; i<resizedLen; i++) {
        if (i<inputLen) {
            resizedB[i] = B[i];
        } else { resizedB[i] = 0; }
    }
    reverse_array(resizedB, resizedLen);
    
    //zero pad A and B as fft input
    int fftInputLen = resizedLen*2; //=10
    float *fft_input_A = malloc(fftInputLen * sizeof(float));
    for (int i=0; i<fftInputLen; i++) {
        if (i < resizedLen) {
            fft_input_A[i] = resizedA[i];
        } else {
            fft_input_A[i] = 0;
        }
    }
    float *fft_input_B = malloc(fftInputLen * sizeof(float));
    for (int i=0; i<fftInputLen; i++) {
        if (i < resizedLen) {
            fft_input_B[i] = resizedB[i];
        } else {
            fft_input_B[i] = 0;
        }
    }
//    for (int i=0; i<fftInputLen; i++) {
//        printf("fft_input_A:%f fft_input_B:%f\n",fft_input_A[i], fft_input_B[i]);
//    }
    
    
    //create fft output structs A and B
    const int fftInputLenOver2 = fftInputLen / 2; //length of complex array
    printf("FIND ME:%d\n", (int)(log10(fftInputLenOver2)/log10(2)));
    DSPSplitComplex *fft_output_A = malloc_DSPSplitComplex(fftInputLenOver2);
    DSPSplitComplex *fft_output_B = malloc_DSPSplitComplex(fftInputLenOver2);
    //do fft on A and B
    fft_wrap(fft_input_A, fftInputLen, fft_output_A, fftInputLenOver2);
    fft_wrap(fft_input_B, fftInputLen, fft_output_B, fftInputLenOver2);
//    fft_print_output(fft_output_A, fftInputLenOver2);
//    fft_print_output(fft_output_B, fftInputLenOver2);
    
    
    //complex multiply fftA and fftB
    DSPSplitComplex *A_complex_mult_B = malloc_DSPSplitComplex(fftInputLenOver2);
    complex_array_multiply(fft_output_A, fftInputLenOver2, fft_output_B, fftInputLenOver2, A_complex_mult_B);
//    fft_print_output(A_complex_mult_B, fftInputLenOver2);
    
    //inverse fft to get xcorr
    DSPSplitComplex *fft_xcorr_result = malloc_DSPSplitComplex(fftInputLenOver2);
    ifft_wrap(A_complex_mult_B, fftInputLenOver2, fft_xcorr_result);
    fft_print_output(fft_xcorr_result, fftInputLenOver2);


    
    //COMPARISON with real xcorr
    //reverse_array(B, inputLen);
    uint32_t resultLen;
    float *C;
    C = xcorr(A, B, inputLen, &resultLen);
    for (int i=0; i<resultLen; i++) {
        printf("C:%f\n", C[i]);
    }
    
    free_DSPSplitComplex(fft_xcorr_result);
    free_DSPSplitComplex(A_complex_mult_B);
    free_DSPSplitComplex(fft_output_B);
    free_DSPSplitComplex(fft_output_A);
    
    //EVERYTHING ABOVE THIS COMMENT IS CORRECT
    
    
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

DSPSplitComplex * malloc_DSPSplitComplex(int length) {
    DSPSplitComplex *myComplexArray = malloc(sizeof(DSPSplitComplex)); //need to free
    myComplexArray->realp = malloc(length * sizeof(float)); //need to free
    myComplexArray->imagp = malloc(length * sizeof(float)); //need to free
    return myComplexArray;
}

void free_DSPSplitComplex(DSPSplitComplex *myComplexArray) {
    free(myComplexArray->realp);
    free(myComplexArray->imagp);
    free(myComplexArray);
    myComplexArray=NULL;
}

void reverse_array(float *array, int arrayLen) {
    float temp = 0;
    for (int i=0; i<arrayLen/2; i++) {
        temp = array[i];
        array[i] = array[(arrayLen-1)-i];
        array[(arrayLen-1)-i] = temp;
    }
}

void fft_print_output(DSPSplitComplex *fft_data, int fft_data_len) {
    printf("FFT output\n");
    int nOver2 = fft_data_len;
    for (int i = 0; i < nOver2; ++i)
        printf("%d: %8g %8g\n", i, fft_data->realp[i], fft_data->imagp[i]);
}

void fft_print_scaled_output(DSPSplitComplex *fft_data, int fft_data_len) {
    printf("FFT scaled output\n");
    int nOver2 = fft_data_len;
    for (int i = 0; i < nOver2; ++i)
        printf("%d: %8g %8g\n", i, fft_data->realp[i]*0.5, fft_data->imagp[i]*0.5);
}

void scale_fft_result(DSPSplitComplex *fft_data, int fft_data_len) {
    for (int i = 0; i<fft_data_len; i++) {
        fft_data->realp[i] = fft_data->realp[i]*0.5;
        fft_data->imagp[i] = fft_data->imagp[i]*0.5;
    }
}

void scale_ifft_result(DSPSplitComplex *fft_data, int fft_data_len) {
    const int log2n = (int)(log10(fft_data_len*2)/log10(2));
    int scale = (double)pow(2, log2n);
//    int scale_by_len = fft_data_len*2;
    for (int i = 0; i<fft_data_len; i++) {
        fft_data->realp[i] = fft_data->realp[i]/scale;
        fft_data->imagp[i] = fft_data->imagp[i]/scale;
    }
}

void complex_array_multiply(DSPSplitComplex *A, int lenA, DSPSplitComplex *B, int lenB, DSPSplitComplex *output) {
    
    for (int i=0; i<lenA; i++) {
        if (i==0) {
            output->realp[0] = A->realp[0] * B->realp[0];
            output->imagp[0] = A->imagp[0] * B->imagp[0];
        } else {
//            (ac-bd) + (ad+bc)i
            output->realp[i]=((A->realp[i] * B->realp[i]) - (A->imagp[i] * B->imagp[i]));
            output->imagp[i]=((A->realp[i] * B->imagp[i]) + (A->imagp[i] * B->realp[i]));
        }
    }
    
}

void ifft_wrap(DSPSplitComplex *ifft_in, int inLen, DSPSplitComplex *ifft_out) {
    const int log2n = (int)(log10(inLen*2)/log10(2));
    
    printf("FIND ME HERE, log2n:%d inLen:%d\n", log2n, inLen);
    
    for (int i=0; i<inLen; i++) {
        ifft_out->realp[i] = ifft_in->realp[i];
        ifft_out->imagp[i] = ifft_in->imagp[i];
    }
    
    
    FFTSetup fftSetup = vDSP_create_fftsetup (log2n, kFFTRadix2); //need to call destroy
    
    vDSP_fft_zrip (fftSetup, ifft_out, 1, log2n, kFFTDirection_Inverse);
    
    scale_ifft_result(ifft_out, inLen);
    
    vDSP_destroy_fftsetup(fftSetup);
    
}

void fft_wrap(float *input, int lenInput, DSPSplitComplex *output, int fftOutputLen) {
    //    int i;
    const int log2n = (int)(log10(lenInput)/log10(2));//4;
    printf("FUCK log2n:%d\n", log2n);
//    const int n = 1 << log2n;
//    const int lenInputOver2 = lenInput / 2;
    
    //first argument must equal exceed the passed in length
    FFTSetup fftSetup = vDSP_create_fftsetup (log2n, kFFTRadix2); //need to call destroy

    vDSP_ctoz((DSPComplex *)input, 2, output, 1, fftOutputLen);
    
    vDSP_fft_zrip (fftSetup, output, 1, log2n, kFFTDirection_Forward);
    
    scale_fft_result(output, fftOutputLen);
    
    vDSP_destroy_fftsetup(fftSetup);

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
    //free(result);
    return result;
}

