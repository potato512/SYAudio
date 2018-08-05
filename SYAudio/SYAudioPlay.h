//
//  SYAudioPlay.h
//  zhangshaoyu
//
//  Created by Herman on 2018/8/5.
//  Copyright © 2018年 zhangshaoyu. All rights reserved.
//  音频播放（播放本地文件，或播放网络文件）

#import <Foundation/Foundation.h>
#import "SYAudioProtocol.h"

@interface SYAudioPlay : NSObject

/// 代理
@property (nonatomic, weak) id<SYAudioDelegate> delegate;

/// 开始播放
- (void)playerStart:(NSString *)filePath complete:(void (^)(BOOL isFailed))complete;

/// 暂停播放
- (void)playerPause;

@end
