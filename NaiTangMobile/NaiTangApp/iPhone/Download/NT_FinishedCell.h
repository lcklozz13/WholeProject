//
//  NT_FinishedCell.h
//  NaiTangApp
//
//  Created by 张正超 on 14-3-13.
//  Copyright (c) 2014年 张正超. All rights reserved.
//
//  下载完成-列表值

#import <UIKit/UIKit.h>
#import "NT_BaseDownloadCell.h"
#import "NT_DownloadModel.h"

@class NT_CustomButtonStyle;

@interface NT_FinishedCell : NT_BaseDownloadCell

//版本和大小
@property (nonatomic,strong) UILabel *versionSizeLabel;
@property (nonatomic,strong) UILabel *dateLabel;
@property (nonatomic,strong) UIButton *installedButton;
@property (nonatomic,strong) NT_DownloadModel *model;
@property (nonatomic,strong) NT_CustomButtonStyle *customButtonStyle;

- (void)refreshFinishedData:(NT_DownloadModel *)model;

@end
