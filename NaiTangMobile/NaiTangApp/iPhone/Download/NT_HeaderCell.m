//
//  NT_HeaderCell.m
//  NaiTangApp
//
//  Created by 张正超 on 14-3-9.
//  Copyright (c) 2014年 张正超. All rights reserved.
//

#import "NT_HeaderCell.h"
#import "UIProgressBar.h"

@implementation NT_HeaderCell

@synthesize usedLabel = _usedLabel;
@synthesize unUsedLabel = _unUsedLabel;
@synthesize editButton = _editButton;
@synthesize allStartButton = _allStartButton;
@synthesize progressView = _progressView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //背景图片
        UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 74)];
        backImageView.image = [UIImage imageNamed:@"white-bg.png"];
        [self.contentView addSubview:backImageView];
        
        //已用图片
        UIImageView *usedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 20, 7, 7)];
        usedImageView.image = [UIImage imageNamed:@"dot-green.png"];
        [backImageView addSubview:usedImageView];
        
        //已用空间
        _usedLabel = [[UILabel alloc] initWithFrame:CGRectMake(usedImageView.right, 15, 100, 20)];
        _usedLabel.font = [UIFont systemFontOfSize:14];
        _usedLabel.text = @"已用5.1G";
        [backImageView addSubview:_usedLabel];
        
        //空闲图片
        UIImageView *unUsedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_usedLabel.right-20, 20, 7, 7)];
        unUsedImageView.image = [UIImage imageNamed:@"dot-gray.png"];
        [backImageView addSubview:unUsedImageView];
        
        //空闲空间
        _unUsedLabel = [[UILabel alloc] initWithFrame:CGRectMake(unUsedImageView.right, 15, 100, 20)];
        _unUsedLabel.font = [UIFont systemFontOfSize:14];
        _unUsedLabel.text = @"空闲22G";
        [backImageView addSubview:_unUsedLabel];
        
        //编辑按钮
        _editButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _editButton.frame = CGRectMake(_unUsedLabel.right-25, 10, 54, 29);
        [_editButton setTitle:@"编辑" forState:UIControlStateNormal];
        [_editButton setTitleColor:Text_Color forState:UIControlStateNormal];
        [_editButton setBackgroundImage:[UIImage imageNamed:@"btn-white.png"] forState:UIControlStateNormal];
        [_editButton setBackgroundImage:[UIImage imageNamed:@"btn-white-hover.png"] forState:UIControlStateHighlighted];
        _editButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [backImageView addSubview:_editButton];
        
        //全部开始按钮
        _allStartButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _allStartButton.frame = CGRectMake(_editButton.right+5, 10, 74, 29);
        [_allStartButton setTitle:@"全部开始" forState:UIControlStateNormal];
        [_allStartButton setBackgroundImage:[UIImage imageNamed:@"btn-light-read.png"] forState:UIControlStateNormal];
         [_allStartButton setBackgroundImage:[UIImage imageNamed:@"btn-light-read-hover.png"] forState:UIControlStateHighlighted];
        _allStartButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_allStartButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [backImageView addSubview:_allStartButton];
        
        //磁盘空间
        _progressView = [[UIProgressBar alloc] initWithFrame:CGRectMake(10, _allStartButton.bottom+10, 300, 10)];
        _progressView.minValue = 0;
        _progressView.currentValue = 0;
        [_progressView setLineColor:[UIColor whiteColor]];
        _progressView.progressColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"sd_card.png"]];
         _progressView.progressRemainingColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"gray-line.png"]];
        [self.contentView addSubview:_progressView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
