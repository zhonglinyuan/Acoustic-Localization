//
//  YZZDataQueuer.cpp
//  MicConvolution01
//
//  Created by Kai Zou on 2012-10-23.
//  Copyright (c) 2012 Kai Zou. All rights reserved.
//
/*
#include "YZZDataQueuer.h"

//YZZDataQueuer::YZZDataQueuer() {
//    this->maxAccDataLen=ACC_DATA_LEN;
//    this->maxGyrDataLen=GYR_DATA_LEN;
//    this->maxMicDataLen=MIC_DATA_LEN;
//}

//LOCATION 01//////////////////////////////
void YZZDataQueuer::enqueueLoc01AccData(float accData){
    if (this->currLoc01AccDataLen >= ACC_DATA_LEN) {
        this->loc01AccData.erase(this->loc01AccData.begin());
    } else {
        this->currLoc01AccDataLen++;
    }
    this->loc01AccData.push_back(accData);
}

void YZZDataQueuer::enqueueLoc01GyrData(float gyrData){
    if (this->currLoc01GyrDataLen >= GYR_DATA_LEN) {
        this->loc01GyrData.erase(this->loc01GyrData.begin());
    } else {
        this->currLoc01GyrDataLen++;
    }
    this->loc01GyrData.push_back(gyrData);
}

void YZZDataQueuer::enqueueLoc01MicData(float micData) {
    if (this->currLoc01MicDataLen >= MIC_DATA_LEN) {
        this->loc01MicData.erase(this->loc01MicData.begin());
    } else {
        this->currLoc01MicDataLen++;
    }
    this->loc01MicData.push_back(micData);
}

//LOCATION 02////////////////////////////
void YZZDataQueuer::enqueueLoc02AccData(float accData){
    if (this->currLoc02AccDataLen >= ACC_DATA_LEN) {
        this->loc02AccData.erase(this->loc02AccData.begin());
    } else {
        this->currLoc02AccDataLen++;
    }
    this->loc02AccData.push_back(accData);
}

void YZZDataQueuer::enqueueLoc02GyrData(float gyrData){
    if (this->currLoc02GyrDataLen >= GYR_DATA_LEN) {
        this->loc02GyrData.erase(this->loc02GyrData.begin());
    } else {
        this->currLoc02GyrDataLen++;
    }
    this->loc02GyrData.push_back(gyrData);
}

void YZZDataQueuer::enqueueLoc02MicData(float micData) {
    if (this->currLoc02MicDataLen >= MIC_DATA_LEN) {
        this->loc02MicData.erase(this->loc02MicData.begin());
    } else {
        this->currLoc02MicDataLen++;
    }
    this->loc02MicData.push_back(micData);
}

//LOCATION INPUT////////////////////////////
void YZZDataQueuer::enqueueInputAccData(float accData){
    if (this->inputAccDataLen >= ACC_DATA_LEN) {
        this->inputAccData.erase(this->inputAccData.begin());
    } else {
        this->inputAccDataLen++;
    }
    this->inputAccData.push_back(accData);
}

void YZZDataQueuer::enqueueInputGyrData(float gyrData){
    if (this->inputGyrDataLen >= GYR_DATA_LEN) {
        this->inputGyrData.erase(this->inputGyrData.begin());
    } else {
        this->inputGyrDataLen++;
    }
    this->inputGyrData.push_back(gyrData);
}

void YZZDataQueuer::enqueueInputMicData(float micData) {
    if (this->inputMicDataLen >= MIC_DATA_LEN) {
        this->inputMicData.erase(this->inputMicData.begin());
    } else {
        this->inputMicDataLen++;
    }
    this->inputMicData.push_back(micData);
}
*/