//
//  ViewController.m
//  ZFVideoPlayer
//
//  Created by zhaofei on 2017/3/3.
//  Copyright © 2017年 zbull. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "VideoModel.h"
#import "VideoCell.h"
#import "ZFVideoPlayer.h"

#define videoListUrl @"http://c.3g.163.com/nc/video/list/VAP4BFR16/y/0-10.html"
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height


@interface ViewController () <UITableViewDataSource, UITabBarDelegate, VideoCellDelegate, UIScrollViewDelegate>

@property (nonatomic, strong, readwrite) UITableView *tableView;
@property (nonatomic, strong, readwrite) NSArray *data;
@property (nonatomic, strong, readwrite) ZFVideoPlayer *videoPlayer;
@property (nonatomic, strong, readwrite) NSIndexPath *currentPlayIndexPath;
@end

@implementation ViewController

#pragma mark - Lazy loads
- (ZFVideoPlayer *)videoPlayer {
    if (!_videoPlayer) {
        _videoPlayer = [[ZFVideoPlayer alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 200)];
        _videoPlayer.backgroundColor = [UIColor blackColor];
    }
    return _videoPlayer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.tableView = [[UITableView alloc] initWithFrame: self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.rowHeight = 280;
    
    [self.view addSubview: self.tableView];
    
    [self fetchData];
}

- (void)fetchData {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString: videoListUrl]];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest: request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error: %@", error);
            return;
        }
//        NSLog(@"data: %@", data);
        // serializer data
        NSDictionary *serializerData = [NSJSONSerialization JSONObjectWithData: data options:NSJSONReadingMutableContainers error:nil];
//        NSLog(@"serializerData: %@", serializerData);
        NSMutableArray *modelArray = [[NSMutableArray alloc] init];
        NSArray *array = [serializerData objectForKey:@"VAP4BFR16"];
        for (NSDictionary *obj in array) {
            VideoModel *model = [VideoModel modelWithDictionary: obj];
            [modelArray addObject: model];
        }
        self.data = modelArray;
        NSLog(@"modelArray: %@", modelArray);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
    
    [task resume];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // create table cell logic, inject data
    VideoCell *cell = [VideoCell videoCellWithTableView: tableView];
    cell.delegate = self;
    cell.videoModel = self.data[indexPath.row];
    return cell;
}

#pragma mark - Video cell delegate
- (void)videoCellDidClickPlayOrPauseBtn:(VideoCell *)videoCell {
    
    if (_videoPlayer) {
        [_videoPlayer destroyVideoPlayer];
        _videoPlayer = nil;
    }
    self.currentPlayIndexPath = [self.tableView indexPathForCell: videoCell];
    self.videoPlayer.frame = videoCell.coverView.bounds;
    [videoCell.contentView addSubview: self.videoPlayer];
    self.videoPlayer.videoUrl = [videoCell.videoModel mp4_url];
}

#pragma mark - 监听scroll view 的 滚动 实现自动小屏播放 和 恢复 到原来的位置
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_videoPlayer) {
        [_videoPlayer playWithBindTableView: self.tableView currentIndexPath: self.currentPlayIndexPath isSupportSmallWindow: YES];
    }
}
@end
