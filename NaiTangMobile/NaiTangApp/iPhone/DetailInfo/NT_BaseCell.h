//
//  NT_BaseCell.h
//  NaiTangApp
//
//  Created by 张正超 on 14-3-6.
//  Copyright (c) 2014年 张正超. All rights reserved.
//
//  详情头部-游戏基本信息

#import <UIKit/UIKit.h>
#import "NT_BaseView.h"
#import "NT_BaseCell.h"

@class NT_BaseView,NT_BaseAppDetailInfo;
@protocol NT_BaseCellDelegate;

@interface NT_BaseCell : UITableViewCell

@property (nonatomic,strong) NT_BaseView *baseView;
@property (nonatomic,strong) UIControl *control;
@property (nonatomic,strong) UIImageView *noLimitGoldImageView,*blackBackView;
@property (nonatomic,weak) id<NT_BaseCellDelegate> delegate;
@property (nonatomic,strong) UIView * giftView;
@property (nonatomic,strong) UILabel * labelGiftName;
@property (nonatomic,strong) UILabel * goLabel;

//基本高度
+ (int)normalHeight;
//无限金币 纯净版 纯净正版 弹出框时的高度
+ (int)heightWhenShowDownloadInfoForAppInfo:(NT_BaseAppDetailInfo *)info;

//获取游戏基本信息
//- (void)refreshWithAppInfo:(NT_BaseAppDetailInfo *)info openDownload:(BOOL)open;
- (void)refreshWithAppInfo:(NT_BaseAppDetailInfo *)info openDownload:(BOOL)open isShowGift:(BOOL)isGift;

//是否显示礼包视图
- (void)isShowGiftView:(BOOL)isGift;
@end

@protocol NT_BaseCellDelegate <NSObject>

- (void)appDetailCell:(NT_BaseCell *)appDetailCell installIndex:(int)index;

@end
