//
//  ViewController.m
//  DemoAudio
//
//  Created by zhangshaoyu on 16/11/18.
//  Copyright © 2016年 zhangshaoyu. All rights reserved.
//

#import "ViewController.h"
#import "SYAudio.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, SYAudioDelegate>

@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSString *filePathMP3;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *array;

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIView *buttonView;

@property (nonatomic, assign) BOOL isLimitTime;
@property (nonatomic, strong) UIView *imgView;                           // 录音音量图像父视图
@property (nonatomic, strong) UIImageView *audioRecorderVoiceImgView;    // 录音音量图像

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.navigationItem.title = @"录音及播放音频";
    
    [self setUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
}

#pragma mark - 视图

- (void)setUI
{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.layoutMargins = UIEdgeInsetsZero;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //
    self.buttonView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, (60.0 + 10.0 + 44.0 + 10.0 + 44.0 + 10.0 + 44.0 + 10.0 + 44.0 + 10.0))];
    self.buttonView.backgroundColor = [UIColor yellowColor];
    //
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, (self.view.frame.size.width - 20.0), 60.0)];
    [self.buttonView addSubview:self.label];
    self.label.adjustsFontSizeToFitWidth = YES;
    self.label.numberOfLines = 2;
    UIView *currentView = self.label;
    //
    NSArray *titles = @[@"播放本地文件", @"播放网络文件", @"播放压缩文件", @"停止播放"];
    NSInteger number = 4;
    CGFloat widthButton = ((self.buttonView.frame.size.width - 10.0 * 5) / number);
    for (int i = 0; i < titles.count; i++) {
        NSString *title = titles[i];
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((i * (widthButton + 10.0) + 10.0), (60.0 + 10.0), widthButton, 44.0)];
        button.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.3];
        button.titleLabel.adjustsFontSizeToFitWidth = YES;
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i;
        [self.buttonView addSubview:button];
        
        currentView = button;
    }
    //
    UIButton *headerButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0, (currentView.frame.origin.y + currentView.frame.size.height + 10.0), (self.view.frame.size.width - 20.0), 44.0)];
    [self.buttonView addSubview:headerButton];
    headerButton.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.3];
    [headerButton setTitle:@"开始录音（不显示录音音量）" forState:UIControlStateNormal];
    [headerButton setTitle:@"停止录音（不显示录音音量）" forState:UIControlStateSelected];
    [headerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [headerButton setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    [headerButton addTarget:self action:@selector(hideButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    headerButton.selected = NO;
    currentView = headerButton;
    //
    UIButton *timeButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0, (currentView.frame.origin.y + currentView.frame.size.height + 10.0), (self.view.frame.size.width - 20.0), 44.0)];
    timeButton.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.3];
    [timeButton setTitle:@"开始录音（限时录音）" forState:UIControlStateNormal];
    [timeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [timeButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [timeButton addTarget:self action:@selector(timeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    timeButton.selected = NO;
    [self.buttonView addSubview:timeButton];
    currentView = timeButton;
    //
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10.0, (currentView.frame.origin.y + currentView.frame.size.height + 10.0), (self.view.frame.size.width - 20.0), 44.0)];
    [self.buttonView addSubview:button];
    button.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.3];
    [button setTitle:@"按下开始录音" forState:UIControlStateNormal];
    [button setTitle:@"正在录音 释放停止录音" forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    // 录音响应
    [button addTarget:self action:@selector(recordStartButtonDown:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(recordStopButtonUp:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(recordStopButtonExit:) forControlEvents:UIControlEventTouchDragExit];
    //
    self.tableView.tableFooterView = self.buttonView;
}

#pragma mark - 交互 

// 播放操作
- (void)buttonClick:(UIButton *)button
{
    if (button.tag == 0) {
        // 播放本地文件
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"BestRegards" ofType:@"mp3"];
        [SYAudio shareAudio].audioPlayer.delegate = self;
        [[SYAudio shareAudio].audioPlayer playerStart:filePath complete:^(BOOL isFailed) {
            if (isFailed) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"音频文件地址无效" preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                    [self dismissViewControllerAnimated:YES completion:NULL];
                }]];
                [self presentViewController:alert animated:YES completion:NULL];
            }
        }];
    } else if (button.tag == 1) {
        // 播放网络文件
        // NSString *filePath = @"http://www.runoob.com/try/demo_source/horse.mp3";
        NSString *filePath = @"http://download.lingyongqian.cn//music//ForElise.mp3";
        [SYAudio shareAudio].audioPlayer.delegate = self;
        [[SYAudio shareAudio].audioPlayer playerStart:filePath complete:^(BOOL isFailed) {
            if (isFailed) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"音频文件地址无效" preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                    [self dismissViewControllerAnimated:YES completion:NULL];
                }]];
                [self presentViewController:alert animated:YES completion:NULL];
            }
        }];
    } else if (button.tag == 2) {
        // 播放压缩文件
        [SYAudio shareAudio].audioPlayer.delegate = self;
        [[SYAudio shareAudio].audioPlayer playerStart:self.filePathMP3 complete:^(BOOL isFailed) {
            if (isFailed) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"音频文件地址无效" preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                    [self dismissViewControllerAnimated:YES completion:NULL];
                }]];
                [self presentViewController:alert animated:YES completion:NULL];
            }
        }];
    } else if (button.tag == 3) {
        // 停止播放
        [[SYAudio shareAudio].audioPlayer playerPause];
    }
}

