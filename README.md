# SYAudio
音频的录制与播放，进行封装后的单例工具组件。
* 使用AVAudioRecorder进行录音
* 使用AVPlayer进行音频播放

# 效果图
![audioImage.gif](./audioImage.gif)


使用注意：
* 添加AVFoundation.framework、AudioToolbox.framework
* 音频处理包括：开始录音、停止录音、播放音频、停止音频播放
* 音频处理是通过按钮进行交互，通常采用三种状态交互方式
  * UIControlEventTouchDown状态时，开始录音
  * UIControlEventTouchUpInside状态时，停止录音，并进行类似音频文件存储的操作
  * UIControlEventTouchDragExit状态时，与UIControlEventTouchUpInside状态进行相同的操作
* 注意隐私设置，添加启用录音功能
  * 设置方法：https://blog.csdn.net/potato512/article/details/52595649
* 播放网络音频文件时，http协议的适配
  * 在plist文件设置属性：`App Transport Security Settings`-`Allow Arbitrary Loads`-`YES`


# 使用示例

导入头文件
```
#import "SYAudio.h"
```

音量图标显示`YES`，或不显示`NO`
```
// 显示
[SYAudio shareAudio].audioRecorder.monitorVoice = YES;

// 不显示
[SYAudio shareAudio].audioRecorder.monitorVoice = NO;
```

音频处理方法-开始录音 
```   
NSString *filePath = xxxxx;
[[SYAudio shareAudio].audioRecorder recorderStart:filePath complete:^(BOOL isFailed) {

}];
```

音频处理方法-停止录音  
```      
[[SYAudio shareAudio].audioRecorder recorderStop];
```

音频处理方法-播放音频（本地音频文件，或网络音频文件均可播放）
```  
NSString *filePath = xxxxx;
[[SYAudio shareAudio].audioPlayer playerStart:filePath complete:^(BOOL isFailed) {

}];
```

音频处理方法-停止音频播放 
```
[[SYAudio shareAudio].audioPlayer playerPause];
```

代理、协议`SYAudioDelegate`，及实现协议方法
```
[SYAudio shareAudio].audioPlayer.delegate = self;
```

实现协议方法

* 录音

```
/// 开始录音
- (void)recordBegined
{

}

/// 停止录音
- (void)recordFinshed
{

}

/// 正在录音中，录音音量监测
- (void)recordingUpdateVoice:(double)lowPassResults
{
    
}

/// 正中录音中，是否录音倒计时、录音剩余时长
- (void)recordingWithResidualTime:(NSTimeInterval)time timer:(BOOL)isTimer
{

}
```

* 压缩
```
/// 开始压缩录音
- (void)recordBeginConvert
{

}

/// 结束压缩录音
- (void)recordFinshConvert:(NSString *)filePath
{

}
```

* 播放
```
/// 开始播放音频
- (void)audioPlayBegined:(AVPlayerItemStatus)state
{

}

/// 正在播放音频（总时长，当前时长）
- (void)audioPlaying:(NSTimeInterval)totalTime time:(NSTimeInterval)currentTime
{

}

/// 结束播放音频
- (void)audioPlayFinished
{

}
```


# 修改完善
* 20180805
  * 版本号：1.2.0
  * 功能完善

* 20180804
  * 版本号：1.1.0
  * 功能完善
    * 拆分音频录制
    * 拆分音频播放
      * 本地音频播放
      * 网络音频播放

  * 版本号：1.0.3
  * 功能完善
   * 录音压缩格式设置：录音文件格式为caf，压缩后文件格式为mp3
   * 录音结束时处理
   * 播放时，时长处理

* 20180726
  * 版本号：1.0.2
  * 功能完善
    * 添加代理协议
      * 开始录音
      * 停止录音
      * 录音音量检测
      * 开始音频压缩
      * 结束音频压缩
    * 音频压缩
    * 录音时长限制
    
* 20180725
  * 版本号：1.0.1
  * 修改完善
    * 音量图标显示异常修改
    * 音量图标是否显示属性设置`showRecorderVoiceStatus`

* 20170630 当前播放与上一条播放判断是否同一个文件的方法添加中文转码，避免判断失败
```
NSString *pathPrevious = [self.audioPlayer.url relativeString];
pathPrevious = [pathPrevious stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
```

