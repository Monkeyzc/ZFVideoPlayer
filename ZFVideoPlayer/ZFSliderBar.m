//
//  ZFSliderBar.m
//  ZFVideoPlayer
//
//  Created by zhaofei on 2017/3/4.
//  Copyright © 2017年 zbull. All rights reserved.
//

#import "ZFSliderBar.h"
#import "Masonry.h"

#define sliderHeight 8
#define dotSize 16

@implementation ZFSliderBar

- (instancetype)init {
    if (self = [super init]) {
        [self addSubview: self.bgView];
        [self addSubview: self.cacheIndicatorView];
        [self addSubview: self.dotView];
        
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self);
            make.trailing.equalTo(self);
            make.centerY.equalTo(self);
            make.height.equalTo(@(sliderHeight));
        }];
        
        [self.cacheIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.bgView);
            make.trailing.equalTo(self.bgView);
            make.centerY.equalTo(self.bgView);
            make.height.equalTo(self.bgView);
        }];
        
        [self.dotView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.bgView).offset(0);
            make.centerY.equalTo(self.bgView).offset(0);
            make.width.equalTo(@(dotSize));
            make.height.equalTo(@(dotSize));
        }];

    }
    return self;
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor purpleColor];
        _bgView.layer.cornerRadius = sliderHeight * 0.5;
        _bgView.clipsToBounds = YES;
    }
    return _bgView;
}

- (UIView *)cacheIndicatorView {
    if (!_cacheIndicatorView) {
        _cacheIndicatorView = [[UIView alloc] init];
        _cacheIndicatorView.backgroundColor = [UIColor redColor];
        _cacheIndicatorView.layer.cornerRadius = sliderHeight * 0.5;
        _cacheIndicatorView.clipsToBounds = YES;
    }
    return _cacheIndicatorView;
}

- (UIView *)dotView {
    if (!_dotView) {
        _dotView = [[UIView alloc] init];
        _dotView.backgroundColor = [UIColor whiteColor];
        _dotView.layer.cornerRadius = dotSize * 0.5;
        _dotView.clipsToBounds = YES;
    }
    return _dotView;
}

- (void)setValue:(float)value {
    _value = value;
    if (value == 1) {
        [self.dotView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.bgView).offset(self.bgView.frame.size.width - dotSize);
        }];
        return;
    }
    
    [self.dotView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.bgView).offset(value * self.bgView.frame.size.width);
    }];
}

@end
