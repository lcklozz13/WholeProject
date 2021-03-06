
//
//  NT_MainViewController.m
//  NaiTangApp
//
//  Created by 张正超 on 14-3-2.
//  Copyright (c) 2014年 张正超. All rights reserved.
//

#import "NT_MainViewController.h"
#import "NT_MainView.h"
#import "NT_OnlineGameDialog.h"
#import "NT_NoNetworkView.h"
#import "NT_USerGuidesViewController.h"
#import "NT_MacroDefine.h"
#import "RightViewController.h"

@interface NT_MainViewController ()
{
    //UIImageView *_slide;
    UIView *_slide;
    int _currnetPage;
    UIButton *_seletBt;
}
@property (nonatomic,strong) NT_UserGuidesViewController *startController;

@end

@implementation NT_MainViewController

@synthesize mainScrollView = _mainScrollView;
@synthesize mainArray = _mainArray;
@synthesize appDetailInfo = _appDetailInfo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

/*
- (void)viewDidAppear:(BOOL)animated{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"])
    {
        //用户指引界面
        self.startController = [[NT_UserGuidesViewController alloc] init];
        //[ [NTAppDelegate shareNTAppDelegate].window.rootViewController presentModalViewController:startController animated:NO];
        //self.window.rootViewController = startController;
        [[NTAppDelegate shareNTAppDelegate].window addSubview:_startController.view];
    }
    else
    {
        self.startController = nil;
    }
}
 */

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //self.navigationItem.title = @"奶糖游戏";
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLable.font = [UIFont boldSystemFontOfSize:20];
    titleLable.textColor = [UIColor whiteColor];
    titleLable.backgroundColor = [UIColor clearColor];
    titleLable.text = @"奶糖游戏";
    titleLable.textAlignment = TEXT_ALIGN_CENTER;
    [titleLable sizeToFit];
    self.navigationItem.titleView = titleLable;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    //加载视图
    [self loadMainData];
}

//加载视图
- (void)loadMainData
{
    //第一次加载时，显示可更新数量
    BOOL isFirstShowUpdate = [[NSUserDefaults standardUserDefaults] boolForKey:KIsFirstShowUpdateCount];
    if (!isFirstShowUpdate)
    {
        //显示可更新数量
        NTAppDelegate *appDelegate = (NTAppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate getGameUpdateCount];
        
        //若无更新信息，不需要弹框提示无更新
        RightViewController *rightController = [[RightViewController alloc] init];
        rightController.isNoShowUpdate = YES;
        [rightController updateNaitangVersion];
        
        [[NSUserDefaults standardUserDefaults] boolForKey:KIsFirstShowUpdateCount];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    //加载滚动条数
    [self loadScrollData];
}

//点击刷新网络
- (void)networkButtonPressed:(id)sender
{
    [self loadMainData];
}

//加载滚动条数
- (void)loadScrollData
{
    /*
    if ([[UIDevice currentDevice] isJailbroken])
    {
        self.mainArray = [NSArray arrayWithObjects:@"热 门",@"必 备",@"网 游",@"无限金币", nil];
    }
    else
    {
        //正版无无限金币版
        self.mainArray = [NSArray arrayWithObjects:@"热 门",@"必 备",@"网 游", nil];
    }
     */
    self.mainArray = [NSArray arrayWithObjects:@"热 门",@"必 备",@"网 游", nil];
    
    //滑动条
    if (isIOS7)
    {
        _slide = [[UIView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, 41)];
    }
    else
    {
        _slide = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 41)];
    }
    
    _slide.backgroundColor = [UIColor colorWithHex:@"#ffffff"];
    _slide.userInteractionEnabled = YES;
    [self.view addSubview:_slide];
    
    //选项按钮
    for (int i = 0;  i< [self.mainArray count]; i++) {
        
        UIButton *textBt = nil;
        if (self.mainArray.count==4)
        {
            textBt = [[UIButton alloc] initWithFrame:CGRectMake(80*i, 0, 80, 40)];
        }
        else
        {
            textBt = [[UIButton alloc] initWithFrame:CGRectMake(107*i, 0, 107, 40)];
        }
        
        textBt.backgroundColor = [UIColor clearColor];
        [textBt setTitle:[self.mainArray objectAtIndex:i] forState:UIControlStateNormal];
        [textBt addTarget:self action:@selector(gotoChange:) forControlEvents:UIControlEventTouchUpInside];
        [_slide addSubview:textBt];
        textBt.tag = 10 + i;
        
        textBt.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        //[textBt setTitleColor:[UIColor colorWithHex:@"#8c9599"] forState:UIControlStateNormal];
        [textBt setTitleColor:Text_Color_Title forState:UIControlStateNormal];
        if (i==0) {
            [textBt setTitleColor:[UIColor colorWithHex:@"#1eb5f7"] forState:UIControlStateNormal];
            _currnetPage = 0;
            _seletBt = textBt;
        }
    }
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 39, SCREEN_WIDTH, 1)];
    lineView.backgroundColor = [UIColor colorWithHex:@"#f0f0f0"];
    [_slide addSubview:lineView];
    
    //滑动线
    UIView *lineShow = nil;
    if (self.mainArray.count == 3)
    {
        //lineShow = [[UIView alloc] initWithFrame:CGRectMake(0, 32, 107, 3)];
        lineShow = [[UIView alloc] initWithFrame:CGRectMake(0, 37, 107, 3)];
    }
    else if (self.mainArray.count == 4)
    {
        //lineShow = [[UIView alloc] initWithFrame:CGRectMake(0, 32, 80, 3)];
        lineShow = [[UIView alloc] initWithFrame:CGRectMake(0, 37, 107, 3)];
    }
    lineShow.backgroundColor = [UIColor colorWithHex:@"#1eb5f7"];
    lineShow.tag = 100;
    [_slide addSubview:lineShow];
    
    [self loadScrollView];
}

