//
//  SYAudio.m
//  zhangshaoyu
//
//  Created by zhangshaoyu on 13/11/7.
//  Copyright (c) 2015年 zhangshaoyu. All rights reserved.
//

#import "SYAudio.h"

// 导入录音头文件（注意添加framework：AVFoundation.framework、AudioToolbox.framework）
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"

@interface SYAudio () <AVAudioRecorderDelegate>

@property (nonatomic, strong) NSMutableDictionary *audioRecorderDict;    // 录音设置
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;            // 录音
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;                // 播放
@property (nonatomic, assign) NSTimeInterval audioRecorderTime;          // 录音时长
@property (nonatomic, strong) UIView *imgView;                           // 录音音量图像父视图
@property (nonatomic, strong) UIImageView *audioRecorderVoiceImgView;    // 录音音量图像
@property (nonatomic, strong) NSTimer *audioRecorderTimer;               // 录音音量计时器

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
    if (self)
    {

    }
    
    return self;
}

// 内存释放
- (void)dealloc
{
    // 内存释放前先停止录音，或音频播放
    [self audioStop];
    [self audioRecorderStop];
    [self timerStop];
    
    if (self.audioRecorderDict)
    {
        self.audioRecorderDict = nil;
    }
    if (self.audioRecorder)
    {
        self.audioRecorder = nil;
    }
    if (self.audioPlayer)
    {
        self.audioPlayer = nil;
    }
    if (self.imgView)
    {
        self.imgView = nil;
    }
    if (self.audioRecorderVoiceImgView)
    {
        self.audioRecorderVoiceImgView = nil;
    }
}

#pragma mark - getter

- (NSMutableDictionary *)audioRecorderDict
{
    if (!_audioRecorderDict)
    {
        // 参数设置 格式、采样率、录音通道、线性采样位数、录音质量
        _audioRecorderDict = [NSMutableDictionary dictionary];
        [_audioRecorderDict setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
        [_audioRecorderDict setValue:[NSNumber numberWithInt:11025] forKey:AVSampleRateKey];
        [_audioRecorderDict setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
        [_audioRecorderDict setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [_audioRecorderDict setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    }
    return _audioRecorderDict;
}

#pragma mark - 音频处理-录音

/// 开始录音
- (void)audioRecorderStartWithFilePath:(NSString *)filePath
{
    // 生成录音文件
    NSURL *urlAudioRecorder = [NSURL fileURLWithPath:filePath];
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:urlAudioRecorder settings:self.audioRecorderDict error:nil];
    
    // 开启音量检测
    [self.audioRecorder setMeteringEnabled:YES];
    [self.audioRecorder setDelegate:self];
    
    if (self.audioRecorder)
    {
        // 录音时设置audioSession属性，否则不兼容Ios7
        AVAudioSession *recordSession = [AVAudioSession sharedInstance];
        [recordSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [recordSession setActive:YES error:nil];
        
        if ([self.audioRecorder prepareToRecord])
        {
            [self.audioRecorder record];
            
            //录音音量显示 75*111
            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            UIView *view = [delegate window];
            
            self.imgView = [[UIView alloc] initWithFrame:CGRectMake((view.frame.size.width - 120) / 2, (view.frame.size.height - 120) / 2, 120, 120)];
            [view addSubview:self.imgView];
            [self.imgView.layer setCornerRadius:10.0];
            [self.imgView.layer setBackgroundColor:[UIColor blackColor].CGColor];
            [self.imgView setAlpha:0.8];
            
            self.audioRecorderVoiceImgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.imgView.frame.size.width - 60) / 2, (self.imgView.frame.size.height - 60 * 111 / 75) / 2, 60, 60 * 111 / 75)];
            [self.imgView addSubview:self.audioRecorderVoiceImgView];
            [self.audioRecorderVoiceImgView setImage:[UIImage imageNamed:@"record_animate_01.png"]];
            [self.audioRecorderVoiceImgView setBackgroundColor:[UIColor clearColor]];
            
            // 设置定时检测
            [self timerStart];
        }
    }
}

/// 停止录音
- (void)audioRecorderStop
{
    if (self.audioRecorder)
    {
        if ([self.audioRecorder isRecording])
        {
            // 获取录音时长
            self.audioRecorderTime = [self.audioRecorder currentTime];
            [self.audioRecorder stop];
            
            // 停止录音后释放掉
            self.audioRecorder = nil;
        }
    }
    
    // 移除音量图标
    if (self.audioRecorderVoiceImgView)
    {
        [self.audioRecorderVoiceImgView setHidden:YES];
        [self.audioRecorderVoiceImgView setImage:nil];
        [self.audioRecorderVoiceImgView removeFromSuperview];
        self.audioRecorderVoiceImgView = nil;
        
        [self.imgView removeFromSuperview];
        self.imgView = nil;
    }
    
    // 释放计时器
    [self timerStop];
}

/// 录音时长
- (NSTimeInterval)durationAudioRecorderWithFilePath:(NSString *)filePath
{
    NSURL *urlFile = [NSURL fileURLWithPath:filePath];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:urlFile error:nil];
    NSTimeInterval time = self.audioPlayer.duration;
    self.audioPlayer = nil;
    return time;
}

#pragma mark - 音频处理-播放/停止

