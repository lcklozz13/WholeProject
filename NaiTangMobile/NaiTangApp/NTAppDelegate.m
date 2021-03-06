//
//  NTAppDelegate.m
//  NaiTangApp
//
//  Created by 张正超 on 14-2-26.
//  Copyright (c) 2014年 张正超. All rights reserved.
//

#import "NTAppDelegate.h"
#import "NT_UncaughtExceptionHandler.h"
#import "NT_HttpEngine.h"
#import "BaiduMobStat.h"
#import "NT_SettingManager.h"
#import "MobileInstallationInstallManager.h"
#import "NT_InstallAppInfo.h"
#import "NT_UpdateAppInfo.h"
#import "NT_MainViewController.h"
#import "NT_DownloadViewController.h"
#import "NT_CategoryViewController.h"
#import "NT_RankingViewController.h"
#import "NT_SearchViewController.h"
#import "NT_DownloadManager.h"

#import "NT_MacroDefine.h"
#import "NT_UserGuidesViewController.h"
#import "RightViewController.h"

// 友盟统计
#import "MobClick.h"
#import "HTTPServer.h"

@interface NTAppDelegate()
@property (nonatomic, strong) HTTPServer *httpServer;

@end

@implementation NTAppDelegate

+ (NTAppDelegate *)shareNTAppDelegate
{
	return (NTAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _installProxyStarted = NO;
    //处理异常
    InstallUncaughtExceptionHandler();
    
    [NT_HttpEngine sharedNT_HttpEngine];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    //友盟统计
    //    [self youMengMobile];
    //参数为NSString * 类型,自定义app版本信息，如果不设置，默认从CFBundleVersion里取
    [MobClick setAppVersion:XcodeAppVersion];
    
    // 开启友盟统计，频道id为默认的App Store，统计的提交方式为SEND_ON_EXIT 退出或进入后台时发送
    if ([[UIDevice currentDevice] isJailbroken])
    {
        //越狱
        [MobClick startWithAppkey:@"53294d1656240b0ce8004bd5" reportPolicy:(ReportPolicy) SEND_ON_EXIT  channelId:nil];
    }
    else
    {
        //正版
        [MobClick startWithAppkey:@"53294de556240b0cf7005868" reportPolicy:(ReportPolicy) SEND_ON_EXIT  channelId:nil];
    }
    
    // 初始化数值型统计的数字
    [self initYoumengLog];
    
    //增加标识，用于判断是否是第一次启动应用...
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"everLaunched"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"everLaunched"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"])
    {
        self.window.alpha = 0;
        //首先加载根视图，引导页显示时，是需要显示默认视图的。所以在引导页后3s，加载主页视图
        [self loadRootViewControl:application];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.window.alpha = 1;
            //用户指引界面
            NT_UserGuidesViewController *appStartController = [[NT_UserGuidesViewController alloc] init];
            self.window.rootViewController = appStartController;
        }];
    }else {
        [self loadRootViewControl:application];
        [self loadRootData];
    }

    [self.window makeKeyAndVisible];
    return YES;
}

