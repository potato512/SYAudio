//
//  AudioHelper.m
//  DemoVideo
//
//  Created by zhangshaoyu on 13/11/7.
//  Copyright (c) 2015年 zhangshaoyu. All rights reserved.
//

#import "AudioHelper.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"

@interface AudioHelper () <AVAudioRecorderDelegate>

@property (nonatomic, strong) NSMutableDictionary *audioRecorderSetting; // 录音设置
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;            // 录音
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;                // 播放
@property (nonatomic, assign) double audioRecorderTime;                  // 录音时长
@property (nonatomic, strong) UIView *imgView;                           // 录音音量图像父视图
@property (nonatomic, strong) UIImageView *audioRecorderVoiceImgView;    // 录音音量图像
@property (nonatomic, strong) NSTimer *audioRecorderTimer;               // 录音音量计时器

@end

@implementation AudioHelper

#pragma mark - 初始化

- (id)init
{
    self = [super init];
    
    if (self)
    {

    }
    
    return self;
}

// 录音
+ (AudioHelper *)shareManager
{
    static AudioHelper *sharedManager;
    
    if (sharedManager == nil)
    {
        @synchronized (self) {
            sharedManager = [[self alloc] init];
            assert(sharedManager != nil);
        }
    }
    
    return sharedManager;
}

// 内存释放
- (void)dealloc
{
    if (self.audioRecorderTimer)
    {
        [self.audioRecorderTimer invalidate];
    }
    if (self.audioRecorderSetting)
    {
        self.audioRecorderSetting = nil;
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

#pragma mark - setter

- (NSMutableDictionary *)audioRecorderSetting
{
    if (!_audioRecorderSetting)
    {
        // 参数设置 格式、采样率、录音通道、线性采样位数、录音质量
        _audioRecorderSetting = [NSMutableDictionary dictionary];
        [_audioRecorderSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
        [_audioRecorderSetting setValue:[NSNumber numberWithInt:11025] forKey:AVSampleRateKey];
        [_audioRecorderSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
        [_audioRecorderSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [_audioRecorderSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    }
    return _audioRecorderSetting;
}

#pragma mark - 音频录制

// 开始录音，保存路径
- (void)startAudioRecorder:(NSString *)filePath;
{
    /*
     // 录音文件名称 根据时间来命名以保证每次录音文件名不重复
     NSString *recorderName = [NSString stringWithFormat:@"%@.aac",[self getSystemDateAndTime]];
     // 录音文件路径
     NSString *recorderPath = GetTmpPath();
     self.recorderFile = [recorderPath stringByAppendingFormat:@"/%@",recorderName];
     */
    
    // 生成录音文件
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:filePath]
                                                     settings:self.audioRecorderSetting
                                                        error:nil];
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
            
            // 录音音量显示 75*111
            /*
             self.audioRecorderVoiceImgView = [[UIImageView alloc] initWithFrame:CGRectMake((mainScrollView.frame.size.width - 60) / 2, (mainScrollView.frame.size.height - 60 * 111 / 75) / 2, 60, 60 * 111 / 75)];
             [mainScrollView addSubview:audioRecorderVoiceImgView];
             */
            
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
            self.audioRecorderTimer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(detectionVoice) userInfo:nil repeats:YES];
        }
    }
}

// 录音音量显示
- (void)detectionVoice
{
    // 刷新音量数据
    [self.audioRecorder updateMeters];
    // 获取音量的平均值  [recorder averagePowerForChannel:0];
    // 音量的最大值  [recorder peakPowerForChannel:0];
    
    double lowPassResults = pow(10, (0.05 * [self.audioRecorder peakPowerForChannel:0]));
    // NSLog(@"%lf",lowPassResults);
    // 最大50  0
    // 图片 小-》大
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

// 停止录音
- (void)stopAudioRecorder
{
    if (self.audioRecorder)
    {
        if ([self.audioRecorder isRecording])
        {
            // 获取录音时长
            self.audioRecorderTime = [self.audioRecorder currentTime];
            [self.audioRecorder stop];
            // NSLog(@"audioRecorderTime is %f",audioRecorderTime);
            
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
    [self.audioRecorderTimer invalidate];
}

// 录音时长
- (NSTimeInterval)timeOfAudioRecorder:(NSString *)filePath
{
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath]
                                                              error:nil];
    NSTimeInterval time = self.audioPlayer.duration;
    self.audioPlayer = nil;
    return time;
}

#pragma mark - 音频播放

// 录音播放或停止
- (void)playAudioRecorder:(NSString *)filePath
{
    if (self.audioPlayer)
    {
        // 判断当前与下一个是否相同
        // 相同时，点击时要么播放，要么停止
        // 不相同时，点击时停止播放当前的，开始播放下一个
        NSString *currentStr = [self.audioPlayer.url relativeString];
        
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
                [self playAudioWithFile:filePath];
            }
        }
        else
        {
            [self stopAudio];
            [self playAudioWithFile:filePath];
        }
    }
    else
    {
        [self playAudioWithFile:filePath];
    }
}

// 音频播放或停止
- (void)playAudio:(NSString *)filePath;
{
    if (self.audioPlayer)
    {
        // 判断当前与下一个是否相同
        // 相同时，点击时要么播放，要么停止
        // 不相同时，点击时停止播放当前的，开始播放下一个
        NSString *currentStr = [self.audioPlayer.url relativeString];
        
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
                [self playAudioWithFile:filePath];
            }
        }
        else
        {
            [self stopAudio];
            [self playAudioWithFile:filePath];
        }
    }
    else
    {
        [self playAudioWithFile:filePath];
    }
}

// 播放录音
- (void)playAudioWithFile:(NSString *)filePath
{
    // 判断将要播放文件是否存在
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        return;
    }
    
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath]
                                                              error:nil];
    if (self.audioPlayer)
    {
        if ([self.audioPlayer prepareToPlay])
        {
            // 播放时，设置时喇叭播放否则音量很小
            AVAudioSession *playSession = [AVAudioSession sharedInstance];
            [playSession setCategory:AVAudioSessionCategoryPlayback error:nil];
            [playSession setActive:YES error:nil];
            
            [self.audioPlayer play];
        }
    }
}

// 停止播放
- (void)stopAudio
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

#pragma mark - 获取文件名称及类型

// 获取文件名及其后缀
NSString *GetFileNameAndType(NSString *filePath)
{
    if (filePath && 0 < filePath.length)
    {
        NSRange range = [filePath rangeOfString:@"/" options:NSBackwardsSearch];
        NSString *file = [filePath substringFromIndex:range.location + 1];
        return file;
    }
    return nil;
}

@end
