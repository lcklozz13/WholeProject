//
//  NT_CategoryInfo.h
//  NaiTangApp
//
//  Created by 张正超 on 14-3-13.
//  Copyright (c) 2014年 张正超. All rights reserved.
//
//  分类信息

#import <Foundation/Foundation.h>

@interface NT_CategoryInfo : NSObject

@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *pic;
@property (nonatomic,strong) NSString *subtitle;
@property (nonatomic,strong) NSString *gameCount;
@property (nonatomic,assign) NSInteger linkType;
@property (nonatomic,strong) NSString *linkId;

- (NT_CategoryInfo *)categoryInfoFrom:(NSDictionary *)dic;

@end