//加载根控制器
- (void)loadRootViewControl:(UIApplication *)application
{
    [NT_DownloadManager sharedNT_DownLoadManager];
    
    if (isIphone)
    {
        self.tabController = [[UITabBarController alloc] init];
        
        //推荐
        self.mainController = [[NT_MainViewController alloc] init];
        UINavigationController *mainNavigation = [[UINavigationController alloc] initWithRootViewController:self.mainController];
       
//        UITabBarItem *mainItem = [[UITabBarItem alloc]initWithTitle:@"推荐" image:[UIImage imageNamed:@"bottom-rec.png"] selectedImage:[UIImage imageNamed:@"bottom-rec-hover.png"]];
        UITabBarItem *mainItem = [[UITabBarItem alloc] initWithTitle:@"推荐" image:nil tag:0];
        [mainItem setFinishedSelectedImage:[UIImage imageNamed:@"bottom-rec-hover.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"bottom-rec.png"]];
        
        
        mainItem.imageInsets = UIEdgeInsetsMake(-4, 0, 4, 0);
        [mainItem setTitlePositionAdjustment:UIOffsetMake(0, -2)];
        mainNavigation.tabBarItem = mainItem;
        
        //分类
        NT_CategoryViewController *categoryController = [[NT_CategoryViewController alloc] init];
        UINavigationController *categoryNavigation = [[UINavigationController alloc] initWithRootViewController:categoryController];
        UITabBarItem *categoryItem = [[UITabBarItem alloc] initWithTitle:@"分类" image:nil tag:1];
        [categoryItem setFinishedSelectedImage:[UIImage imageNamed:@"bottom-catogray-hover.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"bottom-catogray.png"]];
        categoryItem.imageInsets = UIEdgeInsetsMake(-4, 0, 4, 0);
        [categoryItem setTitlePositionAdjustment:UIOffsetMake(0, -2)];
        categoryNavigation.tabBarItem = categoryItem;
        
        //排行
        NT_RankingViewController *rankingController = [[NT_RankingViewController alloc] init];
        UINavigationController *rankingNavigation = [[UINavigationController alloc] initWithRootViewController:rankingController];
        UITabBarItem *rankingItem = [[UITabBarItem alloc] initWithTitle:@"排行" image:nil tag:2];
        [rankingItem setFinishedSelectedImage:[UIImage imageNamed:@"bottom-rank-hover.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"bottom-rank.png"]];
        rankingItem.imageInsets = UIEdgeInsetsMake(-4, 0, 4, 0);
        [rankingItem setTitlePositionAdjustment:UIOffsetMake(0, -2)];
        rankingNavigation.tabBarItem = rankingItem;
        
        //搜索
        NT_SearchViewController *searchController = [[NT_SearchViewController alloc] init];
        UINavigationController *searchNavigation = [[UINavigationController alloc] initWithRootViewController:searchController];
        UITabBarItem *searchItem = [[UITabBarItem alloc] initWithTitle:@"搜索" image:nil tag:3];
        [searchItem setFinishedSelectedImage:[UIImage imageNamed:@"bottom-search-hover.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"bottom-search.png"]];
        searchItem.imageInsets = UIEdgeInsetsMake(-4, 0, 4, 0);
        [searchItem setTitlePositionAdjustment:UIOffsetMake(0, -2)];
        searchNavigation.tabBarItem = searchItem;
        
        //下载
        NT_DownloadViewController *downloadController = [[NT_DownloadViewController alloc] init];
        UINavigationController *downloadNavigation = [[UINavigationController alloc] initWithRootViewController:downloadController];
        UITabBarItem *downloadItem = [[UITabBarItem alloc] initWithTitle:@"下载" image:nil tag:4];
        [downloadItem setFinishedSelectedImage:[UIImage imageNamed:@"bottom-download-hover.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"bottom-download.png"]];
        downloadItem.imageInsets = UIEdgeInsetsMake(-4, 0, 4, 0);
        [downloadItem setTitlePositionAdjustment:UIOffsetMake(0, -2)];
        downloadNavigation.tabBarItem = downloadItem;
        
        /*
         if (isIOS7)
         {
         UIImage *image = [UIImage imageNamed:@"bottom-download-hover.png"];
         UIImage *selectedImage = [UIImage imageNamed:@"bottom-download.png"];
         downloadController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"下载" image:image selectedImage:selectedImage];
         downloadController.tabBarItem.imageInsets = UIEdgeInsetsMake(-4, 0, 4, 0);
         [downloadController.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -2)];
         downloadNavigation.tabBarItem = downloadController.tabBarItem;
         }
         else
         {
         UITabBarItem *downloadItem = [[UITabBarItem alloc] initWithTitle:@"下载" image:nil tag:4];
         [downloadItem setFinishedSelectedImage:[UIImage imageNamed:@"bottom-download-hover.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"bottom-download.png"]];
         downloadItem.imageInsets = UIEdgeInsetsMake(-4, 0, 4, 0);
         [downloadItem setTitlePositionAdjustment:UIOffsetMake(0, -2)];
         downloadNavigation.tabBarItem = downloadItem;
         }
         */
        self.tabController.viewControllers = [NSArray arrayWithObjects:mainNavigation,categoryNavigation,rankingNavigation,searchNavigation,downloadNavigation, nil];
        
        //self.tabController.tabBar.tintColor = [UIColor colorWithHex:@"#f8f8f8"];
        
        
        if (isIOS7)
        {
            
            //[[UINavigationBar appearance] setBarTintColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"top-bk.png"]]];
            
            [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithHex:@"#05aaf1"]];
            [application setStatusBarStyle:UIStatusBarStyleLightContent];
            
            
        }
        else if(isIOS6)
        {
            [application setStatusBarStyle:UIStatusBarStyleBlackOpaque];
            [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"top-bk.png"] forBarMetrics:UIBarMetricsDefault];
            //去掉导航栏底部阴影
            //[[UINavigationBar appearance] setShadowImage:[UIImage imageNamed:@"tabbar-line.png"]];
            [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
            //网游跳转到itunes，不需要colorWithPatternImage
            //[[UINavigationBar appearance] setTintColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"top-bk.png"]]];
            //[[UINavigationBar appearance] setTintColor:[UIColor colorWithHex:@"#05aaf1"]];
            [[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"bk.png"]];
            //去掉阴影
            [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
        }
        else
        {
            [application setStatusBarStyle:UIStatusBarStyleBlackOpaque];
            [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"top-bk.png"] forBarMetrics:UIBarMetricsDefault];
            [[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"bk.png"]];
            
        }
        
        
        //设置navigationbar字体颜色
        [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor,nil]];
        //未选中tab的字体
        [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorWithHex:@"#8c9599"], UITextAttributeTextColor,
                                                           [UIFont systemFontOfSize:12], UITextAttributeFont,
                                                           nil] forState:UIControlStateNormal];
        
        //选中tab的字体
        [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorWithHex:@"#ffffff"], UITextAttributeTextColor,
                                                           [UIFont systemFontOfSize:12], UITextAttributeFont,
                                                           nil] forState:UIControlStateSelected];
        
        
        
        //tab的顶部阴影
        //[[UITabBar appearance] setShadowImage:[UIImage imageNamed:@"line.png"]];
        //tab选中图片无颜色
        //[[UITabBar appearance] setSelectionIndicatorImage:[[UIImage alloc] init]];
        
        //self.tabController.tabBar.selectionIndicatorImage = [UIImage imageNamed:@"bk_button.png"];
        [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"bk_button.png"]];

        self.window.rootViewController = self.tabController;
    }
    [[NT_DownloadManager sharedNT_DownLoadManager] somethingRemoved];
}

//加载数据
- (void)loadRootData
{
    //修复闪退
    [self repairFlashBack];
    
    //这些都放到主页计算
    //获取游戏更新数量
    //[self getGameUpdateCount];
    /*
    //若无更新信息，不需要弹框提示无更新
    RightViewController *rightController = [[RightViewController alloc] init];
    rightController.isNoShowUpdate = YES;
    [rightController updateNaitangVersion];
    */
    
    /**
     ASI缓存
     */
    ASIDownloadCache * cache = [[ASIDownloadCache alloc] init];
    self.myCache = cache;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    [self.myCache setStoragePath:[documentDirectory stringByAppendingPathComponent:@"resource"]];
    [self.myCache setDefaultCachePolicy:ASIAskServerIfModifiedCachePolicy |
     ASIFallbackToCacheIfLoadFailsCachePolicy];
}

//by thilong
-(void)setDownloadBadgeValue:(NSString *)val
{
    UITabBarController *tabController = self.tabController;
    [[tabController.tabBar.items objectAtIndex:4] setBadgeValue:val];
}

- (NSString *)getFilePath
{
    //正版设备访问iTunes_Control，可以使用越狱（私有）路径调用
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager changeCurrentDirectoryPath:@"/var/mobile/Media/iTunes_Control/iTunes"];
    NSString *path = [manager currentDirectoryPath];
    NSLog(@"现在的路径是:%@",path);
    return path;
}

//修复闪退
- (void)repairFlashBack
{
    //只判断一次，所有pc的数据和设备的数据一样的话，就不用再次读取了
    NSString *repaired= [[NSUserDefaults standardUserDefaults] objectForKey:KISRepaired];
    if (![repaired isEqualToString:@"YES"])
    {
        //获取路径iTunes_Control/iTunes 里的数据(企业账号)
        __block NSArray *accountArray = [NSArray array];
        
        __block NSMutableArray *md5AccountArray = [NSMutableArray array];
        [[NT_HttpEngine sharedNT_HttpEngine] getRepairedOnCompletionHandler:^(MKNetworkOperation *completedOperation) {
            [self getFilePath];
            
            //解析aspx或者其他格式，获取数据
            NSData *data = [completedOperation responseData];
            NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (dataString.length >0)
            {
                //查找位置，然后进行匹配
                // dataString = [dataString md5];
                //NSLog(@"account string:%@",dataString);
                accountArray = [dataString componentsSeparatedByString:@","];
                NSLog(@"account array:%@",accountArray);
                
                for (int i = 0; i<accountArray.count; i++)
                {
                    NSString *md5Data = [[accountArray objectAtIndex:i] md5];
                    [md5AccountArray addObject:md5Data];
                    
                }
                NSLog(@"md5data:%@",md5AccountArray);
            }
            
            int count = 0;
            if ([[NSFileManager defaultManager] fileExistsAtPath: [self getFilePath]])
            {
                //获取文件夹下所有的文件
                NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self getFilePath] error:NULL];
                for (int  i = 0; i < (int)[directoryContent count]; i++)
                {
                    NSString *fileName = [directoryContent objectAtIndex:i];
                    
                    for (int j=0; j<md5AccountArray.count; j++) {
                        NSString *md5Data = [md5AccountArray objectAtIndex:j];
                        if ([fileName isEqualToString:md5Data]) {
                            count++;
                        }
                    }
                    //NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
                    
                }
                //若文件数量全相同，则为已连接pc进行修复闪退
                if (count >= 14 && count<=accountArray.count)
                {
                    //统计修复过闪退成功次数，若修复过，只统计一次
                    //umengLogRepairSuccessedCount ++;
                    umengLogRepairSuccessedCount = 1;
                    
                    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:KISRepaired];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                else
                {
                    //未修复闪退，需要提示修复
                    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:KISRepaired];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
            
            //NSString *dataString = [completedOperation responseJSON];
            
        } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error){
            
        }];
    }
}

