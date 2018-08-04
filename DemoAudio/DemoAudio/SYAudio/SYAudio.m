//
//  SYAudio.m
//  zhangshaoyu
//
//  Created by zhangshaoyu on 13/11/7.
//  Copyright (c) 2015年 zhangshaoyu. All rights reserved.
//

#import "SYAudio.h"
#import "lame.h"

@interface SYAudio () <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (nonatomic, strong) NSMutableDictionary *audioRecorderDict; // 录音设置
@property (nonatomic, strong) AVAudioRecorder *audioRecorder; // 录音
@property (nonatomic, strong) NSString *recorderFilePath;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer; // 播放
@property (nonatomic, strong) NSString *playerFilePath;

@property (nonatomic, strong) NSTimer *voiceTimer; // 录音音量计时器

@property (nonatomic, strong) NSTimer *timecountTimer; // 录音倒计时计时器
@property (nonatomic, assign) NSTimeInterval timecountTime; // 录音倒计时时间

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
        self.monitorVoice = NO;
    }
    
    return self;
}

// 内存释放
- (void)dealloc
{
    // 内存释放前先停止录音，或音频播放
    [self audioStop];
    [self audioRecorderStop];
    [self stopVoiceTimer];
    [self stopTimecountTimer];
    
    if (self.audioRecorderDict)
    {
        self.audioRecorderDict = nil;
    }
    if (self.audioRecorder)
    {
        self.audioRecorder.delegate = nil;
        self.audioRecorder = nil;
    }
    if (self.audioPlayer)
    {
        self.audioPlayer.delegate = nil;
        self.audioPlayer = nil;
    }
}

#pragma mark - getter

- (NSMutableDictionary *)audioRecorderDict
{
    if (!_audioRecorderDict)
    {
        // 参数设置 格式、采样率、录音通道、线性采样位数、录音质量
        _audioRecorderDict = [NSMutableDictionary dictionary];
        // kAudioFormatMPEG4AAC ：xxx.acc；kAudioFormatLinearPCM ：xxx.caf
        [_audioRecorderDict setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
        [_audioRecorderDict setValue:[NSNumber numberWithInt:16000] forKey:AVSampleRateKey];
        [_audioRecorderDict setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
        [_audioRecorderDict setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [_audioRecorderDict setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    }
    return _audioRecorderDict;
}

#pragma mark - 录音

/// 开始录音
- (void)audioRecorderStartWithFilePath:(NSString *)filePath
{
    self.recorderFilePath = filePath;
    // 生成录音文件
    NSURL *urlAudioRecorder = [NSURL fileURLWithPath:filePath];
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:urlAudioRecorder settings:self.audioRecorderDict error:nil];
    
    // 开启音量检测
    self.audioRecorder.meteringEnabled = YES;
    self.audioRecorder.delegate = self;
    
    if (self.audioRecorder)
    {
        // 录音时设置audioSession属性，否则不兼容Ios7
        AVAudioSession *recordSession = [AVAudioSession sharedInstance];
        [recordSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [recordSession setActive:YES error:nil];
        
        if ([self.audioRecorder prepareToRecord])
        {
            [self.audioRecorder record];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(recordBegined)]) {
                [self.delegate recordBegined];
            }

            [self startVoiceTimer];
            [self startTimecountTimer];
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
            [self.audioRecorder stop];
            NSLog(@"1 file size = %lld", [SYAudioFile SYAudioGetFileSizeWithFilePath:self.recorderFilePath]);
            
            [self audioConvertMP3];
            
            // 停止录音后释放掉
            self.audioRecorder.delegate = nil;
            self.audioRecorder = nil;
        }
    }
    
    [self stopVoiceTimer];
    [self stopTimecountTimer];
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

#pragma mark - 播放/停止

/// 音频开始播放或停止
- (void)audioPlayWithFilePath:(NSString *)filePath
{
    if (self.audioPlayer)
    {
        // 判断当前与下一个是否相同
        // 相同时，点击时要么播放，要么停止
        // 不相同时，点击时停止播放当前的，开始播放下一个
        NSString *pathPrevious = [self.audioPlayer.url relativeString];
        pathPrevious = [pathPrevious stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
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
        NSRange range = [pathPrevious rangeOfString:filePath];
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
    self.audioPlayer.delegate = self;
    if (self.audioPlayer)
    {
        if ([self.audioPlayer prepareToPlay])
        {
            // 播放时，设置喇叭播放否则音量很小
            AVAudioSession *playSession = [AVAudioSession sharedInstance];
            [playSession setCategory:AVAudioSessionCategoryPlayback error:nil];
            [playSession setActive:YES error:nil];
            
            [self.audioPlayer play];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(audioPlayBegined)]) {
                [self.delegate audioPlayBegined];
            }
            
            if (self.audioPlayer.isPlaying) {
                NSTimeInterval totalTime = self.audioPlayer.duration;
                if (self.delegate && [self.delegate respondsToSelector:@selector(audioPlaying:time:)]) {
                    [self.delegate audioPlaying:totalTime time:self.audioPlayer.currentTime];
                }
            }
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
        
        self.audioPlayer.delegate = nil;
        self.audioPlayer = nil;
    }
}

#pragma mark - timer

#pragma mark 录音计时器

- (void)startVoiceTimer
{
    if (self.monitorVoice) {
        self.voiceTimer = SYAudioTimerInitialize(0.0, nil, YES, self, @selector(detectionVoice));
        SYAudioTimerStart(self.voiceTimer);
        NSLog(@"开始检测音量");
    }
}

- (void)stopVoiceTimer
{
    if (self.voiceTimer)
    {
        SYAudioTimerStop(self.voiceTimer);
        SYAudioTimerKill(self.voiceTimer);
        NSLog(@"停止检测音量");
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
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordingUpdateVoice:)])
    {
        [self.delegate recordingUpdateVoice:lowPassResults];
    }
    
    NSLog(@"voice: %f", lowPassResults);
}

#pragma mark 倒计时计时器

- (void)startTimecountTimer
{
    if (self.totalTime <= 0.0) {
        return;
    }
    
    self.timecountTime = -1.0;
    self.timecountTimer = SYAudioTimerInitialize(0.0, nil, YES, self, @selector(detectionTime));
    SYAudioTimerStart(self.timecountTimer);
    NSLog(@"开始录音倒计时");
}

- (void)stopTimecountTimer
{
    if (self.timecountTimer)
    {
        SYAudioTimerStop(self.timecountTimer);
        SYAudioTimerKill(self.timecountTimer);
        NSLog(@"停止录音倒计时");
    }
}

- (void)detectionTime
{
    self.timecountTime += 1.0;
    NSTimeInterval time = (self.totalTime - self.timecountTime);
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordingWithResidualTime:timer:)]) {
        [self.delegate recordingWithResidualTime:time timer:(self.totalTime > 0.0 ? YES : NO)];
    }
    
    if (time <= 0.0 && self.totalTime > 0.0)
    {
        [self audioRecorderStop];
    }
}

