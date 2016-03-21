//
//  DataList.h
//  MicConvolution01
//
//  Created by Kai Zou on 2012-10-23.
//  Copyright (c) 2012 Kai Zou. All rights reserved.
//

#ifndef __MicConvolution01__DataList__
#define __MicConvolution01__DataList__

#include <iostream>
#include <queue>

class DataList {
private:
    std::queue<double> loc01AccData;
    std::queue<double> loc01GyrData;
    std::queue<double> loc01MicData;
    
    std::queue<double> loc02AccData;
    std::queue<double> loc02GyrData;
    std::queue<double> loc02MicData;
    
    std::queue<double> inputAccData;
    std::queue<double> inputGyrData;
    std::queue<double> inputMicData;
    
public:
};

#endif /* defined(__MicConvolution01__DataList__) */
