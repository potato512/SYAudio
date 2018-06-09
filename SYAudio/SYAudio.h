//
//  SYAudio.h
//  zhangshaoyu
//
//  Created by zhangshaoyu on 13/11/7.
//  Copyright (c) 2015年 zhangshaoyu. All rights reserved.
//  音频录制与播放

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 导入录音头文件（注意添加framework：AVFoundation.framework、AudioToolbox.framework）
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#import "SYAudioFile.h"
#import "SYAudioTimer.h"

@interface SYAudio : NSObject

/// 音频处理单例
+ (SYAudio *)shareAudio;

#pragma mark - 音频处理-录音

/// 开始录音
- (void)audioRecorderStartWithFilePath:(NSString *)filePath;

/// 停止录音
- (void)audioRecorderStop;

/// 录音时长
- (NSTimeInterval)durationAudioRecorderWithFilePath:(NSString *)filePath;

#pragma mark - 音频处理-播放/停止

/// 音频开始播放或停止
- (void)audioPlayWithFilePath:(NSString *)filePath;

/// 音频播放停止
- (void)audioStop;

@end