//获取游戏更新数量
- (void)getGameUpdateCount
{
    //获取游戏版本更新数量
    if ([NT_SettingManager showUpdateTips]) {
        NSMutableArray *installedArray = [NSMutableArray array];
        NSMutableString *identiferStr = [NSMutableString stringWithString:@""];
        [self perform:^{
            NSArray *arr = [MobileInstallationInstallManager IPAInstalled:nil];
            
            if (!arr) {
                arr = [MobileInstallationInstallManager browse];
            }
            
            for (int i = 0; i < arr.count; i++) {
                NT_InstallAppInfo *info = [NT_InstallAppInfo infoFromDic:[arr objectAtIndex:i]];
                if (identiferStr.length == 0) {
                    [identiferStr appendString:info.appIdentifier];
                }else
                {
                    [identiferStr appendString:[NSString stringWithFormat:@",%@",info.appIdentifier]];
                }
                [installedArray addObject:info];
            }
        } withCompletionHandler:^{
            [[NT_HttpEngine sharedNT_HttpEngine] getEnableUpdateListByIdentifer:identiferStr onCompletionHandler:^(MKNetworkOperation *completedOperation)
             {
                 NSDictionary *dic = [completedOperation responseJSON];
                 if ([[dic objectForKey:@"status"] boolValue]) {
                     if ([[dic objectForKey:@"data"] count])
                     {
                         NSArray *itemArray = [[dic objectForKey:@"data"] objectForKey:@"list"];
                         int iconBadgeNumber = 0;
                         for (NSDictionary *subDic in itemArray)
                         {
                             NT_UpdateAppInfo *updateInfo = [NT_UpdateAppInfo dictToInfo:subDic];
                             for (NT_InstallAppInfo *installInfo in installedArray) {
                                 if ([updateInfo.package isEqualToString:installInfo.appIdentifier]) {
                                     //                        NSLog(@"11111112:%@,%@",updateInfo.version_name,installInfo.appVersion);
                                     if ([NT_UpdateAppInfo versionCompare:updateInfo.version_name and:installInfo.appVersion]) {
                                         iconBadgeNumber++;
                                     }
                                     break;
                                 }
                             }
                         }
                         
                         //获取游戏可更新数量
                         [[NSUserDefaults standardUserDefaults] setInteger:iconBadgeNumber forKey:KUpdateCount];
                         [[NSUserDefaults standardUserDefaults] synchronize];
                         
                         [[UIApplication sharedApplication] setApplicationIconBadgeNumber:iconBadgeNumber];
                     }
                     
                 }
             } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
             }];
        }];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    
    // 友盟统计 数值型事件
    //    [MobClick event:@"umengLogRecListShow" attributes:@{@"__ct__":[NSString stringWithFormat:@"%d",umengLogRecListShow]}];
    //    [MobClick event:@"umengLogRecGameRecClick" attributes:@{@"__ct__":[NSString stringWithFormat:@"%d",umengLogRecGameRecClick]}];
    //    [MobClick event:@"umengLogRecTestListShow" attributes:@{@"__ct__":[NSString stringWithFormat:@"%d",umengLogRecTestListShow]}];
    //    [MobClick event:@"umengLogRecTestListClick" attributes:@{@"__ct__":[NSString stringWithFormat:@"%d",umengLogRecTestContClick]}];
    //    [MobClick event:@"umengLogRecVideoListShow" attributes:@{@"__ct__":[NSString stringWithFormat:@"%d",umengLogRecVideoListShow]}];
    //    [MobClick event:@"umengLogRecVideoContClick" attributes:@{@"__ct__":[NSString stringWithFormat:@"%d",umengLogRecVideoContClick]}];
    //    [MobClick event:@"umengLogRecGuideListShow" attributes:@{@"__ct__":[NSString stringWithFormat:@"%d",umengLogRecGuideListShow]}];
    //    [MobClick event:@"umengLogRecGuideContClick" attributes:@{@"__ct__":[NSString stringWithFormat:@"%d",umengLogRecGuideContClick]}];
    //    [MobClick event:@"umengLogRecQuesListShow" attributes:@{@"__ct__":[NSString stringWithFormat:@"%d",umengLogRecQuesListShow]}];
    //    [MobClick event:@"umengLogRecQuesContClick" attributes:@{@"__ct__":[NSString stringWithFormat:@"%d",umengLogRecQuesContClick]}];
    //    [MobClick event:@"umengLogRecXsmfListShow" attributes:@{@"__ct__":[NSString stringWithFormat:@"%d",umengLogRecXsmfListShow]}];
    //    [MobClick event:@"umengLogRecXsmfContClick" attributes:@{@"__ct__":[NSString stringWithFormat:@"%d",umengLogRecXsmfContClick]}];
    
    
    [MobClick event:@"umengLogRecHotListShow" attributes:@{@"__ct__":[NSString stringWithFormat:@"%d",umengLogRecHotListShow]}];
    [MobClick event:@"umengLogRecHotContClick" attributes:@{@"__ct__":[NSString stringWithFormat:@"%d",umengLogRecHotContClick]}];
    [MobClick event:@"umengLogRecNoLimitGoldListShow" attributes:@{@"__ct__":[NSString stringWithFormat:@"%d",umengLogRecNoLimitGoldListShow]}];
    [MobClick event:@"umengLogRecNoLimitGoldContClick" attributes:@{@"__ct__":[NSString stringWithFormat:@"%d",umengLogRecNoLimitGoldContClick]}];
    
    [MobClick event:@"umengLogRecZjbbListShow" attributes:@{@"__ct__":[NSString stringWithFormat:@"%d",umengLogRecZjbbListShow]}];
    [MobClick event:@"umengLogRecZjbbContClick" attributes:@{@"__ct__":[NSString stringWithFormat:@"%d",umengLogRecZjbbContClick]}];
    [MobClick event:@"umengLogRecWlyxListShow" attributes:@{@"__ct__":[NSString stringWithFormat:@"%d",umengLogRecWlyxListShow]}];
    [MobClick event:@"umengLogRecWlyxContClick" attributes:@{@"__ct__":[NSString stringWithFormat:@"%d",umengLogRecWlyxContClick]}];
    [MobClick event:@"umengLogRecRankListShow" attributes:@{@"__ct__":[NSString stringWithFormat:@"%d",umengLogRecRankListShow]}];
    [MobClick event:@"umengLogRecRankContClick" attributes:@{@"__ct__":[NSString stringWithFormat:@"%d",umengLogRecRankContClick]}];
    
    [MobClick event:@"umengLogSearchShow" attributes:@{@"__ct__":[NSString stringWithFormat:@"%d",umengLogSearchShow]}];
    [MobClick event:@"umengLogSearchUse" attributes:@{@"__ct__":[NSString stringWithFormat:@"%d",umengLogSearchUse]}];
    [MobClick event:@"umengLogSearchResultClick" attributes:@{@"__ct__":[NSString stringWithFormat:@"%d",umengLogSearchResultClick]}];
    
    [MobClick event:@"umengLogFindGameShow" attributes:@{@"__ct__":[NSString stringWithFormat:@"%d",umengLogFindGameShow]}];
    [MobClick event:@"umengLogFindGameAll_Show" attributes:@{@"__ct__":[NSString stringWithFormat:@"%d",umengLogFindGameAll_Show]}];
    [MobClick event:@"umengLogFindGameAll_DownloadClick" attributes:@{@"__ct__":[NSString stringWithFormat:@"%d",umengLogFindGameAll_DownloadClick]}];
    
    [MobClick event:@"umengLogGiftListShow" attributes:@{@"__ct__":[NSString stringWithFormat:@"%d",umengLogGiftListShow]}];
    [MobClick event:@"umengLogGiftDetailShow" attributes:@{@"__ct__":[NSString stringWithFormat:@"%d",umengLogGiftDetailShow]}];
    [MobClick event:@"umengLogGiftDetailGet" attributes:@{@"__ct__":[NSString stringWithFormat:@"%d",umengLogGiftDetailGet]}];
    [MobClick event:@"umengLogGiftDetailGetSuccess" attributes:@{@"__ct__":[NSString stringWithFormat:@"%d",umengLogGiftDetailGetSuccess]}];
    
    //修复闪退成功次数
    [MobClick event:@"umengLogRepairSuccessedCount" attributes:@{@"__ct__":[NSString stringWithFormat:@"%d",umengLogRepairSuccessedCount]}];
    
    //设置-修复闪退帮助有用按钮点击次数
    [MobClick event:@"umengLogRepairedClick" attributes:@{@"__ct__":[NSString stringWithFormat:@"%d",umengLogRepairedClick]}];
    
    //设置-修复闪退帮助没用按钮点击次数
    [MobClick event:@"umengLogNoRepairedClick" attributes:@{@"__ct__":[NSString stringWithFormat:@"%d",umengLogNoRepairedClick]}];
    
    //初始化友盟统计
    [self initYoumengLog];
    
}

