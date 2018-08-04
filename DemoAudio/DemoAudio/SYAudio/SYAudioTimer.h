//
//  SYAudioTimer.h
//  zhangshaoyu
//
//  Created by zhangshaoyu on 16/11/21.
//  Copyright © 2016年 zhangshaoyu. All rights reserved.
//  音频计时器

#import <Foundation/Foundation.h>

@interface SYAudioTimer : NSObject

NSTimer *SYAudioTimerInitialize(NSTimeInterval timeElapsed, id userInfo, BOOL isRepeat, id target, SEL action);

void SYAudioTimerStart(NSTimer *timer);

void SYAudioTimerStop(NSTimer *timer);

void SYAudioTimerKill(NSTimer *timer);

@end
