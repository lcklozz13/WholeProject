//
//  NT_AppDetailViewController.m
//  NaiTangApp
//
//  Created by 张正超 on 14-3-3.
//  Copyright (c) 2014年 张正超. All rights reserved.
//

#import "NT_AppDetailViewController.h"
#import "NT_DownloadManager.h"
#import "NT_DownloadModel.h"
#import "NT_BaseCell.h"
#import "NT_DetailCell.h"
#import "NT_OnlineGameDialog.h"
#import "UIImageView+WebCache.h"
#import "NT_DetailNewsInfo.h"
#import "NT_DownloadViewController.h"
#import "NT_UpdateAppInfo.h"
#import "DataService.h"
#import "Utile.h"

#import "GuidesVideoModel.h"
#import "liBaoDetailViewController.h"
#import "NT_NoNetworkView.h"
#import "NT_SettingManager.h"
#import "NT_WifiBrowseImage.h"

@interface NT_AppDetailViewController ()
{
    CGFloat heightForSecondCell;
    
    NSString * giftId;
    NSString * giftName;
    UIView * giftView;
    UIControl * giftControl;
    UILabel * giftLabelName;
    UILabel * giftGoLabel;
    // 判断能否获取礼包
    BOOL isAbleToGetGift;
}

@property (nonatomic,strong) NT_DownloadModel *downloadModel;
@property (nonatomic,strong) NSMutableArray *otherGameMutArray;
@property (nonatomic,strong) NSMutableArray *newsMutArray;

@end

@implementation NT_AppDetailViewController

@synthesize infosDetail = _infosDetail;
@synthesize baseDetailInfo = _baseDetailInfo;
@synthesize appID = _appID;
@synthesize downloadBtn = _downloadBtn;
@synthesize downloadButton = _downloadButton;
@synthesize downloadModel = _downloadModel;
@synthesize tableView = _tableView;
@synthesize isExpansion = _isExpansion;
@synthesize isOnlineGame = _isOnlineGame;
@synthesize isShowGold = _isShowGold;
@synthesize expansionHeight = _expansionHeight;
@synthesize otherGameMutArray = _otherGameMutArray;
@synthesize newsMutArray = _newsMutArray;
@synthesize badgeButton = _badgeButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    //self.navigationItem.title = @"游戏详情";
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLable.font = [UIFont boldSystemFontOfSize:20];
    titleLable.textColor = [UIColor whiteColor];
    titleLable.backgroundColor = [UIColor clearColor];
    titleLable.text = @"游戏详情";
    titleLable.textAlignment = TEXT_ALIGN_CENTER;
    [titleLable sizeToFit];
    self.navigationItem.titleView = titleLable;
    
    //返回按钮
    UIButton *leftBt = [UIButton buttonWithFrame:CGRectMake(0, 0, 44, 44) image:[UIImage imageNamed:@"top-back.png"] target:self action:@selector(gotoBack)];
    [leftBt setImage:[UIImage imageNamed:@"top-back-hover.png"] forState:UIControlStateHighlighted];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:leftBt];
    
    if (isIOS7)
    {
        //设置ios7导航栏两边间距，和ios6以下两边间距一致
        UIBarButtonItem *spaceBar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
        spaceBar.width = -10;
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:spaceBar,backItem, nil];
    }
    else
    {
        self.navigationItem.leftBarButtonItem = backItem;
    }
    
    //下载按钮
    _downloadBtn = [UIButton buttonWithFrame:CGRectMake(-10, 0, 44, 44) image:[UIImage imageNamed:@"top-download.png"] target:self action:@selector(gotoDownload:)];
    [_downloadBtn setImage:[UIImage imageNamed:@"top_download-hover.png"] forState:UIControlStateHighlighted];
    UIBarButtonItem *downloadItem = [[UIBarButtonItem alloc] initWithCustomView:_downloadBtn];

    if (isIOS7)
    {
        //设置ios7导航栏两边间距，和ios6以下两边间距一致
        UIBarButtonItem *spaceBar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
        spaceBar.width = -10;
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:spaceBar,downloadItem, nil];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = downloadItem;
    }
    //初始化详情视图
    [self initDetailView];
    
    //判断是否有网络，进入前台时刷新数据
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshdataWithEntryForegroud) name:kApplicationWillEnterForeground object:nil];
}

- (void)refreshdataWithEntryForegroud
{
    //初始化详情视图
    [self initDetailView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //隐藏底部tabbar
    self.hidesBottomBarWhenPushed = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kApplicationWillEnterForeground object:nil];
    
    if (self.isShowGold)
    {
        //收起无限金币弹框
        self.isShowGold = NO;
        //reloadRowsAtIndexPaths必须使用beginUpdates和endUpdates方法
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }
}

