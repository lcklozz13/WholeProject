//
//  NT_DetailCell.m
//  NaiTangApp
//
//  Created by 张正超 on 14-3-6.
//  Copyright (c) 2014年 张正超. All rights reserved.
//

#import "NT_DetailCell.h"
#import "NT_GuidesView.h"
#import "NT_VideoView.h"
#import "NT_DetailInfoView.h"
#import "AppDelegate_Def.h"

#import "DataService.h"
#import "GuidesVideoModel.h"
#define url @"http://api.naitang.com/mobile/v1/k7mobile/arclist/"
#define urlTail @"_28_1_10.html?332"

#define SPurl @"http://apitest.naitang.com/mobile/v1/k7mobile/arclist/"
#define SPurlTail @"_19_1_10.html"

@interface NT_DetailCell ()
{
    UIButton *_seletButton;
    int _currentPage;
}

@end

@implementation NT_DetailCell
@synthesize arrayGuides;
@synthesize arrayVideo;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.isTemp = YES;
        self.backgroundColor = [UIColor whiteColor];
        
        /*
         arrayVideo = [NSMutableArray array];
         arrayGuides = [NSMutableArray array];
         
         //self.backgroundColor = [UIColor whiteColor];
         self.detailArray = [NSArray arrayWithObjects:@"游戏信息",@"攻略资料",@"游戏视频",nil];
         */
        
        /*
         _sliperImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 36)];
         _sliperImageView.image = [UIImage imageNamed:@"top-slide-bg.png"];
         [self.contentView addSubview:_sliperImageView];
         */
        _sliperImageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 36)];
        _sliperImageView.backgroundColor = [UIColor colorWithHex:@"#f8f8f8"];
        [self.contentView addSubview:_sliperImageView];
        
    }
    return self;
}

- (void)loadScrollView:(CGFloat)height
{
    if (!_scrollView)
    {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 36, SCREEN_WIDTH, height-36+20)];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.bounces = NO;
        _scrollView.showsVerticalScrollIndicator = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.autoresizesSubviews = NO;
        [self.contentView addSubview:_scrollView];
        
        //设置滚动视图内容大小
        _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width*[self.scrollDataArr count], _scrollView.frame.size.height);
        
        //初始化滚动视图内容数据
        [self getData];
        
    }
}

//初始化滚动视图内容数据
- (void)getData
{
    for (int i = 0;  i< self.scrollDataArr.count; i++) {
        UIButton *textBt = [[UIButton alloc] initWithFrame:CGRectMake(107*i, 0, 107, 35)];
        textBt.backgroundColor = [UIColor clearColor];
        [textBt setTitle:[self.scrollDataArr objectAtIndex:i] forState:UIControlStateNormal];
        textBt.titleLabel.textColor = Text_Color_Title;
        [textBt addTarget:self action:@selector(gotoChange:) forControlEvents:UIControlEventTouchUpInside];
        textBt.tag = 20 + i;
        [self.contentView addSubview:textBt];
        
        
        textBt.titleLabel.font = [UIFont systemFontOfSize:16];
        [textBt setTitleColor:Text_Color forState:UIControlStateNormal];
        if (i==0) {
            [textBt setTitleColor:[UIColor colorWithHex:@"#505a5f"] forState:UIControlStateNormal];
            _currentPage = 0;
            _seletButton = textBt;
        }
        
    }
    
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 34, SCREEN_WIDTH, 1)];
    lineView.backgroundColor = [UIColor colorWithHex:@"#f0f0f0"];
    [_sliperImageView addSubview:lineView];
    
    UIView *lineShow = [[UIView alloc] initWithFrame:CGRectMake(0, 32, 107, 3)];
    lineShow.backgroundColor = [UIColor colorWithHex:@"#1eb5f7"];
    lineShow.tag = 100;
    [_sliperImageView addSubview:lineShow];
    
}

//加载游戏介绍
- (void)loadIntroData:(CGFloat)height
{
    
    //游戏介绍
    _detailInfoView = [[NT_DetailInfoView alloc] initWithFrame:CGRectMake(0, 0, _scrollView.frame.size.width, _scrollView.frame.size.height)];
    _detailInfoView.tag = 200;
    //游戏图片
    _detailInfoView.detailInfo = self.appDetailInfo;
    //大家还喜欢 资讯
    _detailInfoView.otherGameArray = self.otherGameArray;
    _detailInfoView.newsInfoArray = self.newsInfoArray;
    _detailInfoView.detailInfoViewDelegate = self;
    //加载所有详情信息
    [_detailInfoView loadAllView:self.expansionHeight isExpansion:self.isExpansion];
    //详情-大图片
    [_detailInfoView loadDetailImage:self.appDetailInfo];
    //介绍
    [_detailInfoView loadDetailInfo:self.appDetailInfo isExpansion:self.isExpansion];
    //展开、收起更多信息
    //[_detailInfoView expansionIntroHeight:self.expansionHeight isExpansion:self.isExpansion];
    //资讯
    [_detailInfoView loadNewsInfo:self.newsInfoArray];
    //大家还喜欢
    [_detailInfoView loadOtherGames:self.otherGameArray];
    [_scrollView addSubview:_detailInfoView];
    
}

