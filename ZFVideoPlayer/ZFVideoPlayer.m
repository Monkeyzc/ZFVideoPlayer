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

@interface ZFVideoPlayer()

@property (nonatomic, strong, readwrite) AVPlayerLayer *playerLayer;
@property (nonatomic, strong, readwrite) AVPlayer *player;
@property (nonatomic, strong, readwrite) AVPlayerItem *playerItem;
@property (nonatomic, strong, readwrite) UIButton *playOrPauseBtn;

@property (nonatomic, strong, readwrite) UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic, strong, readwrite) UIView *bottomToolsView;
@property (nonatomic, strong, readwrite) UILabel *totalDurationLabel;
@property (nonatomic, strong, readwrite) UILabel *currentTimeLabel;
@end

@implementation ZFVideoPlayer

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame: frame]) {
        
        [self addSubview: self.playOrPauseBtn];
        [self addSubview: self.activityIndicatorView];
        [self addSubview: self.bottomToolsView];
        [self.bottomToolsView addSubview: self.totalDurationLabel];
        [self.bottomToolsView addSubview: self.currentTimeLabel];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBgView)];
        [self addGestureRecognizer: tapGesture];
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

- (UILabel *)totalDurationLabel {
    if (!_totalDurationLabel) {
        _totalDurationLabel = [[UILabel alloc] init];
        _totalDurationLabel.font = [UIFont systemFontOfSize: 14];
        _totalDurationLabel.text = @"00:00:00";
    }
    return _totalDurationLabel;
}

- (UILabel *)currentTimeLabel {
    if (!_currentTimeLabel) {
        _currentTimeLabel = [[UILabel alloc] init];
        _currentTimeLabel.font = [UIFont systemFontOfSize: 14];
        _currentTimeLabel.text = @"00:00:00";
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
        make.height.equalTo(@60);
    }];
    
    [self.totalDurationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.bottomToolsView).offset(-12);
        make.centerY.equalTo(self.bottomToolsView);
    }];
    
    [self.currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.bottomToolsView).offset(12);
        make.centerY.equalTo(self.bottomToolsView);
    }];
    
    
    [self bringSubviewToFront: self.playOrPauseBtn];
    [self bringSubviewToFront: self.activityIndicatorView];
    
    [self bringSubviewToFront: self.bottomToolsView];
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

- (void)play {
    NSLog(@"play");
    [self.player play];
}

- (void)pause {
    NSLog(@"pause");
    [self.player pause];
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
        weakSelf.currentTimeLabel.text = [weakSelf timeFormatted: currentTime];
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

@end