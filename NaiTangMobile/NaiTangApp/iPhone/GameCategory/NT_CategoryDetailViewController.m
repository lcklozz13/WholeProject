//
//  NT_CategoryDetailViewController.m
//  NaiTangApp
//
//  Created by 张正超 on 14-3-3.
//  Copyright (c) 2014年 张正超. All rights reserved.
//

#import "NT_CategoryDetailViewController.h"
#import "NT_CategoryView.h"

@interface NT_CategoryDetailViewController ()
{
    BOOL _isLoading;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _isRefreshing;
}

@end

@implementation NT_CategoryDetailViewController

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
    //self.navigationItem.title = self.categoryName;
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLable.font = [UIFont boldSystemFontOfSize:20];
    titleLable.textColor = [UIColor whiteColor];
    titleLable.backgroundColor = [UIColor clearColor];
    titleLable.text = self.categoryName;
    titleLable.textAlignment = TEXT_ALIGN_CENTER;
    [titleLable sizeToFit];
    self.navigationItem.titleView = titleLable;

    self.view.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1.0];
    
    //设置底部兼容信息y值
    //[[NSUserDefaults standardUserDefaults] setFloat:SCREEN_HEIGHT-(64+49+21) forKey:KBottomInfo];
    //[[NSUserDefaults standardUserDefaults] synchronize];
    
    //返回按钮
    UIButton *backBtn= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [backBtn setImage:[UIImage imageNamed:@"top-back.png"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(gotoLeft:) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setImage:[UIImage imageNamed:@"top-back-hover.png"] forState:UIControlStateHighlighted];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    if (isIOS7)
    {
        //设置ios7导航栏两边间距，和ios6以下两边间距一致
        UIBarButtonItem *spaceBar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
        spaceBar.width = -10;
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:spaceBar,barItem, nil];
    }
    else
    {
        self.navigationItem.leftBarButtonItem = barItem;
    }
    
    //添加返回手势
    UISwipeGestureRecognizer *recongizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(recongnizerClick:)];
    [recongizer setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:recongizer];
    
    //刷新头部
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0 - self.view.bounds.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    _refreshHeaderView.delegate = self;
    _refreshHeaderView.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:_refreshHeaderView];
    [_refreshHeaderView refreshLastUpdatedDate];

    
    //分类详情
    //一级控制器的左右滑动scrollView
    if (isIOS7)
    {
         _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, ScreenHeight - (44+49))];
    }
    else
    {
         _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, ScreenHeight - (44+49))];
    }
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.pagingEnabled = YES;
    _scrollView.bounces = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.autoresizesSubviews = NO;
    _scrollView.backgroundColor = [UIColor lightTextColor];
    [self.view addSubview:_scrollView];
    //调整阴影层级，将导航栏阴影遮住tableview
    //[self.view exchangeSubviewAtIndex:3 withSubviewAtIndex:1];
    
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _scrollView.frame.size.height);

    [self getData];
    
    // 友盟统计-分类（找游戏）-子分类-展示量
    umengLogFindGameAll_Show++;

}

- (void)getData
{
    _isLoading = YES;
    [_refreshHeaderView setState:EGOOPullRefreshLoading];
    self.scrollView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
    
    [self.scrollView removeAllSubViews];
    [self.scrollView addSubview:_refreshHeaderView];
    
    
    //分类详情
    NT_CategoryView *hotListView = [[NT_CategoryView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.scrollView.height-20) linkId:self.linkID linkType:self.linkType isOnline:NO sortType:self.sortType];
    hotListView.delegate = self;
    hotListView.bottomRedHeight = hotListView.height-24;
    [self.scrollView addSubview:hotListView];

    
    [self perform:^{
        [self doneLoadingTableViewData];
    } afterDelay:0.1];
}

#pragma mark --
#pragma mark -- NTMainViewDlegate Delegate Methods
- (void)pushNextViewController:(UIViewController *)nextViewController
{
    [self.navigationController pushViewController:nextViewController animated:YES];
}

-(void)reloadTableViewDataSource
{
    _isRefreshing = YES;
    [self getData];
}

-(void)doneLoadingTableViewData
{
    _isRefreshing = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.scrollView];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)resetLastUpdateDate
{
    [USERDEFAULT setObject:[NSDate date] forKey:[self currentLastDateKey]];
    [USERDEFAULT synchronize];
}
- (NSString *)currentLastDateKey
{
    NSString *userdefaultKey = [NSString stringWithFormat:@"CategoryAppView"];
    return userdefaultKey;
}
#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
	[self reloadTableViewDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return _isLoading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
    
    NSDate *date = [USERDEFAULT objectForKey:[self currentLastDateKey]];
    if (![date isKindOfClass:[NSDate class]]) {
        date = nil;
    }
    if (!date) {
        return [[NSDate date] dateafterMonth:1];
    }
	return [NSDate date];
}

//返回手势
- (void)recongnizerClick:(UISwipeGestureRecognizer *)recongizer
{
    if (recongizer.direction == UISwipeGestureRecognizerDirectionRight) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//返回
- (void)gotoLeft:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clear
{
    self.scrollView = nil;
    self.titleLabel = nil;
    self.categoryID = 0;
    self.categoryType = nil;
    self.isOnlineGame = false;
    self.sortType = 0;
    self.linkType = 0;
    self.linkID = 0;
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