#pragma mark - UIScrollView Delegate Methods
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (_scrollView == scrollView) {
        CGFloat pageWidth = scrollView.frame.size.width;
        int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;//根据坐标算页数
        NSLog(@"dddd=====%i",page);
        [self _sliperIndex:page];
    }
}

#pragma mark  ---- 滑动条

- (void)_sliperIndex:(int)page
{
    if (_currentPage != page) {
        UIView *line = (UIView *)[_sliperImageView viewWithTag:100];
        
        [UIView animateWithDuration:0.2 animations:^{
            line.center = CGPointMake(107*page + 107/2, 33);
        } completion:^(BOOL finished)
         {
             for (int i = 0; i < [self.scrollDataArr count]; i++) {
                 UIButton *textBt = (UIButton *)[self.contentView viewWithTag:20 + i];
                 [textBt setTitleColor:Text_Color_Title forState:UIControlStateNormal];
             }
             UIButton *textBt = (UIButton *)[self.contentView viewWithTag:20+page];
             _seletButton = textBt;
             [textBt setTitleColor:[UIColor colorWithHex:@"#505a5f"] forState:UIControlStateNormal];
         }];
        
    }
    _currentPage = page;
    
    switch (page)
    {
        case 1:
        {
            //第二项，可能是攻略，也可能是视频，这里使用guidesType区分下
            if (self.guidesType)
            {
                //有攻略
                if (!_guidesView)
                {
                    //                _videoView.height = YES;
                    //                _guidesView.height = NO;
                    if (self.isTemp == YES) {
                        if (IOS7) {
                            self.tableView.frame = CGRectMake(0, 64, self.frame.size.width, self.frame.size.height + 300);
                        }else{
                            self.tableView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height + 300);
                        }
                    }
                    _guidesView = [[NT_GuidesView alloc] initWithFrame:CGRectMake(_scrollView.frame.size.width, 0, _scrollView.frame.size.width, self.frame.size.height)];
                    _guidesView.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1.0];
                    _guidesView.guidesArray = self.arrayGuides;
                    _guidesView.strType = self.guidesType;
                    [_guidesTableView reloadData];
                    [_scrollView addSubview:_guidesView];
                    //                _guidesView.tag = 200+page;
                    //NSLog(@"aaaaa %@",self.strID);
                    //                [self loadGuidesData:@"384596"];
                    //[self loadGuidesData:self.strID];
                    
                }
            }
            else
            {
                //无攻略 有视频
                if (!_videoView)
                {
                    //                _videoView.height = NO;
                    //                _guidesView.height = YES;
                    if (self.isTemp == YES) {
                        if (IOS7) {
                            self.tableView.frame = CGRectMake(0, 64, self.frame.size.width, self.frame.size.height + 300);
                        }else{
                            self.tableView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height + 300);
                        }
                    }
                    
                    _videoView = [[NT_VideoView alloc] initWithFrame:CGRectMake(_scrollView.frame.size.width, 0, _scrollView.frame.size.width, self.frame.size.height)];
                    _videoView.tag = 200+page;
                    _videoView.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1.0];
                    NSLog(@"%@",self.imgUrl);
                    _videoView.urlImg = self.imgUrl;
                    _videoView.gameName = self.gameName;
                    _videoView.VideoViewArr = arrayVideo;
                    [_videoTableView reloadData];
                    [_scrollView addSubview:_videoView];
                    //                [self loadVideoData:@"19"];
                    //[self loadVideoData:self.strID];
                }
                
            }
        }
            break;
        case 2:
        {
            if (!_videoView)
            {
                //                _videoView.height = NO;
                //                _guidesView.height = YES;
                if (self.isTemp == YES) {
                    if (IOS7) {
                        self.tableView.frame = CGRectMake(0, 64, self.frame.size.width, self.frame.size.height + 300);
                    }else{
                        self.tableView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height + 300);
                    }
                }
                
                _videoView = [[NT_VideoView alloc] initWithFrame:CGRectMake(_scrollView.frame.size.width*2, 0, _scrollView.frame.size.width, self.frame.size.height)];
                _videoView.tag = 200+page;
                _videoView.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1.0];
                NSLog(@"%@",self.imgUrl);
                _videoView.urlImg = self.imgUrl;
                _videoView.gameName = self.gameName;
                _videoView.VideoViewArr = arrayVideo;
                [_videoTableView reloadData];
                [_scrollView addSubview:_videoView];
                //                [self loadVideoData:@"19"];
                //[self loadVideoData:self.strID];
            }
        }
            break;
        case 0:
        {
            if (!_detailInfoView)
            {
                if (IOS7) {
                    self.tableView.frame = CGRectMake(0, 64, 320, self.tableHeight);
                }else{
                    self.tableView.frame = CGRectMake(0, 0, 320, self.tableHeight);
                }
                [self.tableView reloadData];
            }else{
                if (IOS7) {
                    self.tableView.frame = CGRectMake(0, 64, 320, self.tableHeight);
                }else{
                    self.tableView.frame = CGRectMake(0, 0, 320, self.tableHeight);
                }
                [self.tableView reloadData];
            }
        }
            break;
        default:
            break;
    }
}


