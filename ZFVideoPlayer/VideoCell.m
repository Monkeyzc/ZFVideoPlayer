//
//  VideoCell.m
//  ZFVideoPlayer
//
//  Created by zhaofei on 2017/3/3.
//  Copyright © 2017年 zbull. All rights reserved.
//

#import "VideoCell.h"
#import "Masonry.h"
#import "UIImageView+WebCache.h"

static NSString *reuseIdentifier = @"video_cell";


@interface VideoCell()
@property (nonatomic, strong, readwrite) UIButton *playOrPauseBtn;
@property (nonatomic, strong, readwrite) UILabel *titleLabel;
@end

@implementation VideoCell

#pragma mark - Init functions
+ (instancetype)videoCellWithTableView: (UITableView *)tableView {
    VideoCell *cell = [tableView dequeueReusableCellWithIdentifier: reuseIdentifier];
    if (!cell) {
        cell = [[VideoCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: reuseIdentifier];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle: style reuseIdentifier: reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self configureSubViews];
    }
    return self;
}

#pragma mark - Lazy loads
- (UIImageView *)coverView {
    if (!_coverView) {
        _coverView = [[UIImageView alloc] init];
        [self.contentView addSubview: _coverView];
    }
    return _coverView;
}

- (UIButton *)playOrPauseBtn {
    if (!_playOrPauseBtn) {
        _playOrPauseBtn = [[UIButton alloc] init];
        [_playOrPauseBtn setImage: [UIImage imageNamed:@"play"] forState: UIControlStateNormal];
//        [_playOrPauseBtn setImage: [UIImage imageNamed:@"pause"] forState: UIControlStateSelected];
        [_playOrPauseBtn addTarget: self action: @selector(clickPlayOrPauseBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview: _playOrPauseBtn];
    }
    return _playOrPauseBtn;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [self.contentView addSubview: _titleLabel];
    }
    return _titleLabel;
}

- (void)configureSubViews {
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView);
        make.leading.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView);
        make.height.equalTo(@200);
    }];
    
    [self.playOrPauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.coverView);
        make.width.equalTo(@60);
        make.height.equalTo(@60);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.coverView.mas_bottom);
        make.leading.equalTo(self.contentView).offset(12);
        make.trailing.equalTo(self.contentView).offset(-12);
        make.height.equalTo(@80);
    }];
}

- (void)setVideoModel:(VideoModel *)videoModel {
    _videoModel = videoModel;
    
    [self.coverView sd_setImageWithURL: [NSURL URLWithString: videoModel.cover]];
    self.titleLabel.text = videoModel.title;
}

#pragma mark - Actions
- (void)clickPlayOrPauseBtn: (UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(videoCellDidClickPlayOrPauseBtn:)]) {
        [self.delegate videoCellDidClickPlayOrPauseBtn: self];
    }
}
@end
