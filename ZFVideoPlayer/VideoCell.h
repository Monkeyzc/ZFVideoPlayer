//
//  VideoCell.h
//  ZFVideoPlayer
//
//  Created by zhaofei on 2017/3/3.
//  Copyright © 2017年 zbull. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoModel.h"

@class VideoCell;
@protocol VideoCellDelegate <NSObject>
- (void)videoCellDidClickPlayOrPauseBtn: (VideoCell *)videoCell;
@end

@interface VideoCell : UITableViewCell
@property (nonatomic, strong, readwrite) VideoModel *videoModel;
@property (nonatomic, strong, readwrite) UIImageView *coverView;
@property (nonatomic, weak, readwrite) id delegate;
+ (instancetype)videoCellWithTableView: (UITableView *)tableView;
@end
