//
//  SYAudio.m
//  zhangshaoyu
//
//  Created by zhangshaoyu on 13/11/7.
//  Copyright (c) 2015年 zhangshaoyu. All rights reserved.
//

#import "SYAudio.h"

@interface SYAudio ()

//@property (nonatomic, strong) AVAudioPlayer *audioPlayer; // 播放
//@property (nonatomic, strong) NSString *playerFilePath;

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

#pragma mark - 播放/停止

///// 音频开始播放或停止
//- (void)audioPlayWithFilePath:(NSString *)filePath
//{
//    if (self.audioPlayer)
//    {
//        // 判断当前与下一个是否相同
//        // 相同时，点击时要么播放，要么停止
//        // 不相同时，点击时停止播放当前的，开始播放下一个
//        NSString *pathPrevious = [self.audioPlayer.url relativeString];
//        pathPrevious = [pathPrevious stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//
//        /*
//         NSString *currentName = [self getFileNameAndType:currentStr];
//         NSString *nextName = [self getFileNameAndType:filePath];
//
//         if ([currentName isEqualToString:nextName])
//         {
//             if ([self.audioPlayer isPlaying])
//             {
//                 [self.audioPlayer stop];
//                 self.audioPlayer = nil;
//             }
//             else
//             {
//                 self.audioPlayer = nil;
//                 [self audioPlayerPlay:filePath];
//             }
//         }
//         else
//         {
//             [self audioPlayerStop];
//             [self audioPlayerPlay:filePath];
//         }
//         */
//
//        // currentStr包含字符"file://location/"，通过判断filePath是否为currentPath的子串，是则相同，否则不同
//        NSRange range = [pathPrevious rangeOfString:filePath];
//        if (range.location != NSNotFound)
//        {
//            if ([self.audioPlayer isPlaying])
//            {
//                [self.audioPlayer stop];
//                self.audioPlayer = nil;
//            }
//            else
//            {
//                self.audioPlayer = nil;
//                [self audioPlayerPlay:filePath];
//            }
//        }
//        else
//        {
//            [self audioPlayerStop];
//            [self audioPlayerPlay:filePath];
//        }
//    }
//    else
//    {
//        [self audioPlayerPlay:filePath];
//    }
//}
//
///// 音频播放停止
//- (void)audioStop
//{
//    [self audioPlayerStop];
//}
//
///// 音频播放器开始播放
//- (void)audioPlayerPlay:(NSString *)filePath
//{
//    // 判断将要播放文件是否存在
//    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
//    if (!isExist)
//    {
//        return;
//    }
//
//    NSURL *urlFile = [NSURL fileURLWithPath:filePath];
//    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:urlFile error:nil];
//    self.audioPlayer.delegate = self;
//    if (self.audioPlayer)
//    {
//        if ([self.audioPlayer prepareToPlay])
//        {
//            // 播放时，设置喇叭播放否则音量很小
//            AVAudioSession *playSession = [AVAudioSession sharedInstance];
//            [playSession setCategory:AVAudioSessionCategoryPlayback error:nil];
//            [playSession setActive:YES error:nil];
//
//            [self.audioPlayer play];
//
////            if (self.delegate && [self.delegate respondsToSelector:@selector(audioPlayBegined)]) {
////                [self.delegate audioPlayBegined];
////            }
//
////            if (self.audioPlayer.isPlaying) {
////                NSTimeInterval totalTime = self.audioPlayer.duration;
////                if (self.delegate && [self.delegate respondsToSelector:@selector(audioPlaying:time:)]) {
////                    [self.delegate audioPlaying:totalTime time:self.audioPlayer.currentTime];
////                }
////            }
//        }
//    }
//}
//
///// 音频播放器停止播放
//- (void)audioPlayerStop
//{
//    if (self.audioPlayer)
//    {
//        if ([self.audioPlayer isPlaying])
//        {
//            [self.audioPlayer stop];
//        }
//
//        self.audioPlayer.delegate = nil;
//        self.audioPlayer = nil;
//    }
//}

@end