#pragma mark - Convert Utils

- (void)audioConvertMP3
{
    NSString *cafFilePath = self.recorderFilePath;
    NSString *mp3FilePath = [SYAudioFile SYAudioMP3FilePath:self.filePathMP3];
    
    NSLog(@"MP3转换开始");
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordBeginConvert)]) {
        [self.delegate recordBeginConvert];
    }
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4 * 1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 16000); // 采样率不对，编出来的声音完全不对
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2 * sizeof(short int), PCM_SIZE, pcm);
            if (read == 0) {
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            } else {
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            }
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    } @catch (NSException *exception) {
        NSLog(@"%@", [exception description]);
        mp3FilePath = nil;
    } @finally {
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
        NSLog(@"MP3转换结束");
        NSLog(@"2 file size = %lld", [SYAudioFile SYAudioGetFileSizeWithFilePath:mp3FilePath]);
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(recordFinshConvert:)]) {
            [self.delegate recordFinshConvert:mp3FilePath];
        }
    }
}

#pragma mark - 代理

#pragma mark AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordFinshed)]) {
        [self.delegate recordFinshed];
    }
}

#pragma mark AVAudioPlayerDelegate

/* audioPlayerDidFinishPlaying:successfully: is called when a sound has finished playing. This method is NOT called if the player is stopped due to an interruption. */
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioPlayFinished)]) {
        [self.delegate audioPlayFinished];
    }
}

/* if an error occurs while decoding it will be reported to the delegate. */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error
{
    [self audioStop];
}

/* AVAudioPlayer INTERRUPTION NOTIFICATIONS ARE DEPRECATED - Use AVAudioSession instead. */

/* audioPlayerBeginInterruption: is called when the audio session has been interrupted while the player was playing. The player will have been paused. */
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    
}

/* audioPlayerEndInterruption:withOptions: is called when the audio session interruption has ended and this player had been interrupted while playing. */
/* Currently the only flag is AVAudioSessionInterruptionFlags_ShouldResume. */
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags
{
    [self audioStop];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withFlags:(NSUInteger)flags
{
    [self audioStop];
}

/* audioPlayerEndInterruption: is called when the preferred method, audioPlayerEndInterruption:withFlags:, is not implemented. */
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{
    [self audioStop];
}

@end
