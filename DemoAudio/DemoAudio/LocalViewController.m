//
//  LocalViewController.m
//  DemoAudio
//
//  Created by zhangshaoyu on 16/11/21.
//  Copyright © 2016年 zhangshaoyu. All rights reserved.
//

#import "LocalViewController.h"
#import "SYAudio.h"

@interface LocalViewController ()

@end

@implementation LocalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"播放音乐";
 
    UIBarButtonItem *stopItem = [[UIBarButtonItem alloc] initWithTitle:@"stop" style:UIBarButtonItemStyleDone target:self action:@selector(stopItemClick:)];
    UIBarButtonItem *playItem = [[UIBarButtonItem alloc] initWithTitle:@"play" style:UIBarButtonItemStyleDone target:self action:@selector(playItemClick:)];
    self.navigationItem.rightBarButtonItems = @[stopItem, playItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)playItemClick:(UIBarButtonItem *)item
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"BestRegards" ofType:@"mp3"];
    [[SYAudio shareAudio] audioPlayWithFilePath:filePath];
}

- (void)stopItemClick:(UIBarButtonItem *)item
{
    [[SYAudio shareAudio] audioStop];
}

@end