- (BOOL) beginHttpServer
{
    
    NSString *documentFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *installProxyDir = documentFolder;
    NSLog(@"install proxy:%@",installProxyDir);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:installProxyDir]) {
        //如果不存在安装专用文件夹，则创建
        [fileManager createDirectoryAtPath:installProxyDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    self.httpServer = [[HTTPServer alloc] init] ;
    [self.httpServer setPort:8999];
    NSError *error = nil;
    [self.httpServer setDocumentRoot:documentFolder];
    if([self.httpServer start:&error])
    {
        _installProxyStarted = YES;
        return YES;
    }
    else{
        _installProxyStarted = NO;
        return NO;
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    __block    UIBackgroundTaskIdentifier bgTask;
    
    bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                
            }
        });
    }];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    //查看是否已经安装过了
    //by thilong. 2014-04-10
    [[NT_DownloadManager sharedNT_DownLoadManager] shouldRescanInstallApps];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kApplicationWillEnterForeground object:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    //by thilong,IMPORTANT,重新扫描所有安装的应用
    //by thilong. 2014-04-10
    //[[NT_DownloadManager sharedNT_DownLoadManager] shouldRescanInstallApps];
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)initYoumengLog
{
    // 初始化数值型统计的数字
    //    umengLogRecListShow = 0; // ok
    //    umengLogRecGameRecClick = 0; // ok
    //    umengLogRecTestListShow = 0; // ok
    //    umengLogRecTestContClick = 0; // ok
    //    umengLogRecVideoListShow = 0; // ok
    //    umengLogRecVideoContClick = 0; // ok
    //    umengLogRecGuideListShow = 0; // ok
    //    umengLogRecGuideContClick = 0; // ok
    //    umengLogRecQuesListShow = 0; // ok
    //    umengLogRecQuesContClick = 0; // ok
    //    umengLogRecXsmfListShow = 0; // ok
    //    umengLogRecXsmfContClick = 0; // ok
    umengLogRecHotListShow = 0;
    umengLogRecHotContClick = 0;
    umengLogRecNoLimitGoldContClick = 0;
    umengLogRecNoLimitGoldListShow = 0;
    umengLogRecZjbbListShow = 0; // ok
    umengLogRecZjbbContClick = 0; // ok
    umengLogRecWlyxListShow = 0; // ok
    umengLogRecWlyxContClick = 0; // ok
    umengLogRecRankListShow = 0; // ok
    umengLogRecRankContClick = 0; // ok
    
    umengLogSearchShow = 0; // ok
    umengLogSearchUse = 0; // ok
    umengLogSearchResultClick = 0; // ok
    
    umengLogFindGameShow = 0; // ok
    umengLogFindGameAll_Show = 0; // ok
    umengLogFindGameAll_DownloadClick = 0; // ok
    
    umengLogGiftListShow = 0; // ok
    umengLogGiftDetailShow = 0; // ok
    umengLogGiftDetailGet = 0; // ok
    umengLogGiftDetailGetSuccess = 0; // ok
    
    //友盟-修复闪退成功次数统计
    umengLogRepairSuccessedCount = 0; // ok
    
    //设置-修复闪退帮助有用按钮点击次数
    umengLogRepairedClick = 0; // ok
    
    //设置-修复闪退帮助没用按钮点击次数
    umengLogNoRepairedClick = 0; // ok
}

@end
