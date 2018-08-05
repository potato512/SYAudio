//
//  SYAudio.m
//  zhangshaoyu
//
//  Created by zhangshaoyu on 13/11/7.
//  Copyright (c) 2015年 zhangshaoyu. All rights reserved.
//

#import "SYAudio.h"

@interface SYAudio ()

@end

@implementation SYAudio

#pragma mark - 初始化

// 录音
+ (SYAudio *)shareAudio
{
    static SYAudio *staticAudio;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        staticAudio = [[self alloc] init];
    });
    
    return staticAudio;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

// 内存释放
- (void)dealloc
{
    NSLog(@"%@ 被释放了", self);
}

#pragma mark - setter

- (SYAudioRecord *)audioRecorder
{
    if (_audioRecorder == nil) {
        _audioRecorder = [[SYAudioRecord alloc] init];
    }
    return _audioRecorder;
}

- (SYAudioPlay *)audioPlayer
{
    if (_audioPlayer == nil) {
        _audioPlayer = [[SYAudioPlay alloc] init];
    }
    return _audioPlayer;
}

@end
