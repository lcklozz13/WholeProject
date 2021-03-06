//
//  GuidesVideoModel.m
//  NaiTangApp
//
//  Created by 小远子 on 14-3-13.
//  Copyright (c) 2014年 张正超. All rights reserved.
//

#import "GuidesVideoModel.h"

@implementation GuidesVideoModel
@synthesize gameID;
@synthesize gameName;
@synthesize description;
@synthesize source;
@synthesize Videotitle;
@synthesize pid;
@synthesize name;
@synthesize link;
@synthesize pubdate;
@synthesize image;
@synthesize countStr;
@synthesize strId;
- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        gameName = [dictionary objectForKey:@"game_name"];
        gameID = [dictionary objectForKey:@"game_id"];
        description = [dictionary objectForKey:@"description"];
        source = [dictionary objectForKey:@"soure"];
        Videotitle = [dictionary objectForKey:@"title"];
        name = [dictionary objectForKey:@"name"];
        pid = [dictionary objectForKey:@"pid"];
        link = [dictionary objectForKey:@"link"];
        pubdate = [dictionary objectForKey:@"pubdate"];
        image = [dictionary objectForKey:@"image"];
        countStr = [dictionary objectForKey:@"count"];
         strId = [dictionary objectForKey:@"id"];

    }
    return self;
}

@end
