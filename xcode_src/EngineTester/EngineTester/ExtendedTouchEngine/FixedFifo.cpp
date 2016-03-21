
#include "FixedFifo.h"


FixedFifo::FixedFifo(int size, int mid)
{
    if (size > 0 && mid < size)
    {
        this->m_size = size;
        this->m_mid = mid;
        this->m_index = 0;
        this->m_data = new float[this->m_size];
        clearAll();
    }
}

FixedFifo::~FixedFifo()
{
    free(m_data);
}

float FixedFifo::getMax()
{
    float max = m_data[0];
    int i;
    for (i=0; i<(m_index+m_mid)%m_size; i++)
    {
        if (m_data[i] > max)
        {
            max = m_data[i];
        }
    }
    return max;
}

//insert an element with value
float FixedFifo::push(float value)
{
    //printf("%lu\n",this->m_index);
    m_data[(m_index%m_size)] = value;
    m_index++;
    return value;
}

float* FixedFifo::m_toLinearBuffer()
{
    float *linBuffer = new float[m_size];
    int i;
    int index = 0;
    for(i = 0; i<m_size; i++)
    {
        linBuffer[index++] = m_data[(i+m_index)%m_size];
    }
    return linBuffer;
}

float* FixedFifo::m_toLinearBufferNormalized()
{
    float *linBuffer = new float[m_size];
    int i;
    int index = 0;
    for(i = 0; i<m_size; i++)
    {
        linBuffer[index++] = m_data[(i+m_index)%m_size];
    }
    
    //now get rid of mean and varance
    float mean = 0;
    for( i = 0; i < m_size; i++) {
        mean += linBuffer[i];
    }
    mean = mean / m_size;
    
    float std = 0;
    for (i=0 ; i < m_size; i ++) {
        std += pow((linBuffer[i] - mean),2);
    }
    std = pow((std),0.5);
    
    for (i=0;i < m_size; i++) {
        linBuffer[i] = (linBuffer[i]-mean)/std;
    }
    
//    printf("mean:%f std:%f\n",mean,std);
    
    return linBuffer;
}

void FixedFifo::clearAll() {
    //clear all data to 0
    for (int i = 0; i<m_size; i++)
        m_data[i] = 0;
    m_index=0;
}
