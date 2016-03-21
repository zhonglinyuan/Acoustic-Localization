//
//  CircularBuffer.cpp
//  MicConvolution01
//
//  Created by Bill on 2012-10-31.
//  Copyright (c) 2012 Kai Zou. All rights reserved.
//

#include "CircularBuffer.h"

CircularBuffer::CircularBuffer(int size)
{
    if (size > 0)
    {
        this->size = size+1;
        this->data = new float[this->size];
        clearAll();
        this->start = 0;
        this->end = 0;
        this->elementCount = 0;
    }
}

CircularBuffer::~CircularBuffer()
{
    free(data);
}

void CircularBuffer::print()
{
   /*
    std::cout << "circular";
    for (int i = 0; i < size; i++)
          std::cout << data [i] << " ";

    std::cout << std::endl << "linear \n";
    */
    float *linBuffer = toLinearBuffer();
    for (int i = 0; i < elementCount; i++)
        std::cout << linBuffer[i] << " ";
    std::cout << std::endl;
}

//insert an element with value
void CircularBuffer::push(float value)
{
    data[end] = value;
    elementCount++;
    end = (end+1)%size; //if end is same as size, end is back to 0
    if(end == start)    //buffer is fulll, overwrite
    {
        start = (start+1)%size;
        elementCount--;
    }
}

/*
 * return the value in the linear array at index i
 * if i > elements currently holding or i > size or que empty
 * return -9999 on these error cases
 */
float CircularBuffer::get(int i)
{
    if (isEmpty() || i > elementCount || i > size)
        return -9999;
    
    int index = 0;
    if ( end > start )
        index = start+i;
    else //start > end
        index = (start+i)<size ? (start+i):i-(size-start);
    
    if (index >= size && index < 0)
        return -9999;
    return data[index];
}

float* CircularBuffer::toLinearBuffer()
{
    float *linBuffer = new float[elementCount];
    int index = start;
    int i=0;
    for(i=0; i<elementCount; i++)
    {
        linBuffer[i] = data[index];
        index = (index+1)%size;
    }
    return linBuffer;
}

void CircularBuffer::clearAll() {
    //clear all data to 0
    for (int i = 0; i<size; i++)
        data[i] = 0;
}