//初始化详情视图
- (void)initDetailView
{
    //网络未连接，显示默认图片
    NSString *netConnection = [[NT_HttpEngine sharedNT_HttpEngine] getCurrentNet];
    
    if ([netConnection isEqualToString:NETNOTWORKING])
    {
        NT_NoNetworkView *bgView  = nil;
        if (isIOS7&&isIphone5Screen)
        {
            bgView = [[NT_NoNetworkView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        }
        else if (!isIOS7&&isIphone5Screen)
        {
            bgView = [[NT_NoNetworkView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
        }
        else
        {
            if (isIOS7)
            {
                 bgView = [[NT_NoNetworkView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
            }
            else
            {
                //bgView = [[NT_NoNetworkView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-130)];
                bgView = [[NT_NoNetworkView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];

            }
        }
        bgView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:bgView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(networkButtonPressed:)];
        [bgView addGestureRecognizer:tap];
        
        //无网络时，显示图片
        [bgView loadNoNetworkView];
        [bgView.networkButton addTarget:self action:@selector(networkButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        [self.view removeAllSubViews];
        //网络连接
        //底部弹出红色信息
        [[NSUserDefaults standardUserDefaults] setFloat:SCREEN_HEIGHT-(64+20) forKey:KBottomInfo];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //资讯信息 大家还喜欢
        self.newsMutArray = [NSMutableArray arrayWithCapacity:10];
        self.otherGameMutArray = [NSMutableArray arrayWithCapacity:10];
        
        //攻略 视频
        self.scrollDataArr = [NSMutableArray array];
        self.guidesMutArr = [NSMutableArray array];
        self.videoMutArr = [NSMutableArray array];
        
        self.isShowGold = NO;
        
        //解决ios7下tableview空白20px
        UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.view addSubview:tempLabel];
        
        //详情表
        if (isIOS7)
        {
            //底部有下载按钮时使用
            //_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - (44+49)) style:UITableViewStylePlain];
            _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - (44+20)) style:UITableViewStylePlain];
        }
        else
        {
            //_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - (44+49)) style:UITableViewStylePlain];
            _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - (44+20)) style:UITableViewStylePlain];
        }
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_tableView];
        
        /*
         //底部下载
         UIImageView *downloadImageView;
         if (isIOS7)
         {
         downloadImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, ScreenHeight - 63, SCREEN_WIDTH, 63)];
         }
         else
         {
         downloadImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, ScreenHeight - (63+64), SCREEN_WIDTH, 63)];
         }
         
         downloadImageView.image = [UIImage imageNamed:@"download_bk.png"];
         [self.view addSubview:downloadImageView];
         
         _downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
         _downloadButton.frame = CGRectMake(10, 12, 300, 38);
         [_downloadButton setBackgroundImage:[UIImage imageNamed:@"btn-down.png"] forState:UIControlStateNormal];
         [_downloadButton setTitle:@"下载游戏" forState:UIControlStateNormal];
         [_downloadButton setImage:[UIImage imageNamed:@"btn-down-hover.png"] forState:UIControlStateHighlighted];
         [downloadImageView addSubview:_downloadButton];
         
         */
        
        //滑动手势
        UISwipeGestureRecognizer *recognizer;
        recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
        [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
        [self.view addGestureRecognizer:recognizer];
        
        //获取详情数据
        if (self.appID)
        {
            [self getData:self.appID];
        }
        
        switch (self.typeTag)
        {
            case 200:
                //友盟统计-主页-热门-内容点击量
                umengLogRecHotContClick ++;
                break;
            case 201:
                //友盟统计-主页-必备-内容点击量
                umengLogRecZjbbContClick ++;
                break;
            case 202:
                // 友盟统计-主页-网游-内容点击量
                umengLogRecWlyxContClick ++;
                break;
            case 203:
                // 友盟统计-主页-无限金币-内容点击量
                umengLogRecNoLimitGoldContClick ++;
                break;
            case 204:
                // 友盟统计-排行榜-内容点击量
                umengLogRecRankContClick ++;
                break;
            default:
                break;
        }
        
    }

}

//点击刷新网络
- (void)networkButtonPressed:(id)sender
{
    [self initDetailView];
}

//向右滑动
-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{
    
    if(recognizer.direction==UISwipeGestureRecognizerDirectionRight) {
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma UIBarButtonItem Event Methods
//返回
- (void)gotoBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

//下载页
-(void)gotoDownload:(UIButton *)sender
{
   UITabBarController *tabController = [NTAppDelegate shareNTAppDelegate].tabController;
   NT_DownloadViewController *downloadController = [[tabController viewControllers] objectAtIndex:4];
    [downloadController.navigationController popToRootViewControllerAnimated:NO];
    [tabController setSelectedIndex:4];
}

//获取详情信息
- (void)getData:(NSInteger)appID
{
    //网络连接
    NSString *netConnection = [[NT_HttpEngine sharedNT_HttpEngine] getCurrentNet];
    
    if (![netConnection isEqualToString:NETNOTWORKING])
    {
        //显示加载中
        [self.view showLoadingMeg:@"加载中.."];
        [self.view setLoadingUserInterfaceEnable:YES];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenLoading:)];
        [self.view addGestureRecognizer:tapGesture];
        
        if (!appID) {
            appID = [self.infosDetail.appId intValue];
        }
        
        
        //NSString *urlString = @"http://apitest.naitang.com/mobile/v1/info/detail_1_1_384161.html";
        
        
        NSString *url = @"http://apitest.naitang.com/";
        NSString *urlString = nil;
        if (isIpad) {
            urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/info/detail_2_2_%d.html",appID] : [NSString stringWithFormat:@"mobile/v1/info/detail_2_1_%d.html",appID];
        }else
        {
            urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/info/detail_1_1_%d.html",appID] : [NSString stringWithFormat:@"mobile/v1/info/detail_1_1_%d.html",appID];
        }
        urlString = [NSString stringWithFormat:@"%@%@",url,urlString];
        NSLog(@"%@",urlString);
        
        [DataService requestWithURL:urlString finishBlock:^(id result) {
            //获取详情数据
            NSDictionary *dic = (NSDictionary *)result;
            NSLog(@"get detail result:%@",result);
            if ([dic[@"status"] boolValue])
            {
                self.baseDetailInfo = [NT_BaseAppDetailInfo appDetailInfoFrom:dic[@"data"]];
                
                // 存在礼包
                if ([dic[@"data"][@"gift"] count])
                {
                    NSDictionary * obj = [dic[@"data"][@"gift"] objectAtIndex:0];
                    giftId = obj[@"aid"];
                    giftName = obj[@"giftname"];
                    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
                    NSString * urlForIsAbleGetGift = [NSString stringWithFormat:@"http://api.m.7k7k.com/libao/fahao/isvaildGift.php?giftId=%@&t=%@",giftId,timeSp];
                    
                    NSLog(@"url:%@",urlForIsAbleGetGift);
                    [DataService requestWithURL:urlForIsAbleGetGift finishBlock:^(id result) {
                        if ([result[@"status"] boolValue]) {
                            //可领取的礼包
                            isAbleToGetGift = YES;
                            
                            if (giftLabelName != nil) {
                                [self renderGiftView];
                            }
                            
                        }
                        
                    }];
                    
                }
                
                
                //详情-资讯
                NSString *url = @"http://apitest.naitang.com/";
                NSString *urlString = [NSString stringWithFormat:@"mobile/v1/k7mobile/arclist/%d_%d_%d_%d.html",appID,31,1,4];
                urlString = [NSString stringWithFormat:@"%@%@",url,urlString];
                NSLog(@"url:%@",urlString);
                [DataService requestWithURL:urlString finishBlock:^(id result) {
                    [self.newsMutArray removeAllObjects];
                    NSDictionary *dic = (NSDictionary *)result;
                    if ([dic[@"status"] boolValue])
                    {
                        NSArray *arr = dic[@"data"];
                        if ([arr count] > 0)
                        {
                            //self.expansionHeight = 840;
                            for (int i = 0; i<arr.count; i++)
                            {
                                if ([[arr objectAtIndex:i] count])
                                {
                                    //资讯Model
                                    NT_DetailNewsInfo *newsInfo = [[NT_DetailNewsInfo alloc] init];
                                    [self.newsMutArray addObject:[newsInfo newsInfoWithDic:arr[i]]];
                                }
                                
                            }
                        }
                        
                    }
                    //分类id
                    NSInteger categoryID = [self.baseDetailInfo.gameInfo.category_id integerValue];
                    
                    NSString *url = @"http://apitest.naitang.com/";
                    NSString *urlString = nil;
                    if (isIpad)
                    {
                        urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/k7mobile/catelike/2_2_%d_%d_%d.html",categoryID,1,12] : [NSString stringWithFormat:@"mobile/v1/k7mobile/catelike/2_1_%d_%d_%d.html",categoryID,1,12];
                    }
                    else
                    {
                        urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/k7mobile/catelike/1_1_%d_%d_%d.html",categoryID,1,12] : [NSString stringWithFormat: @"mobile/v1/k7mobile/catelike/1_1_%d_%d_%d.html",categoryID,1,12];
                    }
                    urlString = [NSString stringWithFormat:@"%@%@",url,urlString];
                    //大家还喜欢游戏
                    [DataService requestWithURL:urlString finishBlock:^(id result) {
                        
                        NSDictionary *dic = (NSDictionary *)result;
                        NSArray *arr =  dic[@"data"];
                        if ([arr count] > 0)
                        {
                            [self.otherGameMutArray removeAllObjects];
                            //self.expansionHeight = 1000;
                            for (int i = 0; i<arr.count; i++)
                            {
                                if ([[arr objectAtIndex:i] count])
                                {
                                    [self.otherGameMutArray addObject:[NT_AppDetailInfo inforFromDetailDic:arr[i]]];
                                }
                                
                            }
                        }
                        
                        //攻略资料
                        NSString * str = [NSString stringWithFormat:@"http://apitest.naitang.com/mobile/v1/k7mobile/arclist/%d_28_1_10.html",appID];
                        NSLog(@"攻略 %@",str);
                        [DataService requestWithURL:str finishBlock:^(id result)
                         {
                             if ([[result objectForKey:@"status"] boolValue])
                             {
                                 NSArray *listevents = [result objectForKey:@"data"];
                                 NSString * typeStr = [result objectForKey:@"type"];
                                 self.guidesType = typeStr;
                                 
                                 for (int i = 0; i < [listevents count]; i++)
                                 {
                                     if ([[listevents objectAtIndex:i] count])
                                     {
                                         NSDictionary *dic = [listevents objectAtIndex:i];
                                         GuidesVideoModel * model = [[GuidesVideoModel alloc] initWithDictionary:dic];
                                         [self.guidesMutArr addObject:model];
                                     }
                                     
                                     
                                 }
                             }
                             
                             
                             //视频
                             NSString * str = [NSString stringWithFormat:@"http://apitest.naitang.com/mobile/v1/k7mobile/arclist/%d_19_1_10.html",appID];
                             NSLog(@"视频 %@",str);
                             [DataService requestWithURL:str finishBlock:^(id result)
                              {
                                  if ([[result objectForKey:@"status"] boolValue])
                                  {
                                      NSArray *listevents = [result objectForKey:@"data"];
                                      
                                      for (int i = 0; i < [listevents count]; i++)
                                      {
                                          if ([[listevents objectAtIndex:i] count])
                                          {
                                              NSDictionary *dic = [listevents objectAtIndex:i];
                                              GuidesVideoModel * model = [[GuidesVideoModel alloc] initWithDictionary:dic];
                                              [self.videoMutArr addObject:model];
                                          }
                                      }
                                      
                                  }
                                  
                                  
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      
                                      if (tapGesture) {
                                          [self.view removeGestureRecognizer:tapGesture];
                                      }
                                      [self.view hideLoading];
                                      
                                      //有攻略 有视频
                                      if ([self.guidesMutArr count] > 0 && [self.videoMutArr count] > 0)
                                      {
                                          [self.scrollDataArr addObject:@"游戏信息"];
                                          [self.scrollDataArr addObject:@"攻略资料"];
                                          [self.scrollDataArr addObject:@"游戏视频"];
                                      }
                                      else if ([self.guidesMutArr count] > 0 && [self.videoMutArr count] == 0)
                                      {
                                          [self.scrollDataArr addObject:@"游戏信息"];
                                          [self.scrollDataArr addObject:@"攻略资料"];
                                      }
                                      else if ([self.guidesMutArr count] == 0 &&[self.videoMutArr count] > 0)
                                      {
                                          [self.scrollDataArr addObject:@"游戏信息"];
                                          [self.scrollDataArr addObject:@"游戏视频"];
                                      }
                                      else
                                      {
                                          [self.scrollDataArr addObject:@"游戏信息"];
                                      }
                                      
                                      //刷新表格
                                      self.view.userInteractionEnabled = YES;
                                      [_tableView reloadData];
                                  });
                                  
                              }];
                             
                         }];
                        
                    }];
                    
                }];
            }
        }];

    }
}

#pragma mark --
#pragma mark -- Delegate Methods
//大家还喜欢的游戏
- (void)getOtherGamesInfo:(NSInteger)appID isOtherGames:(BOOL)flag;
{
    if (flag)
    {
        self.view.userInteractionEnabled = NO;
        self.isExpansion = NO;
        self.expansionHeight = 0;
        //收起无限金币黑框
        self.isShowGold = NO;
        
        //移除滚动条 攻略 视频 内容
        [self.scrollDataArr removeAllObjects];
        [self.guidesMutArr removeAllObjects];
        [self.videoMutArr removeAllObjects];
        
        // 恢复礼包的初始状态
        giftId = nil;
        giftName = nil;
        giftView = nil;
        giftControl = nil;
        giftLabelName = nil;
        giftGoLabel = nil;
        isAbleToGetGift = NO;
        
        [self getData:appID];
        [self.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
    }
    else
    {
        [self getData:appID];
    }
    
}

//展开、收起游戏信息高度
- (void)expansionDetailInfoViewDelegate:(CGFloat)height expansion:(BOOL)flag
{
    //是否展开详细信息
    self.isExpansion = flag;
    //获取详细信息高度
    self.expansionHeight = height;
    dispatch_async(dispatch_get_main_queue(), ^{
        //更新cell的高度,reloadSections必须使用beginUpdates和endUpdates方法
        [self.tableView beginUpdates];
        [self.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    });
    
}

//计算资讯 大家还喜欢 是否有数据时显示高度
- (void)loadDefaultDetailHeight:(CGFloat)defaultHeight
{
    self.expansionHeight = defaultHeight;
    heightForSecondCell = defaultHeight+46;
     [self.tableView beginUpdates];
    [self.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

//取消加载中显示
- (void)hiddenLoading:(UITapGestureRecognizer *)tap
{
    if (tap) {
        [self.view removeGestureRecognizer:tap];
    }
    [self.view hideLoading];
}

#pragma mark --
#pragma mark -- UITableView Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!self.baseDetailInfo) {
        return 0;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSString *identifier = [NSString stringWithFormat:@"cell%@",indexPath];
    //id reusedCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    switch (indexPath.section)
    {
        case 0:
        {
            //static identifier 如果定义成静态变量，需要包含表格视图的类实例不释放。
            //低内存的时候，刷新cell为null，所以需要复用原来的数据，才不会为null
            NSString *identifier = @"baseCell";
            id reusedCell = [tableView dequeueReusableCellWithIdentifier:identifier];
            //详情头部-游戏基本信息
            NT_BaseCell *appCell = reusedCell;
            if (!appCell)
            {
                appCell = [[NT_BaseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
                appCell.delegate = self;
                [appCell.baseView.button addTarget:self action:@selector(downloadBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
                appCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            //是否有无限金币
            if (isAbleToGetGift)
            {
                [appCell isShowGiftView:isAbleToGetGift];
                
                [appCell giftView];
                [appCell.control addTarget:self action:@selector(handlePressOnGiftView) forControlEvents:UIControlEventTouchUpInside];
                giftView  = appCell.giftView;
                giftControl = appCell.control;
                giftLabelName = appCell.labelGiftName;
                giftGoLabel = appCell.goLabel;
                if(isAbleToGetGift && giftId && giftName){
                    [self renderGiftView];
                }

            }
            
            [appCell refreshWithAppInfo:self.baseDetailInfo openDownload:self.isShowGold isShowGift:isAbleToGetGift];
            return appCell;
        }
            break;
        case 1:
        {
            NSString *identifier = [NSString stringWithFormat:@"cell%@",indexPath];
            id reusedCell = [tableView dequeueReusableCellWithIdentifier:identifier];
            NT_DetailCell *detailCell = reusedCell;
            if (!detailCell)
            {
                detailCell = [[NT_DetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
                detailCell.detailCellDelegate = self;
                detailCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            //传入游戏 ID   icon   名字
            detailCell.imgUrl = self.baseDetailInfo.gameInfo.round_pic;
            detailCell.strID = self.infosDetail.appId;
            detailCell.gameName = self.infosDetail.categoryName;
            detailCell.category_id = self.baseDetailInfo.gameInfo.category_id;
            detailCell.tableView = self.tableView;
            detailCell.tableHeight = self.tableView.frame.size.height;
            
            
            detailCell.expansionHeight = self.expansionHeight;
            detailCell.isExpansion = self.isExpansion;
            detailCell.appDetailInfo = self.baseDetailInfo;
            detailCell.otherGameArray = self.otherGameMutArray;
            detailCell.newsInfoArray = self.newsMutArray;
            
            //滚动视图内容 攻略 视频
            detailCell.scrollDataArr = self.scrollDataArr;
            detailCell.arrayGuides = self.guidesMutArr;
            detailCell.guidesType = self.guidesType;
            detailCell.arrayVideo = self.videoMutArr;
            
            //初始化滚动条内容
            [detailCell loadScrollView:heightForSecondCell];
            //加载游戏介绍 传递展开后的信息高度
            [detailCell loadIntroData:self.expansionHeight];
            return detailCell;
        }
            break;
        default:
            break;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (isAbleToGetGift)
        {
            //有礼包，可领取
            return self.isShowGold?[NT_BaseCell heightWhenShowDownloadInfoForAppInfo:self.baseDetailInfo]:122;
        }
        return self.isShowGold?[NT_BaseCell heightWhenShowDownloadInfoForAppInfo:self.baseDetailInfo]:[NT_BaseCell normalHeight];
    }
    //详情高度
    return [self heightForDetailCell];
}

//计算详情信息所有有数据的高度
- (CGFloat)heightForDetailCell
{
    //无资讯 无大家还喜欢 默认
    CGFloat height = 640;
    heightForSecondCell = 640;
    
    //有资讯信息 有大家还喜欢
    if (self.newsMutArray.count > 0 && self.otherGameMutArray.count > 0)
    {
        CGFloat h = height+30+self.newsMutArray.count*40+150;
        CGFloat allHeight= self.isExpansion?self.expansionHeight + h:h;
        heightForSecondCell = allHeight;
    }
    else if (self.newsMutArray.count > 0 && self.otherGameMutArray.count == 0)
    {
        //有资讯信息 无大家还喜欢
        CGFloat h = height+ 30+self.newsMutArray.count*40;
        CGFloat newsHeight = self.isExpansion ? self.expansionHeight + h: h;
        heightForSecondCell = newsHeight;
    }
    else if (self.newsMutArray.count == 0 && self.otherGameMutArray.count > 0)
    {
        //无资讯信息 有大家还喜欢
        CGFloat h = height + 150;
        CGFloat otherHeight = self.isExpansion ? self.expansionHeight + h : h;
        heightForSecondCell = otherHeight;
    }
    else
    {
        //只计算展开后信息的高度
        CGFloat introHeight = self.isExpansion ? self.expansionHeight + height : height;
        heightForSecondCell = introHeight;
    }
    
    return heightForSecondCell;
}


#pragma mark --
#pragma mark -- NewAppInfoCell Handler Methods
-(void)downloadBtnPressed:(id)sender
{
    NSArray *arr = self.baseDetailInfo.gameInfo.downloadArray;
    
    if (arr.count == 0) {
        showAlert(@"下载链接未找到");
        return;
    }

    if (![NT_UpdateAppInfo versionCompare:self.baseDetailInfo.gameInfo.minVersion and:[[UIDevice currentDevice] systemVersion]])
    {
        if (arr.count == 1) {
            
            NT_DownloadAddInfo *info = self.baseDetailInfo.gameInfo.downloadArray[0];
            NT_DownloadModel *model = [[NT_DownloadModel alloc] initWithAddress:info.download_addr andGameName:self.baseDetailInfo.gameInfo.game_name andRoundPic:self.baseDetailInfo.gameInfo.round_pic andVersion:self.baseDetailInfo.gameInfo.app_version_name  andAppID:self.baseDetailInfo.gameInfo.app_id];
            model.package = self.infosDetail.package;
            if (!model.package) {
                model.package=self.baseDetailInfo.gameInfo.package;
            }
            self.downloadModel = model;
            
            if (self.isOnlineGame)
            {
                //网游弹出框
                [self onlineDownLoadDialog:self.infosDetail];
            }else{
                //下载
                [self downloadWithMode:model];
            }
            return;
        }
        //收起无限金币弹框
        self.isShowGold = !self.isShowGold;
        //reloadRowsAtIndexPaths必须使用beginUpdates和endUpdates方法
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
        
    }
    else
    {
        CGFloat bottomY = [[NSUserDefaults standardUserDefaults] floatForKey:KBottomInfo];
        UILabel *_jreLabel = nil;
        if (bottomY)
        {
            //最低版本兼容信息
            //self.height-(64+13)
            _jreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, bottomY, SCREEN_WIDTH, 21)];
        }
        _jreLabel.backgroundColor = [UIColor redColor];
        _jreLabel.textAlignment = TEXT_ALIGN_CENTER;
        _jreLabel.textColor = [UIColor whiteColor];
        _jreLabel.font = [UIFont  boldSystemFontOfSize:12];
        _jreLabel.text = [NSString stringWithFormat:@"您的系统版本为%@，需要%@以上版本",[[UIDevice currentDevice] systemVersion],self.baseDetailInfo.gameInfo.minVersion];
        [self.view addSubview:_jreLabel];
        
        [self perform:^{
            [_jreLabel removeFromSuperview];
        } afterDelay:3];
        
    }
    
}

#pragma mark -AppDetailCellDelegate
- (void)appDetailCell:(NT_BaseCell *)appDetailCell installIndex:(int)index
{
    NT_DownloadAddInfo *info = self.baseDetailInfo.gameInfo.downloadArray[index];
    NT_DownloadModel *model = [[NT_DownloadModel alloc] initWithAddress:info.download_addr andGameName:self.baseDetailInfo.gameInfo.game_name andRoundPic:self.baseDetailInfo.gameInfo.round_pic andVersion:self.baseDetailInfo.gameInfo.app_version_name  andAppID:self.baseDetailInfo.gameInfo.app_id];
    model.package = self.infosDetail.package;
    if (!model.package) {
        model.package=self.baseDetailInfo.gameInfo.package;
    }
    self.downloadModel = model;
    
    if (self.isOnlineGame) {
        [self onlineDownLoadDialog:self.infosDetail];
    }else{
        [self downloadWithMode:model];
    }
}

//网游弹出框
- (void)onlineDownLoadDialog:(NT_AppDetailInfo *)info
{
    UIWindow *window = [NTAppDelegate shareNTAppDelegate].window;
    NT_OnlineGameDialog *online = [[NT_OnlineGameDialog alloc] initWithFrame:window.bounds appsInfo:info];
    [online.ntDownBtn addTarget:self action:@selector(ntDownBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [online.appStoreDownBtn addTarget:self action:@selector(appStoreDownBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.infosDetail = info;
    [window addSubview:online];
}

// 奶糖账号下载按钮点击
- (void)ntDownBtnClick:(UIButton *)btn
{
    if(self.downloadModel != nil)
    {
        [btn.superview setHidden:YES];
        [btn.superview removeFromSuperview];
        [[NT_DownloadManager sharedNT_DownLoadManager] downLoadWithModel:self.downloadModel];
        //NSLog(@"%d",isDownLoad);
    }
}

//  打开appstore按钮点击
- (void)appStoreDownBtnClick:(UIButton *)btn
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
        [self openAppWithIdentifier:self.infosDetail.apple_id];
    }else
    {
        [self outerOpenAppWithIdentifier:self.infosDetail.apple_id goAppStore:btn];
    }
}

//连接itunes
- (void)openAppWithIdentifier:(NSString *)appId {
    SKStoreProductViewController *storeProductVC = [[SKStoreProductViewController alloc] init];
    storeProductVC.delegate = self;
    
    if (appId!=nil) {
        NSDictionary *dict = [NSDictionary dictionaryWithObject:appId forKey:SKStoreProductParameterITunesItemIdentifier];
        [self.view showLoadingMeg:@"加载中.."];
        [self.view setLoadingUserInterfaceEnable:YES];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenLoading:)];
        [self.view addGestureRecognizer:tapGesture];
        [storeProductVC loadProductWithParameters:dict completionBlock:^(BOOL result, NSError *error) {
            if (tapGesture) {
                [self.view removeGestureRecognizer:tapGesture];
            }
            [self.view hideLoading];
            if (result) {
                self.hidesBottomBarWhenPushed = YES;
                [self presentViewController:storeProductVC animated:YES completion:nil];
                //[[NTAppDelegate shareNTAppDelegate].tabController.navigationController presentViewController:storeProductVC animated:YES completion:nil];
            }
        }];
        //    NSString *str = [NSString stringWithFormat:@"http://itms-apps://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@",appId];
        //    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        //    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/us/app/id%@?mt=8",appId]]];
        
    }
}


// ios6 以下设备
- (void)outerOpenAppWithIdentifier:(NSString *)appId goAppStore:(UIButton*)btn{
    NSString *urlStr = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/us/app/id%@?mt=8", appId];
    NSURL *url = [NSURL URLWithString:urlStr];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [btn.superview setHidden:YES];
        [btn.superview removeFromSuperview];
        [[UIApplication sharedApplication] openURL:url];
    }
    
}

#pragma mark SKStoreProductViewControllerDelegate
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:^{
        if (isIOS7)
        {
            [NTAppDelegate shareNTAppDelegate].tabController.navigationController.view.top = 20;
            [NTAppDelegate shareNTAppDelegate].tabController.navigationController.view.height = [NTAppDelegate shareNTAppDelegate].window.height - 20;
        }
    }];
}

//下载动画
- (void)downloadWithMode:(NT_DownloadModel *)model
{
    //网络连接状态
    NSString *netConnection = [[NT_HttpEngine sharedNT_HttpEngine] getCurrentNet];
    
    //若设置里打开只在wifi下下载游戏，即在3G状态就不下载
    if ([NT_SettingManager onlyDownloadUseWifi] && [netConnection isEqualToString:NETWORKVIA3G])
    {
        showAlert(@"当前是2G/3G网络，您开启了只在Wifi下下载游戏功能");
    }
    else
    {
        NT_BaseCell *cell = (NT_BaseCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [cell.baseView.button setTitle:@"下载中" forState:UIControlStateNormal];
        CGRect convertRect = [cell convertRect:cell.baseView.appIcon.frame toView:self.view];
        EGOImageView *iconImgView = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"default-icon.png"]];
        [iconImgView imageUrl:[NSURL URLWithString:self.baseDetailInfo.gameInfo.round_pic] tempSTR:@"false"];
        //若有缓存，使用缓存
        /*
        NT_WifiBrowseImage *wifiImage = [[NT_WifiBrowseImage alloc] init];
        [wifiImage wifiBrowseImage:iconImgView urlString:self.baseDetailInfo.gameInfo.round_pic];
         */
        //[iconImgView setImageWithURL:[NSURL URLWithString:self.baseDetailInfo.gameInfo.round_pic] placeholderImage:[UIImage imageNamed:@"default-icon.png"]];
        iconImgView.frame = convertRect;
        iconImgView.clipsToBounds = YES;
        iconImgView.layer.cornerRadius = 15;
        iconImgView.layer.borderWidth = 1;
        [self.view addSubview:iconImgView];
        [UIView animateWithDuration:0.7 animations:^{
            //iconImgView.center = CGPointMake(300, 20);
            iconImgView.center = CGPointMake(SCREEN_WIDTH, 10);
            iconImgView.bounds = CGRectMake(0, 0, 0, 0);
            
        }];
        
        if (_downloadBtn != nil)
        {
            _downloadBtn = nil;
            self.navigationItem.rightBarButtonItem = nil;
            
            
            _downloadBtn = [UIButton buttonWithFrame:CGRectMake(0, 0, 44, 44) image:[UIImage imageNamed:@"top-download.png"] target:self action:@selector(gotoDownload:)];
            [_downloadBtn setImage:[UIImage imageNamed:@"top_download-hover.png"] forState:UIControlStateHighlighted];
            
            _badgeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _badgeButton.frame = CGRectMake(_downloadBtn.right-10,10, 7, 7);
            [_badgeButton setImage:[UIImage imageNamed:@"top-white.png"] forState:UIControlStateNormal];
            
            [_downloadBtn addSubview:_badgeButton];
            
             UIBarButtonItem *downloadItem = [[UIBarButtonItem alloc] initWithCustomView:_downloadBtn];
            
            if (isIOS7)
            {
                //设置ios7导航栏两边间距，和ios6以下两边间距一致
                UIBarButtonItem *spaceBar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
                spaceBar.width = -10;
                self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:spaceBar,downloadItem, nil];
            }
            else
            {
                self.navigationItem.rightBarButtonItem = downloadItem;
            }

        }
        
       
        /*
        //下载数量按钮
        _downloadBtn = [UIButton buttonWithFrame:CGRectMake(-10, 0, 44, 44) image:[UIImage imageNamed:@"top-download.png"] target:self action:@selector(gotoDownload:)];
        [_downloadBtn setImage:[UIImage imageNamed:@"top_download-hover.png"] forState:UIControlStateHighlighted];
        
        _badgeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _badgeButton.frame = CGRectMake(_downloadBtn.left+40,10, 7, 7);
        [_badgeButton setBackgroundImage:[UIImage imageNamed:@"top-white.png"] forState:UIControlStateNormal];
        
        //[_downloadBtn addSubview:_badgeButton];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_downloadBtn];
        */
        
        //隐藏底部tabbar显示
        self.hidesBottomBarWhenPushed = YES;
        [self perform:^{
            [cell.baseView.button setTitle:@"免费下载" forState:UIControlStateNormal];
        } afterDelay:10];
        
        // YES 可以下载，并且开始下载   NO 下载地址无效或者已经下载过了
        BOOL isDownLoad = [[NT_DownloadManager sharedNT_DownLoadManager] downLoadWithModel:model];
        if (isDownLoad)
        {
            //存储下载数量
            NSString *downloadCountString = [[NSUserDefaults standardUserDefaults] objectForKey:KDownloadCount];
            if (downloadCountString)
            {
                
                UITabBarController *tabController = [NTAppDelegate shareNTAppDelegate].tabController;
                [[tabController.tabBar.items objectAtIndex:4] setBadgeValue:downloadCountString];
                
            }
        }
        NSLog(@"isDownLoad:%d",isDownLoad);
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //收起无限金币弹出框
    if (self.isShowGold)
    {
        //reloadRowsAtIndexPaths必须要使用beginUpdates和endUpdates方法
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }

}

- (void)dealloc
{
    [self clear];
}

- (void)clear
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kApplicationWillEnterForeground object:nil];
    self.infosDetail = nil;
    self.baseDetailInfo = nil;
    self.appID = 0;
    self.downloadBtn = nil;
    self.tableView = nil;
    self.isShowGold = NO;
    self.isOnlineGame = NO;
    self.downloadBtn = nil;
    self.isExpansion = NO;
    self.expansionHeight = 0;
    self.badgeButton = nil;
    self.scrollDataArr = nil;
    self.guidesMutArr = nil;
    self.guidesType = nil;
    self.videoMutArr = nil;
    self.typeTag = 0;
    self.giftArray = nil;
    self.downloadModel = nil;
    self.otherGameMutArray = nil;
    self.newsMutArray = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self clear];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    if (isIOS6)
    {
        if ([self isViewLoaded] && self.view.window == nil) {
            self.view = nil;
        }
    }
    [self clear];
}


- (void)handlePressOnGiftView
{
    NSLog(@"gift view is click!");
    
    if (giftId != nil && isAbleToGetGift) {
        liBaoDetailViewController * detailView = [[liBaoDetailViewController alloc] initWithNibName:@"liBaoDetailViewController" bundle:nil];
        
        detailView.giftId = giftId;
        detailView.giftName = giftName;
        detailView.gameName = self.baseDetailInfo.gameInfo.game_name;
        detailView.gameIconUrl = self.baseDetailInfo.gameInfo.round_pic;
        // giftState 0 表明还有剩余 可以领取
        detailView.giftState = @"0";
        
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detailView animated:YES];
    }
    
    
}

- (void)renderGiftView
{
    giftLabelName.text = giftName;
    CGSize giftNameSize = [giftName sizeWithFont:[UIFont fontWithName:@"STHeitiSC-Light" size:14.0f] constrainedToSize:CGSizeMake(MAXFLOAT, 15)];
    giftLabelName.frame = CGRectMake(12, 5, giftNameSize.width, giftNameSize.height);
    giftGoLabel.frame = CGRectMake(giftLabelName.frame.origin.x+giftLabelName.frame.size.width+2, 4,180, 17);
    giftView.hidden = NO;
    giftControl.hidden = NO;
}

@end
