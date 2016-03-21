//
//  YZZTemplateSelector.h
//  EngineTester
//
//  Created by ZhongLin Yuan on 2013-02-21.
//  Copyright (c) 2013 YZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZZTapRecording.h"
#import "YZZLabel.h"
#import "YZZSignalProcessor.h"
#define XCORR_THRESHOLD 0.8


@interface YZZTemplateSelector : NSObject

-(NSMutableArray *)FindBestThreeTemplates:(YZZLabel *) myList;
@end
