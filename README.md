# SYAudio
音频的录制与播放，进行封装后的单例工具组件。
* 使用AVAudioRecorder进行录音
* 使用AVAudioPlayer进行音频播放

# 效果图
![audioImage.gif](./audioImage.gif)


>
> 注意：
>
> 1 添加AVFoundation.framework、AudioToolbox.framework
>
> 2 音频处理包括：开始录音、停止录音、播放音频、停止音频播放
>
> 3 音频处理是通过按钮进行交互，通常采用三种状态交互方式
>
> (1) UIControlEventTouchDown状态时，开始录音
>
> (2) UIControlEventTouchUpInside状态时，停止录音，并进行类似音频文件存储的操作
>
> (3) UIControlEventTouchDragExit状态时，与UIControlEventTouchUpInside状态进行相同的操作
> 
> 4 注意隐私设置，添加启用录音功能
> 设置方法：https://blog.csdn.net/potato512/article/details/52595649


# 使用示例
```
// 导入头文件
#import "SYAudio.h"
```

```
// 音量图标显示
[SYAudio shareAudio].showRecorderVoiceStatus = YES;
// 音量图标不显示
[SYAudio shareAudio].showRecorderVoiceStatus = NO;
```

```
// 音频处理方法-开始录音        
NSString *filePath = xxxxx;
[[SYAudio shareAudio] audioRecorderStartWithFilePath:filePath];
```

```
// 音频处理方法-停止录音        
[[SYAudio shareAudio] audioRecorderStop];
```

```
// 音频处理方法-播放录音  
NSString *filePath = xxxxx;
[[SYAudio shareAudio] audioPlayWithFilePath:filePath];
```

```
// 音频处理方法-停止录音播放        
[[SYAudio shareAudio] audioStop];
```



# 修改完善
* 20180804
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

