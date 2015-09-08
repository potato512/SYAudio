# AudioManager
音频的录制和播放（或是播放音乐）

~~~ javascript

#import "AudioHelper.h"

// UIControlEventTouchDown button事件           
- (void)audioStartClick
{
    // 1 停止播放录音
    [[AudioHelper shareManager] stopAudio];
    
    // 2 录音
    // 录音文件名称 根据时间来命名以保证每次录音文件名不重复
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYYMMddHHmmss"];
    NSString *dateStr = [dateFormatter stringFromDate:currentDate];
    NSString *recorderName = [NSString stringWithFormat:@"%@.aac", dateStr];
    // 录音文件路径
    NSString *tmpPath = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
    NSString *recorderPath = tmpPath;
    self.musicPath = [recorderPath stringByAppendingFormat:@"/%@",recorderName];
    
    [[AudioHelper shareManager] startAudioRecorder:self.musicPath];
}

// UIControlEventTouchUpInside button事件  
- (void)recordStopButtonUp
{
    // 停止录音
    [[AudioHelper shareManager] stopAudioRecorder];
}

// UIControlEventTouchDragExit button事件  
- (void)recordStopButtonExit
{
    // 停止录音
    [[AudioHelper shareManager] stopAudioRecorder];
}

- (void)audioPlayClick
{
//    // 播放本地音乐
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"hongri" ofType:@"mp3"];
//    [[AudioHelper shareManager] playAudio:path];

    // 播放录音
    [[AudioHelper shareManager] playAudioRecorder:self.musicPath];
}

~~~
