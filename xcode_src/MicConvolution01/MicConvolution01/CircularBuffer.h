//
//  CircularBuffer.h
//  MicConvolution01
//
//  Created by Bill on 2012-10-31.
//  Copyright (c) 2012 Kai Zou. All rights reserved.
//

#ifndef __MicConvolution01__CircularBuffer__
#define __MicConvolution01__CircularBuffer__

#include <iostream>

class CircularBuffer
{
public:
    CircularBuffer(int size);
    ~CircularBuffer();
    
    void push(float value);
    float get(int i);
    void print();
    int length() {return elementCount;};    //returns number of elements currently holding
    int maxLength() {return size-1;};       //max number of elements can hold
    float* getDataLinear(){return toLinearBuffer();};   //get the data in linear form
    float* getData() {return data;};        //get the raw data in circular queue
    float getMid() {return get(length()/2);};   //get middle element, based on how many inserted
    bool isEmpty() {return end == start;};      //true if empty
    bool isFull() { return (end+1)%size == start;}; //true if full
    void clearAll();                            //clear all elements to 0
    
private:
    int size;       //size of buffer
    int start;      //index of the start
    int end;        //index of end
    int elementCount; //number of element inside the q
    float *data;    //array stores the actual data

    float* toLinearBuffer();    //converts circular buffer into linear
};

#endif /* defined(__MicConvolution01__CircularBuffer__) */