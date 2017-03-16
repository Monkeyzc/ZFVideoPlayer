//
//  ZFVideoPlayer.m
//  ZFVideoPlayer
//
//  Created by zhaofei on 2017/3/3.
//  Copyright © 2017年 zbull. All rights reserved.
//

#import "ZFVideoPlayer.h"
#import "VideoModel.h"
#import <AVFoundation/AVFoundation.h>
#import "Masonry.h"
#import "ZFVideoPlayerBottomToolsView.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define PlayOrPauseBtnSize 60

@interface ZFVideoPlayer()

@property (nonatomic, strong, readwrite) AVPlayerLayer *playerLayer;
@property (nonatomic, strong, readwrite) AVPlayer *player;
@property (nonatomic, strong, readwrite) AVPlayerItem *playerItem;
@property (nonatomic, strong, readwrite) UIButton *playOrPauseBtn;

@property (nonatomic, strong, readwrite) UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic, strong, readwrite) ZFVideoPlayerBottomToolsView *bottomToolsView;

@property (nonatomic, strong, readwrite) NSIndexPath *currentIndexPath;
@property (nonatomic, assign, readwrite) BOOL isSmallWindow;

@property (nonatomic, strong, readwrite) UIView *originSuperView;
@property (nonatomic, assign, readwrite) CGRect originFrame;
@property (nonatomic, strong, readwrite) UITableView *bindTableView;

@property (nonatomic, assign, readwrite) BOOL isZoom;
@property (nonatomic, assign, readwrite) BOOL isOriginFrame;


@end

@implementation ZFVideoPlayer

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame: frame]) {
        
        self.originFrame = frame;
        self.isZoom = NO;
        self.isOriginFrame = NO;
        
        [self addSubview: self.playOrPauseBtn];
        [self addSubview: self.activityIndicatorView];
        [self addSubview: self.bottomToolsView];

        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBgView)];
        [self addGestureRecognizer: tapGesture];
        
        self.isSmallWindow = NO;
    }
    return self;
}

#pragma mark --- Lazy loads ---
- (AVPlayerLayer *)playerLayer {
    if (!_playerLayer) {
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer: self.player];
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _playerLayer;
}

- (AVPlayer *)player {
    if (!_player) {
        _player = [AVPlayer playerWithPlayerItem: [self getPlayerItem]];
    }
    return _player;
}

- (UIButton *)playOrPauseBtn {
    if (!_playOrPauseBtn) {
        _playOrPauseBtn = [[UIButton alloc] init];
        [_playOrPauseBtn setImage: [UIImage imageNamed:@"play"] forState: UIControlStateNormal];
        [_playOrPauseBtn setImage: [UIImage imageNamed:@"pause"] forState: UIControlStateSelected];
        [_playOrPauseBtn addTarget: self action: @selector(clickPlayOrPauseBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playOrPauseBtn;
}

- (UIActivityIndicatorView *)activityIndicatorView {
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite];
    }
    return _activityIndicatorView;
}

- (ZFVideoPlayerBottomToolsView *)bottomToolsView {
    if (!_bottomToolsView) {
        _bottomToolsView = [[ZFVideoPlayerBottomToolsView alloc] init];
        _bottomToolsView.backgroundColor = [UIColor grayColor];
        
        __weak typeof(self) weakSelf = self;

        _bottomToolsView.sliderBar.valueDidChangedBlock = ^{
            float totalDuration = CMTimeGetSeconds([weakSelf.playerItem duration]);
            // 更改 时间标签
            weakSelf.bottomToolsView.currentTimeLabel.text = [weakSelf timeFormatted: weakSelf.bottomToolsView.sliderBar.value * totalDuration];
        };

        _bottomToolsView.sliderBar.valueChangeDidFinishedBlock = ^{
            float totalDuration = CMTimeGetSeconds([weakSelf.playerItem duration]);

            [weakSelf.player seekToTime:CMTimeMake(weakSelf.bottomToolsView.sliderBar.value * totalDuration, 1) completionHandler:^(BOOL finished) {
                NSLog(@"dragDotBlock");
                [weakSelf.player play];
            }];
        };
        
        _bottomToolsView.sliderBar.dragDotBlock = ^{
            [weakSelf.player pause];
        };
        
        _bottomToolsView.zoomBlock = ^{
            NSLog(@"全屏播放");
            [weakSelf zoomPlayer];
        };
    }
    return _bottomToolsView;
}

#pragma mark --- Private ---
- (AVPlayerItem *)getPlayerItem {
    NSAssert(self.videoUrl != nil, @"Url is nil");
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL: [NSURL URLWithString:[self.videoUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    self.playerItem = playerItem;
    return playerItem;
}

- (NSString *)timeFormatted:(int)totalSeconds {
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
}


#pragma mark --- layout subviews ---
- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!self.isOriginFrame) {
        self.originSuperView = self.superview;
        self.isOriginFrame = YES;
    }
    
    self.playerLayer.frame = self.bounds;
    
    [self.playOrPauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.equalTo(@60);
        make.height.equalTo(@60);
    }];
    
    [self.activityIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.equalTo(@(self.activityIndicatorView.frame.size.width));
        make.height.equalTo(@(self.activityIndicatorView.frame.size.height));
    }];
    
    [self.bottomToolsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self);
        make.trailing.equalTo(self);
        make.bottom.equalTo(self);
        make.height.equalTo(@32);
    }];

    [self bringSubviewToFront: self.playOrPauseBtn];
    [self bringSubviewToFront: self.activityIndicatorView];
    [self bringSubviewToFront: self.bottomToolsView];
}


