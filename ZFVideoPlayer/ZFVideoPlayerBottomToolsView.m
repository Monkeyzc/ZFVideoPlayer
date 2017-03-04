//
//  ZFVideoPlayerBottomToolsView.m
//  ZFVideoPlayer
//
//  Created by zhaofei on 2017/3/4.
//  Copyright © 2017年 zbull. All rights reserved.
//

#import "ZFVideoPlayerBottomToolsView.h"
#import "Masonry.h"

@implementation ZFVideoPlayerBottomToolsView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor grayColor];
        self.alpha = 0.6;
        
        [self addSubview: self.currentTimeLabel];
        [self addSubview: self.sliderBar];
        [self addSubview: self.totalDurationLabel];
        [self addSubview: self.zoomBtn];
        
    }
    return self;
}

- (ZFSliderBar *)sliderBar {
    if (!_sliderBar) {
        _sliderBar = [[ZFSliderBar alloc] init];
    }
    return _sliderBar;
}

- (UILabel *)totalDurationLabel {
    if (!_totalDurationLabel) {
        _totalDurationLabel = [[UILabel alloc] init];
        _totalDurationLabel.font = [UIFont systemFontOfSize: 10];
        _totalDurationLabel.text = @"00:00:00";
        _totalDurationLabel.textAlignment = NSTextAlignmentRight;
    }
    return _totalDurationLabel;
}

- (UILabel *)currentTimeLabel {
    if (!_currentTimeLabel) {
        _currentTimeLabel = [[UILabel alloc] init];
        _currentTimeLabel.font = [UIFont systemFontOfSize: 10];
        _currentTimeLabel.text = @"00:00:00";
        _totalDurationLabel.textAlignment = NSTextAlignmentRight;
    }
    return _currentTimeLabel;
}

- (UIButton *)zoomBtn {
    if (!_zoomBtn) {
        _zoomBtn = [[UIButton alloc] init];
        [_zoomBtn setImage: [UIImage imageNamed:@"btn_zoom_out"] forState: UIControlStateNormal];
        [_zoomBtn setImage: [UIImage imageNamed:@"btn_zoom_in"] forState: UIControlStateSelected];
        [_zoomBtn addTarget: self action:@selector(clickZoomBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _zoomBtn;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(4);
        make.centerY.equalTo(self);
        make.width.equalTo(@48);
    }];
    
    [self.sliderBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.currentTimeLabel.mas_trailing).offset(1);
        make.trailing.equalTo(self.totalDurationLabel.mas_leading).offset(-1);
        make.top.equalTo(self);
        make.bottom.equalTo(self);
    }];
    
    [self.totalDurationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.zoomBtn.mas_leading).offset(-4);
        make.centerY.equalTo(self);
        make.width.equalTo(@48);
    }];
    
    [self.zoomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.trailing.equalTo(self).offset(-4);
        make.height.equalTo(@16);
        make.width.equalTo(@16);
    }];
}

- (void)clickZoomBtn: (UIButton *)btn {
    btn.selected = !btn.selected;
    
    if (self.zoomBlock) {
        NSLog(@"zoom");
        self.zoomBlock();
    }
}

@end
