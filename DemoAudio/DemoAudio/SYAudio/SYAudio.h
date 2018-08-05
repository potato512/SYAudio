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

#pragma mark - 播放/停止

///// 音频开始播放或停止
//- (void)audioPlayWithFilePath:(NSString *)filePath;
//
///// 音频播放停止
//- (void)audioStop;

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


