//
//  SYAudioProtocol.h
//  zhangshaoyu
//
//  Created by Herman on 2018/8/5.
//  Copyright © 2018年 zhangshaoyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

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

/// 开始播放音频（状态：加载中、加载失败、加载成功正在播放、未知）
- (void)audioPlayBegined:(AVPlayerItemStatus)state;
/// 正在播放音频（总时长，当前时长）
- (void)audioPlaying:(NSTimeInterval)totalTime time:(NSTimeInterval)currentTime;
/// 结束播放音频
- (void)audioPlayFinished;

@end
