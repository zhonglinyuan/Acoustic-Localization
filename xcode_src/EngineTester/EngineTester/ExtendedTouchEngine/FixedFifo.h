
#ifndef __SimpleTap__FixedFifo__
#define __SimpleTap__FixedFifo__

#include <iostream>
#include <math.h>

class FixedFifo
{
public:
    FixedFifo(int size, int mid);
    ~FixedFifo();
    
    float push(float value);
    int length() {return m_index >= m_size? m_size: m_index ;};    //returns number of elements currently holding
    int maxLength() {return m_size;};       //max number of elements can hold
    float* getDataLinear(){return m_toLinearBuffer();};   //get the data in linear form
    float* getDataLinearNormalized(){return m_toLinearBufferNormalized();};   //get the data in linear form
    float getMid() {return m_data[(m_index+m_mid)%m_size];};   //get middle element, based on how many inserted
    bool isEmpty() {return m_index == 0;};      //true if empty
    bool isFull() {return m_index >= m_size;}; //true if full
    void clearAll();                            //clear all elements to 0
    float getMax();
    
private:
    int m_size;       //size of buffer
    int m_mid;
    unsigned long m_index;
    float *m_data;    //array stores the actual data
    
    float* m_toLinearBuffer();    //converts circular buffer into linear
    float* m_toLinearBufferNormalized();    //converts circular buffer into linear
};


#endif /* defined(__SimpleTap__FixedFifo__) */
