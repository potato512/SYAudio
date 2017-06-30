//
//  SYAudioTimer.m
//  zhangshaoyu
//
//  Created by zhangshaoyu on 16/11/21.
//  Copyright © 2016年 zhangshaoyu. All rights reserved.
//

#import "SYAudioTimer.h"

@implementation SYAudioTimer

NSTimer *SYAudioTimerInitialize(NSTimeInterval timeElapsed, id userInfo, BOOL isRepeat, id target, SEL action)
{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:timeElapsed target:target selector:action userInfo:userInfo repeats:isRepeat];
    // 非必要设置，实际已设置为 NSDefaultRunLoopMode 模式
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    [timer setFireDate:[NSDate distantFuture]];
    
    return timer;
}

void SYAudioTimerStart(NSTimer *timer)
{
    [timer setFireDate:[NSDate distantPast]];
}

void SYAudioTimerStop(NSTimer *timer)
{
    [timer setFireDate:[NSDate distantFuture]];
}

void SYAudioTimerKill(NSTimer *timer)
{
    if ([timer isValid])
    {
        [timer invalidate];
    }
    
    timer = nil;
}

@end
