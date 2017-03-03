//
//  VideoModel.h
//  ZFVideoPlayer
//
//  Created by zhaofei on 2017/3/3.
//  Copyright © 2017年 zbull. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoModel : NSObject
@property (nonatomic, strong, readwrite) NSString *cover;
@property (nonatomic, strong, readwrite) NSString *descriptionText;
@property (nonatomic, strong, readwrite) NSNumber *length;
@property (nonatomic, strong, readwrite) NSString *m3u8Hd_url;
@property (nonatomic, strong, readwrite) NSString *m3u8_url;
@property (nonatomic, strong, readwrite) NSString *mp4Hd_url;
@property (nonatomic, strong, readwrite) NSString *mp4_url;
@property (nonatomic, strong, readwrite) NSNumber *playCount;
@property (nonatomic, strong, readwrite) NSNumber *playersize;
@property (nonatomic, strong, readwrite) NSString *ptime;
@property (nonatomic, strong, readwrite) NSString *replyBoard;

@property (nonatomic, strong, readwrite) NSString *replyid;
@property (nonatomic, strong, readwrite) NSString *sectiontitle;
@property (nonatomic, strong, readwrite) NSString *title;
@property (nonatomic, strong, readwrite) NSString *topicImg;
@property (nonatomic, strong, readwrite) NSString *topicName;

@property (nonatomic, strong, readwrite) NSString *topicSid;
@property (nonatomic, strong, readwrite) NSString *vid;


@property (nonatomic, strong, readwrite) NSString *videosource;


+ (instancetype)modelWithDictionary: (NSDictionary *)dictionary;

@end
