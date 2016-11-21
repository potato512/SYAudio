# SYAudio
使用AVAudioRecorder进行录音
使用AVAudioPlayer进行音频播放

#注意：
 * 添加AVFoundation.framework、AudioToolbox.framework
 * 音频处理包括：开始录音、停止录音、播放音频、停止音频播放
 * 音频处理是通过按钮进行交互，通常采用三种状态交互方式
  * 1 UIControlEventTouchDown状态时，开始录音
  * 2 UIControlEventTouchUpInside状态时，停止录音，并进行类似音频文件存储的操作
  * 3 UIControlEventTouchDragExit状态时，与UIControlEventTouchUpInside状态进行相同的操作

~~~ javascript

// 导入头文件
#import "SYAudio.h"

~~~ 

~~~ javascript

// 音频处理方法-开始录音        
NSString *filePath = xxxxx;
[[SYAudio shareAudio] audioRecorderStartWithFilePath:filePath];

~~~

~~~ javascript

// 音频处理方法-停止录音        
[[SYAudio shareAudio] audioRecorderStop];

~~~

~~~ javascript

// 音频处理方法-播放录音  
NSString *filePath = xxxxx;
[[SYAudio shareAudio] audioPlayWithFilePath:filePath];

~~~

~~~ javascript

// 音频处理方法-停止录音播放        
[[SYAudio shareAudio] audioStop];

~~~

