//
//  Location.cpp
//  SimpleTap
//
//  Created by ZhongLin Yuan on 2012-11-17.
//  Copyright (c) 2012 ZhongLin Yuan. All rights reserved.
//

#include "Location.h"

Location::Location()
{
    this->AccZFifo = new FixedFifo(DATA_BUFF_STRUCT_SIZE, DATA_BUFF_STRUCT_SIZE_TRIGGER);
    this->MicFifo = new FixedFifo(MIC_DATA_BUFF_SIZE,MIC_DATA_BUFF_SIZE_TRIGGER);
    this->GyroXFifo = new FixedFifo(DATA_BUFF_STRUCT_SIZE, DATA_BUFF_STRUCT_SIZE_TRIGGER);
    this->GyroYFifo = new FixedFifo(DATA_BUFF_STRUCT_SIZE, DATA_BUFF_STRUCT_SIZE_TRIGGER);
}

Location::~Location()
{
    free(AccZFifo);
    free(MicFifo);
    free(GyroXFifo);
    free(GyroYFifo);
}

void Location::ClearAllBuffers() {
    this->AccZFifo->clearAll();
    this->MicFifo->clearAll();
    this->GyroXFifo->clearAll();
    this->GyroYFifo->clearAll();
}