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
#import "ZFSliderBar.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ZFVideoPlayer()

@property (nonatomic, strong, readwrite) AVPlayerLayer *playerLayer;
@property (nonatomic, strong, readwrite) AVPlayer *player;
@property (nonatomic, strong, readwrite) AVPlayerItem *playerItem;
@property (nonatomic, strong, readwrite) UIButton *playOrPauseBtn;

@property (nonatomic, strong, readwrite) UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic, strong, readwrite) UIView *bottomToolsView;
@property (nonatomic, strong, readwrite) ZFSliderBar *sliderBar;
@property (nonatomic, strong, readwrite) UILabel *totalDurationLabel;
@property (nonatomic, strong, readwrite) UILabel *currentTimeLabel;

@property (nonatomic, strong, readwrite) NSIndexPath *currentIndexPath;
@property (nonatomic, assign, readwrite) BOOL isSmallWindow;

@property (nonatomic, strong, readwrite) UIView *originSuperView;
@property (nonatomic, assign, readwrite) CGRect originFrame;
@property (nonatomic, strong, readwrite) UITableView *bindTableView;

@end

@implementation ZFVideoPlayer

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame: frame]) {
        
        self.originFrame = frame;
        
        [self addSubview: self.playOrPauseBtn];
        [self addSubview: self.activityIndicatorView];
        [self addSubview: self.bottomToolsView];
        [self addSubview: self.sliderBar];
        [self.bottomToolsView addSubview: self.totalDurationLabel];
        [self.bottomToolsView addSubview: self.currentTimeLabel];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBgView)];
        [self addGestureRecognizer: tapGesture];
        
        self.isSmallWindow = NO;
    }
    return self;
}

#pragma mark - Lazy loads
- (AVPlayerLayer *)playerLayer {
    if (!_playerLayer) {
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer: self.player];
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
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

- (UIView *)bottomToolsView {
    if (!_bottomToolsView) {
        _bottomToolsView = [[UIView alloc] init];
        _bottomToolsView.backgroundColor = [UIColor grayColor];
    }
    return _bottomToolsView;
}

- (ZFSliderBar *)sliderBar {
    if (!_sliderBar) {
        _sliderBar = [[ZFSliderBar alloc] init];
        
        __weak typeof(self) weakSelf = self;
        
        _sliderBar.valueDidChangedBlock = ^{
            float totalDuration = CMTimeGetSeconds([weakSelf.playerItem duration]);
            // 更改 时间标签
            weakSelf.currentTimeLabel.text = [weakSelf timeFormatted: weakSelf.sliderBar.value * totalDuration];
        };
        
        _sliderBar.valueChangeDidFinishedBlock = ^{
            float totalDuration = CMTimeGetSeconds([weakSelf.playerItem duration]);
            
            [weakSelf.player seekToTime:CMTimeMake(weakSelf.sliderBar.value * totalDuration, 1) completionHandler:^(BOOL finished) {
                NSLog(@"dragDotBlock");
                [weakSelf.player play];
            }];
        };
        
        _sliderBar.dragDotBlock = ^{
            [weakSelf.player pause];
        };
        
    }
    return _sliderBar;
}

- (UILabel *)totalDurationLabel {
    if (!_totalDurationLabel) {
        _totalDurationLabel = [[UILabel alloc] init];
        _totalDurationLabel.font = [UIFont systemFontOfSize: 14];
        _totalDurationLabel.text = @"00:00:00";
        _totalDurationLabel.textAlignment = NSTextAlignmentRight;
    }
    return _totalDurationLabel;
}

- (UILabel *)currentTimeLabel {
    if (!_currentTimeLabel) {
        _currentTimeLabel = [[UILabel alloc] init];
        _currentTimeLabel.font = [UIFont systemFontOfSize: 14];
        _currentTimeLabel.text = @"00:00:00";
        _totalDurationLabel.textAlignment = NSTextAlignmentRight;
    }
    return _currentTimeLabel;
}

- (AVPlayerItem *)getPlayerItem {
    NSAssert(self.videoUrl != nil, @"Url is nil");
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL: [NSURL URLWithString:[self.videoUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    self.playerItem = playerItem;
    return playerItem;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    
    self.originSuperView = self.superview;
    
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
        make.height.equalTo(@40);
    }];
    
    [self.totalDurationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.bottomToolsView).offset(-12);
        make.centerY.equalTo(self.bottomToolsView);
        make.width.equalTo(@65);
    }];
    
    [self.currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.bottomToolsView).offset(12);
        make.centerY.equalTo(self.bottomToolsView);
        make.width.equalTo(@65);
    }];
    
    [self.sliderBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.currentTimeLabel.mas_trailing).offset(1);
        make.trailing.equalTo(self.totalDurationLabel.mas_leading).offset(-1);
        make.top.equalTo(self.bottomToolsView);
        make.bottom.equalTo(self.bottomToolsView);
    }];
    
    [self bringSubviewToFront: self.playOrPauseBtn];
    [self bringSubviewToFront: self.activityIndicatorView];
    
    [self bringSubviewToFront: self.bottomToolsView];
    [self bringSubviewToFront: self.sliderBar];
    [self bringSubviewToFront: self.totalDurationLabel];
    [self bringSubviewToFront: self.currentTimeLabel];
}


#pragma mark - Override setter
- (void)setVideoUrl:(NSString *)videoUrl {
    _videoUrl = videoUrl;
    [self.layer addSublayer: self.playerLayer];
    
    [self clickPlayOrPauseBtn: self.playOrPauseBtn];
    self.playOrPauseBtn.hidden = YES;
    
    // 监听 当前播放的时间在哪
    [self addPeriodicTimeObserver];
    
    // 监听 播放状态
    [self.player addObserver: self forKeyPath:@"status" options: NSKeyValueObservingOptionNew context: nil];
    
    [self.activityIndicatorView startAnimating];
}

- (void)clickPlayOrPauseBtn: (UIButton *)btn {
    btn.selected = !btn.selected;
    [self playOrPause];
}

#pragma mark - Actions
- (void)tapBgView {
    NSLog(@"tapBgView");
    self.playOrPauseBtn.hidden = !self.playOrPauseBtn.hidden;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.playOrPauseBtn.hidden = !self.playOrPauseBtn.hidden;;
    });
}

#pragma mark - Public
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

#pragma - KVO
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

}


- (void)addPeriodicTimeObserver {
    
    __weak typeof(self) weakSelf = self;
    
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue: dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float totalDuration = CMTimeGetSeconds([weakSelf.playerItem duration]);
        float currentTime = CMTimeGetSeconds([weakSelf.playerItem currentTime]);
        weakSelf.totalDurationLabel.text = [weakSelf timeFormatted: totalDuration];
//        weakSelf.currentTimeLabel.text = [weakSelf timeFormatted: currentTime];
        
        float scale = currentTime / totalDuration;
        weakSelf.sliderBar.value = scale;
        if (scale == 1) {
            NSLog(@"播放完成");
        }
    }];
}

#pragma mark - timeFormat

- (NSString *)timeFormatted:(int)totalSeconds {
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
}

- (void)dealloc {
    [self.player removeObserver: self forKeyPath: @"status"];
}

#pragma mark - small window play
- (void)playWithBindTableView: (UITableView *)tableView currentIndexPath: (NSIndexPath *)currentIndexPath isSupportSmallWindow: (BOOL)isSupportSmallWindow {
    NSLog(@"%@", tableView);
    
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

@end
