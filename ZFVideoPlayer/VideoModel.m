//
//  VideoModel.m
//  ZFVideoPlayer
//
//  Created by zhaofei on 2017/3/3.
//  Copyright © 2017年 zbull. All rights reserved.
//

#import "VideoModel.h"

@implementation VideoModel

+ (instancetype)modelWithDictionary: (NSDictionary *)dictionary {
    if (!dictionary || ![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    VideoModel *model = [[VideoModel alloc] init];
    [model setValuesForKeysWithDictionary: dictionary];
    return model;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
}

@end