#pragma mark --- Override setter ---
- (void)setVideoUrl:(NSString *)videoUrl {
    _videoUrl = videoUrl;
    [self.layer addSublayer: self.playerLayer];
    
    [self clickPlayOrPauseBtn: self.playOrPauseBtn];
    
    //隐藏播放按钮 和 底部工具条
    self.playOrPauseBtn.hidden = YES;
    self.bottomToolsView.hidden = YES;
    
    // 监听 当前播放的时间在哪
    [self addPeriodicTimeObserver];
    
    // 监听 播放状态
    [self.player addObserver: self forKeyPath:@"status" options: NSKeyValueObservingOptionNew context: nil];
    // 监听 缓冲
    [self.playerItem addObserver: self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    [self.activityIndicatorView startAnimating];
}

#pragma mark --- Actions ---

- (void)clickPlayOrPauseBtn: (UIButton *)btn {
    btn.selected = !btn.selected;
    [self playOrPause];
}

- (void)tapBgView {
    self.playOrPauseBtn.hidden = !self.playOrPauseBtn.hidden;
    self.bottomToolsView.hidden = !self.bottomToolsView.hidden;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.playOrPauseBtn.hidden = !self.playOrPauseBtn.hidden;;
        self.bottomToolsView.hidden = !self.bottomToolsView.hidden;
    });
}

- (void)zoomPlayer {
    if (!self.isZoom) {
        [[UIDevice currentDevice] setValue: [NSNumber numberWithInt: UIInterfaceOrientationLandscapeLeft] forKey:@"orientation"];
        [self updateConstraintsIfNeeded];
        [[UIApplication sharedApplication].keyWindow addSubview: self];
        [UIView animateWithDuration:0.3 animations:^{
            self.frame = [UIApplication sharedApplication].keyWindow.bounds;
        }];
    } else {
        [[UIDevice currentDevice] setValue: [NSNumber numberWithInt: UIDeviceOrientationPortrait] forKey:@"orientation"];
        [self updateConstraintsIfNeeded];
        
        [self.originSuperView addSubview: self];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.frame = self.originFrame;
        }];
    }
    self.isZoom = !self.isZoom;
}

#pragma mark --- Public ---
- (void)playOrPause {
    if (self.player.rate == 0) { // Pause
        [self.player play];
    } else if (self.player.rate == 1) { //Playing
        [self.player pause];
    }
}

- (void)destroyVideoPlayer {
    NSLog(@"destroyVideoPlayer");
    [self.player pause];
    [self.playerLayer removeFromSuperlayer];
    [self removeFromSuperview];
}

#pragma mark --- KVO ---
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"status"]) {
        NSInteger playerStatus = [[change objectForKey: NSKeyValueChangeNewKey] integerValue];
        
        switch (playerStatus) {
            case AVPlayerStatusUnknown:
                break;
            case AVPlayerStatusReadyToPlay:
                [self.activityIndicatorView stopAnimating];
                break;
            case AVPlayerStatusFailed: {
                NSLog(@"AVPlayerStatusFailed");
            }
                break;
            default:
                break;
        }
    }
    
    // 已加载的数据
    if ([keyPath isEqualToString: @"loadedTimeRanges"]) {
        CMTimeRange loadedTimeRange = [[self.playerItem.loadedTimeRanges firstObject] CMTimeRangeValue];
        
        NSLog(@"totalDuration: %f", CMTimeGetSeconds(self.playerItem.duration));
        
        NSLog(@"+++++++++++++");
        NSLog(@"start: %f", CMTimeGetSeconds(loadedTimeRange.start));
        NSLog(@"duration: %f", CMTimeGetSeconds(loadedTimeRange.duration));
        NSLog(@"==========");
        
        float totalBuffer = CMTimeGetSeconds(loadedTimeRange.start) + CMTimeGetSeconds(loadedTimeRange.duration);
        self.bottomToolsView.sliderBar.cachevalue = totalBuffer / CMTimeGetSeconds(self.playerItem.duration);
    }
}


