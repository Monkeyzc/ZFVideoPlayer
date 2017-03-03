//
//  ZFSliderBar.h
//  ZFVideoPlayer
//
//  Created by zhaofei on 2017/3/4.
//  Copyright © 2017年 zbull. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZFSliderBar : UIView

@property (nonatomic, strong, readwrite) UIView *bgView;
@property (nonatomic, strong, readwrite) UIView *cacheIndicatorView;
@property (nonatomic, strong, readwrite) UIView *dotView;


/**
 0 - 1
 */
@property (nonatomic, assign, readwrite) float value;

@end
