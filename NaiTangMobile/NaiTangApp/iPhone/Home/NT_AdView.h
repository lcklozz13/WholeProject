//
//  NT_AdView.h
//  NaiTangApp
//
//  Created by 张正超 on 14-3-3.
//  Copyright (c) 2014年 张正超. All rights reserved.
//
//  主页-广告视图

#import <UIKit/UIKit.h>
#import "XLCycleScrollView.h"
#import "EGOImageView.h"
#import <StoreKit/StoreKit.h>
#import "SwitchTableView.h"
@protocol NT_AdViewDelegate;

@interface NT_AdView : UIView <XLCycleScrollViewDatasource,XLCycleScrollViewDelegate,SKStoreProductViewControllerDelegate>
{
     EGOImageView *_imgView;
}

@property (nonatomic,strong) XLCycleScrollView *scrollView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) NSArray *imageArray;
@property (nonatomic,strong) UIImageView *backImageview;
@property (nonatomic,strong) id<NT_AdViewDelegate> delegate;
@property (nonatomic, strong) NSArray * imgArr;

@property (nonatomic,strong) UILabel * titleType;
@property (nonatomic,strong) UILabel * textLable;
@property (nonatomic , strong) SwitchTableView * switchTableView;

@property (assign) BOOL isPull;

//重新加载数据
- (void)refreshData;

- (void)willMoveToSuperview:(UIView *)newSuperview;
- (void)setImageURL:(NSString *)imageURL;
- (void)setImageURL:(NSString *)imageURL strTemp:(NSString *)temp;

@end

//跳转到详情页
@protocol NT_AdViewDelegate <NSObject>

- (void)toDetailViewControllerDelegate:(UIViewController *)viewController;

@end