- (void)loadVideoData:(NSString *)urlString
{
    NSString * str = [NSString stringWithFormat:@"%@%@%@",SPurl,urlString,SPurlTail];
    NSLog(@"%@",str);
    [DataService requestWithURL:str finishBlock:^(id result) {
        NSArray *listevents = [result objectForKey:@"data"];
        for (NSDictionary * dic in listevents) {
            GuidesVideoModel * model = [[GuidesVideoModel alloc] initWithDictionary:dic];
            [arrayVideo addObject:model];
        }
        _videoView.VideoViewArr = arrayVideo;
        [_videoTableView reloadData];
        [_scrollView addSubview:_videoView];
    }];
}

- (void)loadGuidesData:(NSString *)urlString
{
    NSString * str = [NSString stringWithFormat:@"%@%@%@",url,urlString,urlTail];
    NSLog(@"%@",str);
    [DataService requestWithURL:str finishBlock:^(id result) {
        NSArray *listevents = [result objectForKey:@"data"];
        NSString * typeStr = [result objectForKey:@"type"];
        for (NSDictionary * dic in listevents) {
            GuidesVideoModel * model = [[GuidesVideoModel alloc] initWithDictionary:dic];
            [arrayGuides addObject:model];
        }
        _guidesView.guidesArray = arrayGuides;
        _guidesView.strType = typeStr;
        [_guidesTableView reloadData];
        [_scrollView addSubview:_guidesView];
    }];
}

- (void)gotoChange:(UIButton *)sender
{
    if (sender != _seletButton) {
        [self _sliperIndex:(sender.tag - 20)];
        _seletButton = sender;
        CGRect newFrame = _scrollView.frame;
        newFrame.origin.x = _scrollView.frame.size.width*(sender.tag -20);
        [_scrollView scrollRectToVisible:newFrame animated:YES];
    }
}

#pragma mark --
#pragma  mark -- Delegate Methods

//根据游戏id，获取详情信息
- (void)getOtherGamesInfo:(NSInteger)appID isOtherGames:(BOOL)flag;
{
    if (self.detailCellDelegate&&[self.detailCellDelegate respondsToSelector:@selector(getOtherGamesInfo:isOtherGames:)])
    {
        [self.detailCellDelegate getOtherGamesInfo:appID isOtherGames:YES];
    }
}

//展开、收起详情介绍高度
- (void)expansionDetailInfoViewDelegate:(CGFloat)height expansion:(BOOL)flag;
{
    if (self.detailCellDelegate&&[self.detailCellDelegate respondsToSelector:@selector(expansionDetailInfoViewDelegate:expansion:)]) {
        [self.detailCellDelegate expansionDetailInfoViewDelegate:height expansion:flag];
    }
}

//计算资讯 大家还喜欢 是否有数据时显示高度
- (void)loadDefaultDetailHeight:(CGFloat)defaultHeight
{
    NSLog(@"sdsds%f",defaultHeight);
    NSLog(@" ----%f",self.scrollView.frame.size.height);
    self.scrollView.frame = CGRectMake(0, 36, 320, defaultHeight);
    NSLog(@"PPP ==%f",self.scrollView.frame.size.height);
    
    CGRect frame = self.scrollView.frame;
    frame.size.height = defaultHeight;
    self.scrollView.frame = frame;
    self.scrollView.contentSize = CGSizeMake(frame.size.width*3,frame.size.height);
    
    
    
    if (self.detailCellDelegate && [self.detailCellDelegate respondsToSelector:@selector(loadDefaultDetailHeight:)])
    {
        [self.detailCellDelegate loadDefaultDetailHeight:defaultHeight];
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)dealloc
{
    self.scrollDataArr = nil;
    self.infoTableView = nil;
    self.guidesTableView = nil;
    self.videoTableView = nil;
    self.sliperImageView = nil;
    self.otherGameArray = nil;
    self.newsInfoArray = nil;
    self.appDetailInfo = nil;
    self.detailCellDelegate = nil;
    self.detailInfoView = nil;
    self.expansionHeight = 0;
    self.isExpansion = 0;
    self.tableView = nil;
    self.tableHeight = 0;
    self.strID = nil;
    self.imgUrl = nil;
    self.gameName = nil;
    self.category_id = nil;
    self.isTemp = NO;
    self.arrayVideo = nil;
    self.arrayGuides = nil;
    self.guidesType = nil;
    self.scrollDataArr = nil;
}

@end