// 录音时不监测音量
- (void)hideButtonClick:(UIButton *)button
{
    button.selected = !button.selected;
    if (button.selected) {
        [SYAudio shareAudio].audioRecorder.monitorVoice = NO;
        self.filePath = [SYAudioFile SYAudioDefaultFilePath:nil];
        [SYAudio shareAudio].audioRecorder.delegate = self;
        [[SYAudio shareAudio].audioRecorder recorderStart:self.filePath complete:^(BOOL isFailed) {
            if (isFailed) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"音频文件地址无效" preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                    [self dismissViewControllerAnimated:YES completion:NULL];
                }]];
                [self presentViewController:alert animated:YES completion:NULL];
            }
        }];
    } else {
        [self saveRecorder];
    }
}

// 录音时限制时长
- (void)timeButtonClick:(UIButton *)button
{
    self.isLimitTime = YES;
    
    self.filePath = [SYAudioFile SYAudioDefaultFilePath:nil];
    [SYAudio shareAudio].audioRecorder.delegate = self;
    [SYAudio shareAudio].audioRecorder.totalTime = 10.0;
    [[SYAudio shareAudio].audioRecorder recorderStart:self.filePath complete:^(BOOL isFailed) {
        if (isFailed) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"音频文件地址无效" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                [self dismissViewControllerAnimated:YES completion:NULL];
            }]];
            [self presentViewController:alert animated:YES completion:NULL];
        }
    }];
}

// 录音时监测音量
- (void)recordStartButtonDown:(UIButton *)button
{
    [SYAudio shareAudio].audioRecorder.monitorVoice = YES;
    self.filePath = [SYAudioFile SYAudioDefaultFilePath:nil];
    [SYAudio shareAudio].audioRecorder.delegate = self;
    [[SYAudio shareAudio].audioRecorder recorderStart:self.filePath complete:^(BOOL isFailed) {
        if (isFailed) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"音频文件地址无效" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                [self dismissViewControllerAnimated:YES completion:NULL];
            }]];
            [self presentViewController:alert animated:YES completion:NULL];
        }
    }];
}

- (void)recordStopButtonUp:(UIButton *)button
{
    [self saveRecorder];
}

- (void)recordStopButtonExit:(UIButton *)button
{
    [self saveRecorder];
}

// 停止录音，并保存
- (void)saveRecorder
{
    [[SYAudio shareAudio].audioRecorder recorderStop];
    
    // 保存音频信息
    if (!self.array)
    {
        self.array = [[NSMutableArray alloc] init];
    }
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:self.filePath forKey:@"FilePath"];
    NSString *fileName = [SYAudioFile SYAudioGetFileNameWithFilePath:self.filePath type:YES];
    [dict setValue:fileName forKey:@"FileName"];
    long long fileSize = [SYAudioFile SYAudioGetFileSizeWithFilePath:self.filePath];
    [dict setValue:@(fileSize) forKey:@"FileSize"];
    NSTimeInterval fileTime = [[SYAudio shareAudio].audioRecorder recorderDurationWithFilePath:self.filePath];
    [dict setValue:@(fileTime) forKey:@"FileTime"];
    [self.array addObject:dict];
    
    // 刷新列表
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const identifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        
        cell.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
        cell.layoutMargins = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.textColor = [UIColor orangeColor];
        
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    NSDictionary *dict = self.array[indexPath.row];
    NSString *fileName = dict[@"FileName"];
    NSNumber *fileSize = dict[@"FileSize"];
    NSNumber *fileTime = dict[@"FileTime"];
    NSString *filePath = dict[@"FilePath"];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@(size=%@Byte duration=%.2fs)", fileName, fileSize, fileTime.doubleValue];
    cell.detailTextLabel.text = filePath;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dict = self.array[indexPath.row];
    NSString *filePath = dict[@"FilePath"];
    //
    [SYAudio shareAudio].audioPlayer.delegate = self;
    [[SYAudio shareAudio].audioPlayer playerStart:filePath complete:^(BOOL isFailed) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"音频文件地址无效" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [self dismissViewControllerAnimated:YES completion:NULL];
        }]];
        [self presentViewController:alert animated:YES completion:NULL];
    }];
}


