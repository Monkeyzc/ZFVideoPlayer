//
//  ZFSliderBar.h
//  ZFVideoPlayer
//
//  Created by zhaofei on 2017/3/4.
//  Copyright © 2017年 zbull. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZFSliderBar;

@interface ZFSliderBar : UIView

@property (nonatomic, strong, readwrite) UIView *bgView;
@property (nonatomic, strong, readwrite) UIView *cacheIndicatorView;
@property (nonatomic, strong, readwrite) UIView *dotView;


@property (nonatomic, strong, readwrite) void (^valueDidChangedBlock)();

@property (nonatomic, strong, readwrite) void (^valueChangeDidFinishedBlock)();

@property (nonatomic, strong, readwrite) void (^dragDotBlock)();

/**
 0 - 1
 */
@property (nonatomic, assign, readwrite) float value;

@end