/// 音频开始播放或停止
- (void)audioPlayWithFilePath:(NSString *)filePath
{
    if (self.audioPlayer)
    {
        // 判断当前与下一个是否相同
        // 相同时，点击时要么播放，要么停止
        // 不相同时，点击时停止播放当前的，开始播放下一个
        NSString *currentStr = [self.audioPlayer.url relativeString];
        
        /*
         NSString *currentName = [self getFileNameAndType:currentStr];
         NSString *nextName = [self getFileNameAndType:filePath];
         
         if ([currentName isEqualToString:nextName])
         {
             if ([self.audioPlayer isPlaying])
             {
                 [self.audioPlayer stop];
                 self.audioPlayer = nil;
             }
             else
             {
                 self.audioPlayer = nil;
                 [self audioPlayerPlay:filePath];
             }
         }
         else
         {
             [self audioPlayerStop];
             [self audioPlayerPlay:filePath];
         }
         */
        
        // currentStr包含字符"file://location/"，通过判断filePath是否为currentPath的子串，是则相同，否则不同
        NSRange range = [currentStr rangeOfString:filePath];
        if (range.location != NSNotFound)
        {
            if ([self.audioPlayer isPlaying])
            {
                [self.audioPlayer stop];
                self.audioPlayer = nil;
            }
            else
            {
                self.audioPlayer = nil;
                [self audioPlayerPlay:filePath];
            }
        }
        else
        {
            [self audioPlayerStop];
            [self audioPlayerPlay:filePath];
        }
    }
    else
    {
        [self audioPlayerPlay:filePath];
    }
    
}

/// 音频播放停止
- (void)audioStop
{
    [self audioPlayerStop];
}


/// 音频播放器开始播放
- (void)audioPlayerPlay:(NSString *)filePath
{
    // 判断将要播放文件是否存在
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (!isExist)
    {
        return;
    }
    
    NSURL *urlFile = [NSURL fileURLWithPath:filePath];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:urlFile error:nil];
    if (self.audioPlayer)
    {
        if ([self.audioPlayer prepareToPlay])
        {
            // 播放时，设置喇叭播放否则音量很小
            AVAudioSession *playSession = [AVAudioSession sharedInstance];
            [playSession setCategory:AVAudioSessionCategoryPlayback error:nil];
            [playSession setActive:YES error:nil];
            
            [self.audioPlayer play];
        }
    }
}

/// 音频播放器停止播放
- (void)audioPlayerStop
{
    if (self.audioPlayer)
    {
        if ([self.audioPlayer isPlaying])
        {
            [self.audioPlayer stop];
        }
        
        self.audioPlayer = nil;
    }
}

#pragma mark - timer

- (void)timerStart
{
    if (self.audioRecorderTimer == nil)
    {
        // 设置定时检测
        self.audioRecorderTimer = SYAudioTimerInitialize(0.0, nil, YES, self, @selector(detectionVoice));
    }
    
    SYAudioTimerStart(self.audioRecorderTimer);
}

- (void)timerStop
{
    if (self.audioRecorderTimer)
    {
        SYAudioTimerStop(self.audioRecorderTimer);
        SYAudioTimerKill(self.audioRecorderTimer);
    }
}


/// 录音音量显示
- (void)detectionVoice
{
    // 刷新音量数据
    [self.audioRecorder updateMeters];
    
//    // 获取音量的平均值
//    [self.audioRecorder averagePowerForChannel:0];
//    // 音量的最大值
//    [self.audioRecorder peakPowerForChannel:0];
    
    double lowPassResults = pow(10, (0.05 * [self.audioRecorder peakPowerForChannel:0]));
    
    if (0 < lowPassResults <= 0.06)
    {
        [self.audioRecorderVoiceImgView setImage:[UIImage imageNamed:@"record_animate_01.png"]];
    }
    else if (0.06 < lowPassResults <= 0.13)
    {
        [self.audioRecorderVoiceImgView setImage:[UIImage imageNamed:@"record_animate_02.png"]];
    }
    else if (0.13 < lowPassResults <= 0.20)
    {
        [self.audioRecorderVoiceImgView setImage:[UIImage imageNamed:@"record_animate_03.png"]];
    }
    else if (0.20 < lowPassResults <= 0.27)
    {
        [self.audioRecorderVoiceImgView setImage:[UIImage imageNamed:@"record_animate_04.png"]];
    }
    else if (0.27 < lowPassResults <= 0.34)
    {
        [self.audioRecorderVoiceImgView setImage:[UIImage imageNamed:@"record_animate_05.png"]];
    }
    else if (0.34 < lowPassResults <= 0.41)
    {
        [self.audioRecorderVoiceImgView setImage:[UIImage imageNamed:@"record_animate_06.png"]];
    }
    else if (0.41 < lowPassResults <= 0.48)
    {
        [self.audioRecorderVoiceImgView setImage:[UIImage imageNamed:@"record_animate_07.png"]];
    }
    else if (0.48 < lowPassResults <= 0.55)
    {
        [self.audioRecorderVoiceImgView setImage:[UIImage imageNamed:@"record_animate_08.png"]];
    }
    else if (0.55 < lowPassResults <= 0.62)
    {
        [self.audioRecorderVoiceImgView setImage:[UIImage imageNamed:@"record_animate_09.png"]];
    }
    else if (0.62 < lowPassResults <= 0.69)
    {
        [self.audioRecorderVoiceImgView setImage:[UIImage imageNamed:@"record_animate_10.png"]];
    }
    else if (0.69 < lowPassResults <= 0.76)
    {
        [self.audioRecorderVoiceImgView setImage:[UIImage imageNamed:@"record_animate_11.png"]];
    }
    else if (0.76 < lowPassResults <= 0.83)
    {
        [self.audioRecorderVoiceImgView setImage:[UIImage imageNamed:@"record_animate_12.png"]];
    }
    else if (0.83 < lowPassResults <= 0.9)
    {
        [self.audioRecorderVoiceImgView setImage:[UIImage imageNamed:@"record_animate_13.png"]];
    }
    else
    {
        [self.audioRecorderVoiceImgView setImage:[UIImage imageNamed:@"record_animate_14.png"]];
    }
}

@end
