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

#pragma mark - 代理协议

@protocol SYAudioDelegate <NSObject>

/// 开始录音
- (void)recordBegined;
/// 停止录音
- (void)recordFinshed;
/// 正在录音中，录音音量监测
- (void)recordingUpdateVoice:(double)metering;
/// 正中录音中，是否录音倒计时、录音剩余时长
- (void)recordingWithResidualTime:(NSTimeInterval)time timer:(BOOL)isTimer;

/// 开始压缩录音
- (void)recordBeginConvert;
/// 结束压缩录音
- (void)recordFinshConvert:(NSString *)filePath;

/// 开始播放音频
- (void)audioPlayBegined;
/// 正在播放音频（总时长，当前时长）
- (void)audioPlaying:(NSTimeInterval)totalTime time:(NSTimeInterval)currentTime;
/// 结束播放音频
- (void)audioPlayFinished;

@end

#pragma mark - 录音功能

@interface SYAudio : NSObject

/// 音频处理单例
+ (SYAudio *)shareAudio;

/// 是否监测录音音量（默认NO）
@property (nonatomic, assign) BOOL monitorVoice;

/// 代理
@property (nonatomic, weak) id<SYAudioDelegate> delegate;

/// 音频文件压缩文件名
@property (nonatomic, strong) NSString *filePathMP3;

/// 录音限制时长（默认0，即没有时长限制）
@property (nonatomic, assign) NSTimeInterval totalTime;


#pragma mark - 录音

/// 开始录音
- (void)audioRecorderStartWithFilePath:(NSString *)filePath;

/// 停止录音
- (void)audioRecorderStop;

/// 录音时长
- (NSTimeInterval)durationAudioRecorderWithFilePath:(NSString *)filePath;

#pragma mark - 播放/停止

/// 音频开始播放或停止
- (void)audioPlayWithFilePath:(NSString *)filePath;

/// 音频播放停止
- (void)audioStop;

@end

/*
 使用示例
 1、导入头文件
 #import "SYAudio.h"
 
 2、属性设置
 // 是否显示录音音量状态图标，默认显示
 [SYAudio shareAudio].showRecorderStatus = NO;
 
 3、录音
 （1）定义录音文件路径
 NSString *filePath = [SYAudioFile SYAudioGetFilePathWithDate];
 
 （2）开始录音
 [button addTarget:self action:@selector(startRecorder:) forControlEvents:UIControlEventTouchDown];
 - (void)startRecorder
 {
     [[SYAudio shareAudio] audioRecorderStartWithFilePath:filePath];
 }
 
 （3）停止录音，并保存录音
 [button addTarget:self action:@selector(saveRecorder:) forControlEvents:UIControlEventTouchUpInside];
 [button addTarget:self action:@selector(saveRecorder:) forControlEvents:UIControlEventTouchDragExit];
 // 停止录音，并保存
 - (void)saveRecorder
 {
     [[SYAudio shareAudio] audioRecorderStop];
 }
 
 4、播放录音，或播放音乐文件
 - (void)playRecorder
 {
     [[SYAudio shareAudio] audioPlayWithFilePath:filePath];
 }
 
 5、停止播放录音，或停止播放音乐文件
 - (void)stopRecorder
 {
     [[SYAudio shareAudio] audioStop];
 }


*/