- (void)loadScrollView
{
    //滚动条
    _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _slide.bottom-1, SCREEN_WIDTH, SCREEN_HEIGHT-(44+49))];
    _mainScrollView.delegate = self;
    _mainScrollView.pagingEnabled = YES;
    _mainScrollView.backgroundColor = [UIColor clearColor];
    _mainScrollView.bounces = NO;
    _mainScrollView.showsVerticalScrollIndicator = NO;
    _mainScrollView.showsHorizontalScrollIndicator = NO;
    _mainScrollView.autoresizesSubviews = NO;
    _mainScrollView.contentSize = CGSizeMake(_mainScrollView.frame.size.width*[self.mainArray count], _mainScrollView.frame.size.height);
    [self.view addSubview:_mainScrollView];

    if (!_mainView)
    {
        //主页视图
        _mainView = [[NT_MainView alloc] initWithFrame:CGRectMake(0, 0, _mainScrollView.frame.size.width, _mainScrollView.frame.size.height-55) type:AppListTypeHomeHot];
        _mainView.bottomRedHeight = _mainView.height-24;
        _mainView.tag = 200;
        _mainView.delegate = self;
        [_mainScrollView addSubview:_mainView];
    }
    else
    {
        if (![[[NT_HttpEngine sharedNT_HttpEngine] getCurrentNet] isEqualToString:NETNOTWORKING])
        {
            //有网络，刷新
            [_mainView getDataForPage:1];
        }
    }
    
    //友盟-热门-展示量
    umengLogRecHotListShow ++;
}

#pragma mark --
#pragma mark -- NTMainViewDelegate Delegate Methods
//导航到下一页
- (void)pushNextViewController:(UIViewController *)nextViewController
{
    [self.navigationController pushViewController:nextViewController animated:YES];
}

//跳到itunes
- (void)presentToItunes:(NSString *)appleID itunesButton:(UIButton *)btn
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
        [self openAppWithIdentifier:appleID];
    }else
    {
        [self outerOpenAppWithIdentifier:appleID goAppStore:btn];
    }
}

//ios6以上 itunes下载
- (void)openAppWithIdentifier:(NSString *)appId {
    SKStoreProductViewController *storeProductVC = [[SKStoreProductViewController alloc] init];
    storeProductVC.delegate = self;
    
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
            [self presentViewController:storeProductVC animated:YES completion:nil];
        }
        else
        {
            NSLog(@"storeproduct error:%@",[error description]);
        }
    }];
    //    NSString *str = [NSString stringWithFormat:@"http://itms-apps://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@",appId];
    //    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    //    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/us/app/id%@?mt=8",appId]]];
}

// ios6 以下设备到itunes
- (void)outerOpenAppWithIdentifier:(NSString *)appId  goAppStore:(UIButton*)btn{
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
        if (isIOS7) {
            viewController.navigationController.view.top = 20;
            viewController.view.height = [NTAppDelegate shareNTAppDelegate].window.height - 20;
            /*
             [NTAppDelegate shareNTAppDelegate].mainController.navigationController.view.top = 20;
             [NTAppDelegate shareNTAppDelegate].mainController.navigationController.view.height = [NTAppDelegate shareNTAppDelegate].window.height - 20;
             */
        }
    }];
}

- (void)hiddenLoading:(UITapGestureRecognizer *)tap
{
    if (tap) {
        [self.view removeGestureRecognizer:tap];
    }
    [self.view hideLoading];
}


