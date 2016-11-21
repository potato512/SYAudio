//
//  SYAudioFile.m
//  DemoAudio
//
//  Created by zhangshaoyu on 16/11/18.
//  Copyright © 2016年 zhangshaoyu. All rights reserved.
//

#import "SYAudioFile.h"

@implementation SYAudioFile

/// 录音文件保存路径
+ (NSString *)SYAudioGetFilePathWithDate
{
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYYMMddHHmmss"];
    NSString *filePath = [dateFormatter stringFromDate:currentDate];
    // 文件名称
    filePath = [NSString stringWithFormat:@"%@.aac", filePath];
    
    NSString *tmpPath = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
    
    filePath = [tmpPath stringByAppendingFormat:@"/%@",filePath];
    
    return filePath;
}

/// 获取文件名（包含后缀，如：xxx.acc；不包含文件类型，如xxx）
+ (NSString *)SYAudioGetFileNameWithFilePath:(NSString *)filePath type:(BOOL)hasFileType
{
    NSString *fileName = [filePath stringByDeletingLastPathComponent];
    if (hasFileType)
    {
        fileName = [filePath lastPathComponent];
    }
    return fileName;
}

/// 获取文件大小
+ (long long)SYAudioGetFileSizeWithFilePath:(NSString *)filePath
{
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (isExist)
    {
        NSDictionary *fileDict = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        long long fileSize = fileDict.fileSize;
        return fileSize;
    }
    
    return 0.0;
}

/// 删除文件
+ (void)SYAudioDeleteFileWithFilePath:(NSString *)filePath
{
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (isExist)
    {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
}

@end
