//
//  SYAudio.h
//  zhangshaoyu
//
//  Created by zhangshaoyu on 13/11/7.
//  Copyright (c) 2015年 zhangshaoyu. All rights reserved.
//  音频录制与播放：https://github.com/potato512/SYAudio

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 导入录音头文件（注意添加framework：AVFoundation.framework、AudioToolbox.framework）
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#import "SYAudioFile.h"
#import "SYAudioTimer.h"

#import "SYAudioRecord.h"
#import "SYAudioPlay.h"

#pragma mark - 录音功能

@interface SYAudio : NSObject

/// 音频处理单例
+ (SYAudio *)shareAudio;

/// 录音对象
@property (nonatomic, strong) SYAudioRecord *audioRecorder;

/// 播放对象
@property (nonatomic, strong) SYAudioPlay *audioPlayer;

@end

/*
 使用示例
 1、导入头文件
 #import "SYAudio.h"
 
 2、属性设置
 // 是否显示录音音量状态
[SYAudio shareAudio].audioRecorder.monitorVoice = NO;
 // 限制录音时长
 [SYAudio shareAudio].audioRecorder.totalTime = 10.0;
 // 代理
 [SYAudio shareAudio].audioRecorder.delegate = self;

 3、录音
 （1）音频处理方法-开始录音
 NSString *filePath = xxxxx;
 [[SYAudio shareAudio].audioRecorder recorderStart:filePath complete:^(BOOL isFailed) {
 
 }];
 
 （2）音频处理方法-停止录音
 [[SYAudio shareAudio].audioRecorder recorderStop];
 
 4、播放
 （1）音频处理方法-播放音频（本地音频文件，或网络音频文件均可播放）
 NSString *filePath = xxxxx;
 [[SYAudio shareAudio].audioPlayer playerStart:filePath complete:^(BOOL isFailed) {
 
 }];
 
 （2）音频处理方法-停止音频播放
 [[SYAudio shareAudio].audioPlayer playerPause];

 5、实现代理协议
 (1)录音
 /// 开始录音
 - (void)recordBegined
 { }
 
 /// 停止录音
 - (void)recordFinshed
 { }
 
 /// 正在录音中，录音音量监测
 - (void)recordingUpdateVoice:(double)lowPassResults
 { }
 
 /// 正中录音中，是否录音倒计时、录音剩余时长
 - (void)recordingWithResidualTime:(NSTimeInterval)time timer:(BOOL)isTimer
 { }

 （2）录音文件压缩
 /// 开始压缩录音
 - (void)recordBeginConvert
 { }
 
 /// 结束压缩录音
 - (void)recordFinshConvert:(NSString *)filePath
 { }
 ```
 
 （3）音频文件播放
 /// 开始播放音频
 - (void)audioPlayBegined:(AVPlayerItemStatus)state
 { }
 
 /// 正在播放音频（总时长，当前时长）
 - (void)audioPlaying:(NSTimeInterval)totalTime time:(NSTimeInterval)currentTime
 { }
 
 /// 结束播放音频
 - (void)audioPlayFinished
 { }

*/


