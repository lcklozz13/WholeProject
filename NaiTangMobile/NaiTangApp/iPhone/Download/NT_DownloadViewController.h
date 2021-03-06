//
//  NT_DownloadViewController.h
//  NaiTangApp
//
//  Created by 张正超 on 14-3-9.
//  Copyright (c) 2014年 张正超. All rights reserved.
//
//  下载管理

#import <UIKit/UIKit.h>
#import "NT_BaseViewController.h"
#import "NT_DownloadManager.h"
#import "NT_CustomButtonStyle.h"
#import "NT_DownloadingCell.h"

//存储下载按钮状态  存储下载按钮
#define KDownloadingStauts  @"downloadingStatus"

@class NT_HeaderView;
@protocol NT_DownLoadManagerDelegate,NT_DownLoadFinishedManagerDelegate,NT_DownLoadManagerUpdateDelegate,NT_DownloadManagerUsedSpaceDelegate;
@protocol NT_DownloadLackOfSpaceDelegate; //空间不足，底部红色提示

@interface NT_DownloadViewController : NT_BaseViewController <UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,NT_DownLoadManagerDelegate,NT_DownLoadFinishedManagerDelegate,NT_DownLoadManagerUpdateDelegate,NT_DownloadManagerUsedSpaceDelegate,NT_DownloadLackOfSpaceDelegate,UIAlertViewDelegate>

@end
