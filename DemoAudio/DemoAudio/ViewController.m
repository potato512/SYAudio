//
//  ViewController.m
//  DemoAudio
//
//  Created by zhangshaoyu on 16/11/18.
//  Copyright © 2016年 zhangshaoyu. All rights reserved.
//

#import "ViewController.h"
#import "SYAudio.h"
#import "LocalViewController.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, SYAudioDelegate>

@property (nonatomic, strong) NSString *filePath;

@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) NSMutableArray *mainArray;

@property (nonatomic, assign) NSTimeInterval audioRecorderTime;          // 录音时长
@property (nonatomic, strong) UIView *imgView;                           // 录音音量图像父视图
@property (nonatomic, strong) UIImageView *audioRecorderVoiceImgView;    // 录音音量图像

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.navigationItem.title = @"录音及播放音频";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"local" style:UIBarButtonItemStyleDone target:self action:@selector(localItemClick:)];
    
    UIBarButtonItem *clearItem = [[UIBarButtonItem alloc] initWithTitle:@"clear" style:UIBarButtonItemStyleDone target:self action:@selector(clearItemClick:)];
    UIBarButtonItem *stopItem = [[UIBarButtonItem alloc] initWithTitle:@"stop" style:UIBarButtonItemStyleDone target:self action:@selector(stopItemClick:)];
    UIBarButtonItem *playItem = [[UIBarButtonItem alloc] initWithTitle:@"play" style:UIBarButtonItemStyleDone target:self action:@selector(playItemClick:)];
    self.navigationItem.rightBarButtonItems = @[clearItem, stopItem, playItem];
    
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
    self.mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 10.0 - 40.0 - 10.0) style:UITableViewStylePlain];
    [self.view addSubview:self.mainTableView];
    self.mainTableView.tableFooterView = [[UIView alloc] init];
    self.mainTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.mainTableView.backgroundColor = [UIColor clearColor];
    self.mainTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.mainTableView.separatorInset = UIEdgeInsetsZero;
    self.mainTableView.layoutMargins = UIEdgeInsetsZero;
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    //
    UIButton *headerButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 44.0)];
    [headerButton setTitle:@"开始录音" forState:UIControlStateNormal];
    [headerButton setTitle:@"停止录音" forState:UIControlStateSelected];
    [headerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [headerButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [headerButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    headerButton.selected = NO;
    self.mainTableView.tableHeaderView = headerButton;
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:button];
    button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    button.frame = CGRectMake(10.0, (CGRectGetHeight(self.view.bounds) - 10.0 - 40.0), (CGRectGetWidth(self.view.bounds) - 10.0 * 2), 40.0);
    button.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.3];
    [button setTitle:@"按下开始录音" forState:UIControlStateNormal];
    [button setTitle:@"正在录音 释放停止录音" forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    // 录音响应
    [button addTarget:self action:@selector(recordStartButtonDown:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(recordStopButtonUp:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(recordStopButtonExit:) forControlEvents:UIControlEventTouchDragExit];
}

#pragma mark - 交互 

- (void)localItemClick:(UIBarButtonItem *)item
{
    LocalViewController *nextVC = [[LocalViewController alloc] init];
    [self.navigationController pushViewController:nextVC animated:YES];
}

- (void)clearItemClick:(UIBarButtonItem *)item
{
    if (self.mainArray)
    {
        for (NSDictionary *dict in self.mainArray)
        {
            NSString *filePath = dict[@"FilePath"];
            [SYAudioFile SYAudioDeleteFileWithFilePath:filePath];
        }
        
        [self.mainArray removeAllObjects];
        
        [self.mainTableView reloadData];
    }
}

- (void)playItemClick:(UIBarButtonItem *)item
{
    [self playRecorder];
}

- (void)stopItemClick:(UIBarButtonItem *)item
{
    [self stopRecorder];
}

- (void)recordStartButtonDown:(UIButton *)button
{
    [SYAudio shareAudio].showRecorderVoice = YES;
    [self startRecorder];
}

- (void)recordStopButtonUp:(UIButton *)button
{
    [self saveRecorder];
}

- (void)recordStopButtonExit:(UIButton *)button
{
    [self saveRecorder];
}

- (void)buttonClick:(UIButton *)button
{
    button.selected = !button.selected;
    if (button.selected) {
        [SYAudio shareAudio].showRecorderVoice = NO;
        [self startRecorder];
    } else {
        [self saveRecorder];
    }
}

#pragma mark - 音频处理方法

// 开始录音
- (void)startRecorder
{
    self.filePath = [SYAudioFile SYAudioDefaultFilePath:nil];
    [SYAudio shareAudio].delegate = self;
    [[SYAudio shareAudio] audioRecorderStartWithFilePath:self.filePath];
}

// 停止录音，并保存
- (void)saveRecorder
{
    [[SYAudio shareAudio] audioRecorderStop];
    
    // 保存音频信息
    if (!self.mainArray)
    {
        self.mainArray = [[NSMutableArray alloc] init];
    }
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:self.filePath forKey:@"FilePath"];
    NSString *fileName = [SYAudioFile SYAudioGetFileNameWithFilePath:self.filePath type:YES];
    [dict setValue:fileName forKey:@"FileName"];
    long long fileSize = [SYAudioFile SYAudioGetFileSizeWithFilePath:self.filePath];
    [dict setValue:@(fileSize) forKey:@"FileSize"];
    NSTimeInterval fileTime = [[SYAudio shareAudio] durationAudioRecorderWithFilePath:self.filePath];
    [dict setValue:@(fileTime) forKey:@"FileTime"];
    [self.mainArray addObject:dict];
    
    // 刷新列表
    [self.mainTableView reloadData];
}

// 录音开始播放，或停止
- (void)playRecorder
{
    [[SYAudio shareAudio] audioPlayWithFilePath:self.filePath];
}

// 录音停止播放
- (void)stopRecorder
{
    [[SYAudio shareAudio] audioStop];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.mainArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const identifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        
        cell.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
        cell.layoutMargins = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.textColor = [UIColor orangeColor];
        
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    NSDictionary *dict = self.mainArray[indexPath.row];
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
    
    NSDictionary *dict = self.mainArray[indexPath.row];
    NSString *filePath = dict[@"FilePath"];
    
    [[SYAudio shareAudio] audioPlayWithFilePath:filePath];
}


#pragma mark - 代理

- (void)recordBegined
{
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

- (void)recordFinshed
{
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
}

- (void)recordingUpdateVoice:(double)lowPassResults
{
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

@end