#pragma mark - 代理

#pragma mark 录音

/// 开始录音
- (void)recordBegined
{
    NSLog(@"%s", __func__);
    self.label.text = @"开始录音";
    
    if ([SYAudio shareAudio].audioRecorder.monitorVoice) {
        // 录音音量显示 75*111
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        //
        self.imgView = [[UIView alloc] initWithFrame:CGRectMake((window.frame.size.width - 120) / 2, (window.frame.size.height - 120) / 2, 120, 120)];
        [window addSubview:self.imgView];
        [self.imgView.layer setCornerRadius:10.0];
        [self.imgView.layer setBackgroundColor:[UIColor blackColor].CGColor];
        [self.imgView setAlpha:0.8];
        //
        self.audioRecorderVoiceImgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.imgView.frame.size.width - 60) / 2, (self.imgView.frame.size.height - 60 * 111 / 75) / 2, 60, 60 * 111 / 75)];
        [self.imgView addSubview:self.audioRecorderVoiceImgView];
        [self.audioRecorderVoiceImgView setImage:[UIImage imageNamed:@"record_animate_01.png"]];
        [self.audioRecorderVoiceImgView setBackgroundColor:[UIColor clearColor]];
    }
}

/// 停止录音
- (void)recordFinshed
{
    NSLog(@"%s", __func__);
    self.label.text = @"完成录音";
    if (self.isLimitTime) {
        self.isLimitTime = NO;
        [self saveRecorder];
    }
    
    // 移除音量图标
    if (self.audioRecorderVoiceImgView && [SYAudio shareAudio].audioRecorder.monitorVoice)
    {
        [self.audioRecorderVoiceImgView setHidden:YES];
        [self.audioRecorderVoiceImgView setImage:nil];
        [self.audioRecorderVoiceImgView removeFromSuperview];
        self.audioRecorderVoiceImgView = nil;
        
        [self.imgView removeFromSuperview];
        self.imgView = nil;
    }
}

/// 正在录音中，录音音量监测
- (void)recordingUpdateVoice:(double)lowPassResults
{
    NSLog(@"%s", __func__);
    self.label.text = [NSString stringWithFormat:@"正在录音：%f", lowPassResults];
    
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

/// 正中录音中，是否录音倒计时、录音剩余时长
- (void)recordingWithResidualTime:(NSTimeInterval)time timer:(BOOL)isTimer
{
    NSLog(@"%s", __func__);
    NSLog(@"录音倒计时：%f, 是否录音倒计时：%ld", time, isTimer);
    self.label.text = [NSString stringWithFormat:@"录音倒计时：%f, 是否录音倒计时：%ld", time, isTimer];
}

#pragma mark 压缩

/// 开始压缩录音
- (void)recordBeginConvert
{
    NSLog(@"%s", __func__);
    self.label.text = @"正在压缩文件";
}

/// 结束压缩录音
- (void)recordFinshConvert:(NSString *)filePath
{
    NSLog(@"%s", __func__);
    NSLog(@"%@", filePath);
    self.filePathMP3 = filePath;
    self.label.text = @"完成文件压缩";
}

#pragma mark 播放

/// 开始播放音频
- (void)audioPlayBegined:(AVPlayerItemStatus)state
{
    NSLog(@"%s", __func__);
    NSLog(@"state = %@", @(state));
    self.label.text = [NSString stringWithFormat:@"准备播放 state = %@", @(state)];
}

/// 正在播放音频（总时长，当前时长）
- (void)audioPlaying:(NSTimeInterval)totalTime time:(NSTimeInterval)currentTime
{
    NSLog(@"%s", __func__);
    NSLog(@"播放总时长：%f, 当前播放时间：%f", totalTime, currentTime);
    self.label.text = [NSString stringWithFormat:@"正在播放\n播放总时长：%f, 当前播放时间：%f", totalTime, currentTime];
}

/// 结束播放音频
- (void)audioPlayFinished
{
    NSLog(@"%s", __func__);
    self.label.text = [NSString stringWithFormat:@"播放完成"];
}


@end
