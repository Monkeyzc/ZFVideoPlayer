//
//  ZFVideoPlayerBottomToolsView.h
//  ZFVideoPlayer
//
//  Created by zhaofei on 2017/3/4.
//  Copyright © 2017年 zbull. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFSliderBar.h"

@interface ZFVideoPlayerBottomToolsView : UIView

@property (nonatomic, strong, readwrite) ZFSliderBar *sliderBar;
@property (nonatomic, strong, readwrite) UILabel *totalDurationLabel;
@property (nonatomic, strong, readwrite) UILabel *currentTimeLabel;
@property (nonatomic, strong, readwrite) UIButton *zoomBtn;

@property (nonatomic, strong, readwrite) void (^zoomBlock)();
@end
