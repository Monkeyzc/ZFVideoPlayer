//
//  ZFVideoPlayer.h
//  ZFVideoPlayer
//
//  Created by zhaofei on 2017/3/3.
//  Copyright © 2017年 zbull. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZFVideoPlayer : UIView
@property (nonatomic, strong, readwrite) NSString *videoUrl;

- (void)play;
- (void)pause;
- (void)destroyVideoPlayer;
@end