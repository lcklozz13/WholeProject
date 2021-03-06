//
//  NT_AdInfo.m
//  NaiTangApp
//
//  Created by 张正超 on 14-3-3.
//  Copyright (c) 2014年 张正超. All rights reserved.
//

#import "NT_AdInfo.h"

@implementation NT_AdInfo

+ (NT_AdInfo *)focusInfoFromDic:(NSDictionary *)dic
{
    NT_AdInfo *info = [[NT_AdInfo alloc] init];
    info.status = [dic objectForKey:@"status"];
    NSMutableArray *array = [dic objectForKey:@"data"];
    info.dataArray = [[NSMutableArray alloc] initWithCapacity:[array count]];
    for (int i = 0; i < [array count]; i++) {
        NT_AdDetailInfo *focus = [NT_AdDetailInfo infoDetialFromDic:[array objectAtIndex:i]];
        [info.dataArray addObject:focus];
    }
    return info;
}

@end

@implementation NT_AdDetailInfo

+ (NT_AdDetailInfo *)infoDetialFromDic:(NSDictionary *)dic
{
    NT_AdDetailInfo *info = [[NT_AdDetailInfo alloc] init];
    info.desc = [dic objectForKey:@"summary"];
    if (!info.desc) {
        info.desc = [dic objectForKey:@"description"];
    }
    info.infoId = [dic objectForKey:@"id"];
    info.pic = [dic objectForKey:@"pic"];
    info.title = [dic objectForKey:@"title"];
    if (isIpad) {
        info.count = [[dic objectForKey:@"count"] intValue];
        info.ctime = [dic objectForKey:@"ctime"];
    }
    return info;
}

@end
