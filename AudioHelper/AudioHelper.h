//
//  AudioHelper.h
//  DemoVideo
//
//  Created by zhangshaoyu on 13/11/7.
//  Copyright (c) 2015年 zhangshaoyu. All rights reserved.
//  音频播放器（系统）

#import <Foundation/Foundation.h>

@interface AudioHelper : NSObject

+ (AudioHelper *)shareManager;

//设置录音器 初化值
//- (void)setAudioRecorderDict;

/**
 * 方法描述: 开始录音
 * 输入参数: (NSString *)filePath 文件路径
 * 返回值: 无
 * 创建人: 张绍裕
 * 创建时间: 2013-11-07
 */
- (void)startAudioRecorder:(NSString *)filePath;

//录音音量显示
//- (void)detectionVoice;

/**
 * 方法描述: 停止录音
 * 输入参数: 无
 * 返回值: 无
 * 创建人: 张绍裕
 * 创建时间: 2013-11-07
 */
- (void)stopAudioRecorder;

/**
 * 方法描述: 获得录音的时间长
 * 输入参数: (NSString *)filePath 文件路径
 * 返回值: (NSTimeInterval) 录音时间长
 * 创建人: 张绍裕
 * 创建时间: 2013-11-07
 */
- (NSTimeInterval)timeOfAudioRecorder:(NSString *)filePath;

/**
 * 方法描述: 录音开始播放或停止播放（点击不同录音文件时停止当前的播放下一个，点击同一个时开始播放或停止播放）
 * 输入参数: (NSString *)filePath 文件路径
 * 返回值: 无
 * 创建人: 张绍裕
 * 创建时间: 2013-11-07
 */
- (void)playAudioRecorder:(NSString *)filePath;

/**
 * 方法描述: 音频开始播放或停止播放（点击不同音频文件时停止当前的播放下一个，点击同一个时开始播放或停止播放）
 * 输入参数: (NSString *)filePath 文件路径
 * 返回值: 无
 * 创建人: 张绍裕
 * 创建时间: 2013-11-07
 */
- (void)playAudio:(NSString *)filePath;

/**
 * 方法描述: 录音停止播放
 * 输入参数: 无
 * 返回值: 无
 * 创建人: 张绍裕
 * 创建时间: 2013-11-07
 */
- (void)stopAudio;

@end