- (void)gotoChange:(UIButton *)sender
{
    if (sender != _seletBt) {
        [self _slideIndex:(sender.tag - 10)];
        _seletBt = sender;
        CGRect newFrame = self.mainScrollView.frame;
        newFrame.origin.x = self.mainScrollView.frame.size.width*(sender.tag -10);
        [self.mainScrollView scrollRectToVisible:newFrame animated:YES];
    }
}

#pragma mark --
#pragma mark -- UIScrollView Delegate Methods
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.mainScrollView == scrollView) {
        CGFloat pageWidth = scrollView.frame.size.width;
        int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;//根据坐标算页数
        NSLog(@"dddd=====%i",page);
        [self _slideIndex:page];
    }
}

//选项卡-下一栏
- (void)_slideIndex:(int)page
{
    if (_currnetPage != page) {
        UIImageView *line = (UIImageView *)[_slide viewWithTag:100];
        
        [UIView animateWithDuration:0.2 animations:^{
            if (self.mainArray.count == 4) {
                line.center = CGPointMake(80*page + 80/2, 39);
            }
            else
            {
                line.center = CGPointMake(107*page + 107/2, 39);

            }
        } completion:^(BOOL finished) {
            for (int i = 0; i < [self.mainArray count]; i++) {
                UIButton *textBt = (UIButton *)[_slide viewWithTag:10 + i];
                //[textBt setTitleColor:[UIColor colorWithHex:@"#8c9599"] forState:UIControlStateNormal];
                [textBt setTitleColor:Text_Color_Title forState:UIControlStateNormal];
            }
            UIButton *textBt = (UIButton *)[_slide viewWithTag:10+page];
            _seletBt = textBt;
            [textBt setTitleColor:[UIColor colorWithHex:@"#1eb5f7"] forState:UIControlStateNormal];
        }];
        
    }
    _currnetPage = page;
    
    switch (page) {
        case 1:
        {
            //必备
            if (!_topClassical) {
                _topClassical = [[NT_MainView alloc] initWithFrame:CGRectMake(_mainScrollView.width*1, 0, _mainScrollView.width, _mainScrollView.height-55) type:AppListTypeTopClassical];
                _topClassical.tag = 200 + page;
                _topClassical.bottomRedHeight = _mainView.height-24;
                _topClassical.delegate = self;
                [_mainScrollView addSubview:_topClassical];
                
                
            }
            else
            {
                if (![[[NT_HttpEngine sharedNT_HttpEngine] getCurrentNet] isEqualToString:NETNOTWORKING])
                {
                    //有网络，刷新
                    [_topClassical getDataForPage:1];
                }
                
            }
            
            //必备-展示量
            umengLogRecZjbbListShow++;
        }
            break;
        case 2:
        {
            //网游
            if (!_onlineGame) {
                _onlineGame = [[NT_MainView alloc] initWithFrame:CGRectMake(_mainScrollView.width*2, 0, _mainScrollView.frame.size.width, _mainScrollView.frame.size.height-55) type:AppListTypeGameOnlineHot];
                _onlineGame.bottomRedHeight = _mainView.height-24;
                _onlineGame.isOnlineGame = YES;
                _onlineGame.tag = 200 + page;
                _onlineGame.delegate = self;
                [_mainScrollView addSubview:_onlineGame];
                
            }
            else
            {
                if (![[[NT_HttpEngine sharedNT_HttpEngine] getCurrentNet] isEqualToString:NETNOTWORKING])
                {
                    //有网络，刷新
                    [_onlineGame getDataForPage:1];
                }
                
            }
            //网游-展示量
            umengLogRecWlyxListShow++;
            
        }
            break;
        case 3:
        {
            //无限金币
            if (!_goldTableView) {
                _goldTableView = [[NT_CategoryView alloc] initWithFrame:CGRectMake(_mainScrollView.width*3, 0, _mainScrollView.width, _mainScrollView.height-55) categoryType:@"YSCategoryUserView" categoryId:23 sortType:SortTypeHotest isOnlineGame:NO];
                _goldTableView.tag = 200+page;
                _goldTableView.bottomRedHeight = _mainView.height-24;
                _goldTableView.isOnlineGame = NO;
                _goldTableView.delegate = self;
                [_mainScrollView addSubview:_goldTableView];
            }
            else
            {
                if (![[[NT_HttpEngine sharedNT_HttpEngine] getCurrentNet] isEqualToString:NETNOTWORKING])
                {
                    //有网络，刷新
                    [_goldTableView getDataForPage:1];
                }
                
            }
            //无限金币-展示量
            umengLogRecNoLimitGoldListShow++;
        };
            break;
        default:
            break;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    //判断视图是否消失，若消失则将无限金币的弹出框收起
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShouldHideInstallCell object:self];
}

- (void)clear
{
    self.mainScrollView = nil;
    self.mainArray = nil;
    self.appDetailInfo = nil;
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

@end