- (void)addPeriodicTimeObserver {
    
    __weak typeof(self) weakSelf = self;
    
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue: dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        float totalDuration = CMTimeGetSeconds([weakSelf.playerItem duration]);
        if (isnan(totalDuration)) {
            return ;
        }

        float currentTime = CMTimeGetSeconds([weakSelf.playerItem currentTime]);
        weakSelf.bottomToolsView.totalDurationLabel.text = [weakSelf timeFormatted: totalDuration];
        
        float scale = currentTime / totalDuration;
        weakSelf.bottomToolsView.sliderBar.value = scale;
        if (scale == 1) {
            NSLog(@"播放完成");
            
            weakSelf.playOrPauseBtn.selected = NO;
            weakSelf.playOrPauseBtn.hidden = NO;
            weakSelf.bottomToolsView.hidden = NO;
            CMTime currentCMTime = CMTimeMake(0, 1);
            [weakSelf.player seekToTime:currentCMTime completionHandler:^(BOOL finished) {
                weakSelf.bottomToolsView.sliderBar.value = 0.0f;
            }];
        }
    }];
}

#pragma mark - small window play
- (void)playWithBindTableView: (UITableView *)tableView currentIndexPath: (NSIndexPath *)currentIndexPath isSupportSmallWindow: (BOOL)isSupportSmallWindow {
    
    CGFloat tableViewContentOffsetY = tableView.contentOffset.y;
    
    self.currentIndexPath = currentIndexPath;
    self.bindTableView = tableView;
    
    
    CGRect currentPlayCellRect = [tableView rectForRowAtIndexPath:currentIndexPath];
    
    CGFloat cellHeight = currentPlayCellRect.size.height;
    
    CGFloat cellTop = currentPlayCellRect.origin.y;
    CGFloat cellBottom = cellTop + cellHeight;
    
    
    // 离开屏幕, 展示小屏幕
    if (tableViewContentOffsetY > cellBottom) {
        NSLog(@"向上滑动, 离开屏幕");
        [self playWithSmallWindow];
        return;
    }

    if (cellTop > tableViewContentOffsetY + tableView.frame.size.height) {
        NSLog(@"向下滑动, 离开屏幕");
        [self playWithSmallWindow];
        return;
    }
    
    
    // 向下滑动, 回到屏幕
    if (tableViewContentOffsetY < cellBottom) {
        NSLog(@"向下滑动, 回到屏幕");
        [self playWithOriginFrame];
        return;
    }

    if (cellTop < tableViewContentOffsetY + tableView.frame.size.height) {
        NSLog(@"向上滑动, 回到屏幕");
        [self playWithOriginFrame];
        return;
    }
    
}

- (void)playWithSmallWindow {
    
    if ([self.superview isKindOfClass:[UIWindow class]]) {
        return;
    }
    
    // 隐藏底部工具条
    self.bottomToolsView.hidden = YES;
    
    UIWindow *keyWindow =  [UIApplication sharedApplication].keyWindow;
    
    // 坐标转换
    CGRect tableViewFrame = [self.bindTableView convertRect:self.bindTableView.bounds toView: keyWindow];
    self.frame = [self convertRect:self.frame toView: keyWindow];
    [keyWindow addSubview: self];

    [UIView animateWithDuration:0.3 animations:^{
        CGFloat width = self.originFrame.size.width * 0.5;
        CGFloat height = self.originFrame.size.height * 0.5;
        
        CGRect smallFrame = CGRectMake(tableViewFrame.origin.x + tableViewFrame.size.width  - width, tableViewFrame.origin.y + tableViewFrame.size.height - height, width, height);
        self.frame = smallFrame;
        self.playerLayer.frame = self.bounds;
    }];
}

- (void)playWithOriginFrame {
    if (![self.superview isKindOfClass:[UIWindow class]]) {
        return;
    }
    
    // 隐藏底部工具条
    self.bottomToolsView.hidden = NO;
    
    UITableViewCell *cell = [self.bindTableView cellForRowAtIndexPath: self.currentIndexPath];
    CGRect cellFrame =  cell.frame;
    
    [UIView animateWithDuration: 0.3 animations:^{
        
        // 先移动到 所属 cell 的位置
        self.frame = CGRectMake(cellFrame.origin.x, cellFrame.origin.y, self.originFrame.size.width, self.originFrame.size.height);
        self.playerLayer.frame = self.bounds;
        
        NSLog(@"回到原始位置: %@", NSStringFromCGRect(self.frame));
    } completion:^(BOOL finished) {
        
        // 回到原来的位子
        self.frame = self.originFrame;
        
        // 添加到原来的cell上
        [cell.contentView addSubview:self];
    }];
}

- (void)dealloc {
    [self.player removeObserver: self forKeyPath: @"status"];
    [self.playerItem removeObserver: self forKeyPath: @"loadedTimeRanges"];
}

@end
