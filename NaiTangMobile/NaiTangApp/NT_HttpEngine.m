//
//  NT_HttpEngine.m
//  NaiTangApp
//
//  Created by 张正超 on 14-3-2.
//  Copyright (c) 2014年 张正超. All rights reserved.
//

#import "NT_HttpEngine.h"
#import "NT_Singleton.h"

@implementation NT_HttpEngine
SYNTHESIZE_SINGLETON_FOR_CLASS(NT_HttpEngine);

- (id)init
{
    if (self = [super initWithHostName:@"apitest.naitang.com"]) {
        //通知 (网络状态变化)
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
		//Change the host name here to change the server your monitoring
		internetReach = [Reachability reachabilityForInternetConnection];
		[internetReach startNotifier];
    }
    return self;
}
#pragma mark Reachability
//监视网络状态,状态变化调用该方法.
- (void) reachabilityChanged: (NSNotification* )note
{
	//	Reachability* curReach = [note object];
	//	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	//	BOOL connectionRequired= [hostReach connectionRequired];
    
	if ([internetReach currentReachabilityStatus] != NotReachable) {
		//网络可用  在这将记录的收藏等操作完成.
		NSLog(@"网络可用");
	}
	else {
		//网络不可用
		NSLog(@"网络不可用");
	}
}
- (BOOL)checkIsWifi
{
    if ([internetReach currentReachabilityStatus] == ReachableViaWiFi) {
        return YES;
    }
    return NO;
}
- (BOOL)isJailbroken
{
#ifdef INSTALLFORJailbroken
    return YES;
#endif
    return NO;
    static NSNumber *isJailbroken = nil;
    if (!isJailbroken) {
        isJailbroken = [NSNumber numberWithBool:[[UIDevice currentDevice] isJailbroken]];
    }
    return [isJailbroken boolValue];
}

- (NSString *)getCurrentNet
{
    NSString *resultStr;
    Reachability *reachablility = [Reachability reachabilityWithHostname:@"apitest.naitang.com"];
    switch ([reachablility currentReachabilityStatus]) {
        case NotReachable:
            resultStr = NETNOTWORKING;
            break;
        case ReachableViaWiFi:
            resultStr = NETWORKVIAWIFI;
            break;
        case ReachableViaWWAN:
            resultStr = NETWORKVIA3G;
            break;
        default:
            break;
    }
    return resultStr;
}

//修复闪退
- (MKNetworkOperation *)getRepairedOnCompletionHandler:(MKNKResponseBlock)response  errorHandler:(MKNKResponseErrorBlock)error
{
    MKNetworkOperation *op  = [self operationWithURLString:@"http://121.199.40.203:70/Default.aspx?Activity=AppIdList"];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}


//主页-最新推荐-头图标题
- (MKNetworkOperation *)getFocusOnCompletionHandler:(MKNKResponseBlock) response
                                       errorHandler:(MKNKResponseErrorBlock) error
{
    MKNetworkOperation *op = nil;
    op = [self operationWithPath:@"http://dev.dedecms.7k7k.com/json/appad/1_1.html"];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}


/*
//主页-最新推荐-头图标题
- (MKNetworkOperation *)getFocusOnCompletionHandler:(MKNKResponseBlock) response
                                       errorHandler:(MKNKResponseErrorBlock) error
{
    MKNetworkOperation *op = nil;
    if (isIpad) {
        op = [self operationWithPath:[[UIDevice currentDevice] isJailbroken] ? @"mobile/v1/index/focus_2_2.html" : @"mobile/v1/index/focus_2_1.html"];
    }else
    {
        op = [self operationWithPath:[[UIDevice currentDevice] isJailbroken] ? @"mobile/v1/index/focus_1_2.html" : @"mobile/v1/index/focus_1_1.html"];
    }
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *dic = [completedOperation responseJSON];
        if ([[dic objectForKey:@"status"] boolValue]) {
            self.focusDataArray = [dic objectForKey:@"data"];
        }
        response(completedOperation);
    } errorHandler:error];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}
*/

//主页-最新推荐-四个分类块(ipad)
- (MKNetworkOperation *)getFocusPadOnCompletionHandler:(MKNKResponseBlock) response
                                          errorHandler:(MKNKResponseErrorBlock) error
{
    MKNetworkOperation *op = [self operationWithPath:[[UIDevice currentDevice] isJailbroken] ? @"mobile/v1/index/ipadIndex_2_1.html" : @"mobile/v1/index/ipadIndex_2_2.html"];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *dic = [completedOperation responseJSON];
        if ([[dic objectForKey:@"status"] boolValue]) {
            self.linkDataArray = [dic objectForKey:@"data"];
        }
        response(completedOperation);
    } errorHandler:error];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
    
}

//主页-最新推荐
- (MKNetworkOperation *)getRecForPage:(int)page
                  OnCompletionHandler:(MKNKResponseBlock) response
                         errorHandler:(MKNKResponseErrorBlock) error
{
    NSString *urlString = nil;
    if (isIpad) {
        //rec_2(iPad)_2(越狱)_1(倒序)_
        urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/index/rec_2_2_1_%d.html",page] : [NSString stringWithFormat:@"mobile/v1/index/rec_2_1_1_%d.html",page];
    }else
    {
        //rec_2(iPhone)_2(正版)_1(倒序)_
        urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/index/rec_1_2_1_%d.html",page] : [NSString stringWithFormat:@"mobile/v1/index/rec_1_1_1_%d.html",page];
    }
    MKNetworkOperation *op = [self operationWithPath:urlString];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}


//所有列表-（游戏下载页面）应用详情
- (MKNetworkOperation *)getAppDetailInfoFor:(int)appID OnCompletionHander:(MKNKResponseBlock) response errorHandler:(MKNKResponseErrorBlock) error
{
    //NSString *urlString = [NSString stringWithFormat:@"mobile/info/1_%d.htm",appID];
    NSString *urlString = nil;
    if (isIpad) {
        urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/info/detail_2_2_%d.html",appID] : [NSString stringWithFormat:@"mobile/v1/info/detail_2_1_%d.html",appID];
    }else
    {
        urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/info/detail_1_2_%d.html",appID] : [NSString stringWithFormat:@"mobile/v1/info/detail_1_1_%d.html",appID];
    }
    
    NSLog(@"urlstring:%@",urlString);
    MKNetworkOperation *op = [self operationWithPath:urlString];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}


//主页-时下热门
- (MKNetworkOperation *)getCurrrentHotFor:(int)page OnCompletionHander:(MKNKResponseBlock) response errorHandler:(MKNKResponseErrorBlock) error
{
    NSString *urlString = nil;
    if (isIpad) {
        urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/index/rec_2_2_3_%d.html",page] : [NSString stringWithFormat:@"mobile/v1/index/rec_2_1_3_%d.html",page];
    }else
    {
        urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/index/rec_1_2_3_%d.html",page] : [NSString stringWithFormat:@"mobile/v1/index/rec_1_1_3_%d.html",page];
    }
    NSLog(@"urlString:%@",urlString);
    MKNetworkOperation *op = [self operationWithPath:urlString];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}

//主页-游戏专题
- (MKNetworkOperation *)getGameSpecialOnCompletionHander:(MKNKResponseBlock) response errorHandler:(MKNKResponseErrorBlock) error
{
    MKNetworkOperation *op = nil;
    op = [self operationWithPath:@"mobile/v1/special/list.html"];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}

// 主页-游戏专题-列表
- (MKNetworkOperation *)getTopicDetailWithId:(NSString *)infoId OnCompletionHander:(MKNKResponseBlock) response errorHandler:(MKNKResponseErrorBlock) error
{
    NSString *urlString = nil;
    if (isIpad) {
        urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/special/id_2_2_%@.html",infoId] : [NSString stringWithFormat:@"mobile/v1/special/id_2_1_%@.html",infoId];
    }else
    {
        urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/special/id_1_2_%@.html",infoId] : [NSString stringWithFormat:@"mobile/v1/special/id_1_1_%@.html",infoId];
    }
    MKNetworkOperation *op = [self operationWithPath:urlString];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}

//排行榜-上升最快（改为游戏排行）
- (MKNetworkOperation *)getTopUpForPage:(int)page
                    OnCompletionHandler:(MKNKResponseBlock) response
                           errorHandler:(MKNKResponseErrorBlock) error
{
    NSString *urlString = nil;
    if (isIpad) {
        urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/top/2_2_1_%d.html",page] : [NSString stringWithFormat:@"mobile/v1/top/2_1_1_%d.html",page];
    }else
    {
        urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/top/1_2_1_%d.html",page] : [NSString stringWithFormat:@"mobile/v1/top/1_1_1_%d.html",page];
    }
    MKNetworkOperation *op = [self operationWithPath:urlString];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}
//排行榜-近期最热
- (MKNetworkOperation *)getTopHotForPage:(int)page
                     OnCompletionHandler:(MKNKResponseBlock) response
                            errorHandler:(MKNKResponseErrorBlock) error
{
    NSString *urlString = nil;
    if (isIpad) {
        urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/top/2_2_2_%d.html",page] : [NSString stringWithFormat:@"mobile/v1/top/2_1_2_%d.html",page];
    }else
    {
        urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/top/1_2_2_%d.html",page] : [NSString stringWithFormat:@"mobile/v1/top/1_1_2_%d.html",page];
    }
    MKNetworkOperation *op = [self operationWithPath:urlString];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}
//排行榜-经典必备
- (MKNetworkOperation *)getTopNecessaryForPage:(int)page
                           OnCompletionHandler:(MKNKResponseBlock) response
                                  errorHandler:(MKNKResponseErrorBlock) error
{
    NSString *urlString = nil;
    if (isIpad) {
        urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/top/2_2_3_%d.html",page] : [NSString stringWithFormat:@"mobile/v1/top/2_1_3_%d.html",page];
    }else
    {
        urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/top/1_2_3_%d.html",page] : [NSString stringWithFormat:@"mobile/v1/top/1_1_3_%d.html",page];
    }
    MKNetworkOperation *op = [self operationWithPath:urlString];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}

//新装机必备
- (MKNetworkOperation *)getMainNecessaryForPage:(int)page pageSize:(int)pageSize OnCompletionHandler:(MKNKResponseBlock)response errorHandler:(MKNKResponseErrorBlock)error
{
    NSString *urlString = nil;
    
    if (isIpad) {
        urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/k7mobile/bibei/2_2_%d_%d.html",page,pageSize] : [NSString stringWithFormat:@"mobile/v1/k7mobile/bibei/2_1_3_%d_%d.html",page,pageSize];
    }else
    {
        urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/k7mobile/bibei/1_2_%d_%d.html",page,pageSize] : [NSString stringWithFormat:@"mobile/v1/k7mobile/bibei/1_1_%d_%d.html",page,pageSize];
    }
    NSLog(@"urlString:%@",urlString);
    MKNetworkOperation *op = [self operationWithPath:urlString];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}

//新整合的-分类
- (MKNetworkOperation *)getCategoryInfoCompletionHandler:(MKNKResponseBlock) response
                                            errorHandler:(MKNKResponseErrorBlock) error
{
    NSString *urlString  = @"mobile/v1/k7mobile/websetting/452_1_100.html";
    MKNetworkOperation *op = [self operationWithPath:urlString];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;

}

//新整合分类-通用列表详情
- (MKNetworkOperation *)getCategoryDetailInfoWithLinkType:(NSInteger)linkType
                                                   linkID:(NSInteger)linkID
                                               sortType:(SortType)type
                                                   page:(int)page
                                     OnCompletionHander:(MKNKResponseBlock) response
                                           errorHandler:(MKNKResponseErrorBlock) error
{
    NSString *urlString = nil;
    //NSString *categoryType = nil;
    //分类-游戏类别-列表详情
    switch (linkType)
    {
        case 1:
        {
            //categoryType = @"Game"; 1 游戏 Game
            if (isIpad) {
                urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/info/detail_2_2_%d.html",linkID] : [NSString stringWithFormat:@"mobile/v1/info/detail_2_1_%d.html",linkID];
            }
            else
            {
                urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/info/detail_1_2_%d.html",linkID] : [NSString stringWithFormat:@"mobile/v1/info/detail_1_1_%d.html",linkID];
            }
        }
            break;
        case 2:
        {
            //categoryType = @"Album"; 2 合辑 Album
            if (isIpad) {
                urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/album/gamelist_2_2_%d_%d_%d.html",linkID,type,page] : [NSString stringWithFormat:@"mobile/v1/album/gamelist_2_1_%d_%d_%d.html",linkID,type,page];
            }
            else
            {
                urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/album/gamelist_1_2_%d_%d_%d.html",linkID,type,page] : [NSString stringWithFormat:@"mobile/v1/album/gamelist_1_1_%d_%d_%d.html",linkID,type,page];
            }
        }
            break;
        case 3:
        {
            //categoryType = @"Special"; 3 专题 Special
            if (isIpad) {
                urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"special/id_2_2_%d.html",linkID] : [NSString stringWithFormat:@"special/id_2_1_%d.html",linkID];
            }
            else
            {
                urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"special/id_1_2_%d.html",linkID] : [NSString stringWithFormat:@"special/id_1_1_%d.html",linkID];
            }
        }
            break;
        case 4:
        {
            //categoryType = @"Tag"; 4 标签 Tag
            if (isIpad) {
                urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/tag/gamelist_2_2_%d_%d_%d.html",linkID,type,page] : [NSString stringWithFormat:@"mobile/v1/tag/gamelist_2_1_%d_%d_%d.html",linkID,type,page];
            }
            else
            {
                urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/tag/gamelist_1_2_%d_%d_%d.html",linkID,type,page] : [NSString stringWithFormat:@"mobile/v1/tag/gamelist_1_1_%d_%d_%d.html",linkID,type,page];
            }
        }
            break;
        case 5:
        {
            //categoryType = @"Category"; 5 分类 Category
            if (isIpad) {
                urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/category/list_2_2_%d_%d_%d.html",linkID,type,page] : [NSString stringWithFormat:@"mobile/v1/category/list_2_1_%d_%d_%d.html",linkID,type,page];
            }
            else
            {
                urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/category/list_1_2_%d_%d_%d.html",linkID,type,page] : [NSString stringWithFormat:@"mobile/v1/category/list_1_1_%d_%d_%d.html",linkID,type,page];
            }

        }
            break;
        default:
            break;
    }
    
    NSLog(@"category urlstring:%@",urlString);
    MKNetworkOperation *op = [self operationWithPath:urlString];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}

//新版游戏详情-资讯
- (MKNetworkOperation *)getDetailInfoWithGameID:(NSInteger)gameID categoryID:(int)categoryID page:(int)page pageSize:(int)pageSize CompletionHandler:(MKNKResponseBlock) response
                                       errorHandler:(MKNKResponseErrorBlock) error
{
    NSString *urlString = [NSString stringWithFormat:@"mobile/v1/k7mobile/arclist/%d_%d_%d_%d.html",gameID,categoryID,page,pageSize];
    NSLog(@"urlstring:%@",urlString);
    MKNetworkOperation *op = [self operationWithPath:urlString];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;

}

//新版游戏详情-大家还喜欢
- (MKNetworkOperation *)getDetailOtherGameWithCategoryID:(int)categoryID page:(int)page pageSize:(int)pageSize completionHandler:(MKNKResponseBlock) response
                                            errorHandler:(MKNKResponseErrorBlock) error
{
    NSString *urlString = nil;
    if (isIpad)
    {
        urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/k7mobile/catelike/2_2_%d_%d_%d.html",categoryID,page,pageSize] : [NSString stringWithFormat:@"mobile/v1/k7mobile/catelike/2_1_%d_%d_%d.html",categoryID,page,pageSize];
    }
    else
    {
        urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/k7mobile/catelike/1_2_%d_%d_%d.html",categoryID,page,pageSize] : [NSString stringWithFormat: @"mobile/v1/k7mobile/catelike/1_1_%d_%d_%d.html",categoryID,page,pageSize];
    }
    NSLog(@"urlString:%@",urlString);
    MKNetworkOperation *op =  [self operationWithPath:urlString];
    /*
    MKNetworkOperation *op = nil;
    if (isIpad) {
        op = [self operationWithPath:[[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/k7mobile/catelike/2_2_%d_%d_%d.html",categoryID,page,pageSize] : [NSString stringWithFormat:@"mobile/v1/k7mobile/catelike/2_1_%d_%d_%d.html",categoryID,page,pageSize]];
    }else
    {
        op = [self operationWithPath:[[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/k7mobile/catelike/1_2_%d_%d_%d.html",categoryID,page,pageSize] : [NSString stringWithFormat: @"mobile/v1/k7mobile/catelike/1_1_%d_%d_%d.html",categoryID,page,pageSize]];
    }
    */
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;

}

//分类-游戏类别-头图
- (MKNetworkOperation *)getGameCategoryCompletionHandler:(MKNKResponseBlock) response
                                            errorHandler:(MKNKResponseErrorBlock) error
{
    MKNetworkOperation *op = nil;
    if (isIpad) {
        op = [self operationWithPath:[[UIDevice currentDevice] isJailbroken] ? @"mobile/v1/category/index_2_2.html" : @"mobile/v1/category/index_2_1.html"];
    }else
    {
        op = [self operationWithPath:[[UIDevice currentDevice] isJailbroken] ? @"mobile/v1/category/index_1_2.html" : @"mobile/v1/category/index_1_1.html"];
    }
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}


//分类-通用列表详情
- (MKNetworkOperation *)getCategoryListWithId:(int)categoryId
                                 categoryType:(NSString *)categoryType
                                     sortType:(SortType)type
                                         page:(int)page
                           OnCompletionHander:(MKNKResponseBlock) response
                                 errorHandler:(MKNKResponseErrorBlock) error
{
    NSString *urlString = nil;
    //分类-游戏类别-列表详情
    if ([categoryType isEqualToString:@"BaseCategoryTableView"] || [categoryType isEqualToString:@"CategoryBaseTableView"])
    {
        if (isIpad) {
            urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/category/list_2_2_%d_%d_%d.html",categoryId,type,page] : [NSString stringWithFormat:@"mobile/v1/category/list_2_1_%d_%d_%d.html",categoryId,type,page];
        }
        else
        {
            urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/category/list_1_2_%d_%d_%d.html",categoryId,type,page] : [NSString stringWithFormat:@"mobile/v1/category/list_1_1_%d_%d_%d.html",categoryId,type,page];
        }
        
    }//分类-热门合集-列表详情
    else if ([categoryType isEqualToString:@"YSCategoryUserView"] || [categoryType isEqualToString:@"CategoryUseTableView"])
    {
        if (isIpad) {
            urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/album/gamelist_2_2_%d_%d_%d.html",categoryId,type,page] : [NSString stringWithFormat:@"mobile/v1/album/gamelist_2_1_%d_%d_%d.html",categoryId,type,page];
        }
        else
        {
            urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/album/gamelist_1_2_%d_%d_%d.html",categoryId,type,page] : [NSString stringWithFormat:@"mobile/v1/album/gamelist_1_1_%d_%d_%d.html",categoryId,type,page];
        }
        
    }//分类-热门推荐-列表详情
    else if ([categoryType isEqualToString:@"YSCategoryAppView"] || [categoryType isEqualToString:@"CategoryPadAppView"])
    {
        if (isIpad) {
            urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/tag/gamelist_2_2_%d_%d_%d.html",categoryId,type,page] : [NSString stringWithFormat:@"mobile/v1/tag/gamelist_2_1_%d_%d_%d.html",categoryId,type,page];
        }
        else
        {
            urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/tag/gamelist_1_2_%d_%d_%d.html",categoryId,type,page] : [NSString stringWithFormat:@"mobile/v1/tag/gamelist_1_1_%d_%d_%d.html",categoryId,type,page];
        }
        
    }
    
    
    NSLog(@"urlstring:%@",urlString);
    MKNetworkOperation *op = [self operationWithPath:urlString];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}

//分类-热门合辑
- (MKNetworkOperation *)getAppCategoryCompletionHandler:(MKNKResponseBlock) response
                                           errorHandler:(MKNKResponseErrorBlock) error
{
    NSString *urlString = nil;
    if (isIpad)
    {
        urlString = @"mobile/v1/album/list_2.html";
    }
    else
    {
        urlString = @"mobile/v1/album/list_1.html";
    }
    
    
    MKNetworkOperation *op = [self operationWithPath:urlString];
    //    MKNetworkOperation *op = [self operationWithPath:[[UIDevice currentDevice] isJailbroken] ? @"mobile/category/tag_1_2.htm" : @"mobile/category/tag_1_1.htm"];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}

//分类-热门推荐
- (MKNetworkOperation *)getAppRecommendCategoryCompletionHandler:(MKNKResponseBlock) response
                                                    errorHandler:(MKNKResponseErrorBlock) error
{
    NSString *urlString = nil;
    if (isIpad)
    {
        urlString = @"mobile/v1/tag/list_2.html";
    }
    else
    {
        urlString = @"mobile/v1/tag/list_1.html";
    }
    
    MKNetworkOperation *op = [self operationWithPath:urlString];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}

// 网络游戏-最新推荐-头图
- (MKNetworkOperation *)getOnlineGameNewFocusCompletionHandler:(MKNKResponseBlock) response
                                                  errorHandler:(MKNKResponseErrorBlock) error
{
    MKNetworkOperation *op = nil;
    self.focusDataArray = nil;
    self.linkDataArray = nil;
    if (isIpad) {
        op = [self operationWithPath:[[UIDevice currentDevice] isJailbroken] ? @"mobile/v1/net/focus_2_2.html" : @"mobile/v1/net/focus_2_1.html"];
        [op addCompletionHandler:response errorHandler:error];
        [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
            NSDictionary *dic = [completedOperation responseJSON];
            if ([[dic objectForKey:@"status"] boolValue]) {
                self.focusDataArray = [dic objectForKey:@"data"];
                self.linkDataArray = [dic objectForKey:@"link4"];
            }
            response(completedOperation);
        } errorHandler:error];
        [op addCompletionHandler:response errorHandler:error];
    }else
    {
        op = [self operationWithPath:[[UIDevice currentDevice] isJailbroken] ? @"mobile/v1/net/focus_1_2.html" : @"mobile/v1/net/focus_1_1.html"];
        [op addCompletionHandler:response errorHandler:error];
    }
    [self enqueueOperation:op];
    return op;
}


//网游-最新推荐
- (MKNetworkOperation *)getOnlineGameLastestForPage:(int)page
                                OnCompletionHandler:(MKNKResponseBlock) response
                                       errorHandler:(MKNKResponseErrorBlock) error
{
    NSString *urlString = nil;
    if (isIpad) {
        urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/net/newest_2_2_%d.html",page] : [NSString stringWithFormat:@"mobile/v1/net/newest_2_1_%d.html",page];
    }
    else
    {
        urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/net/newest_1_2_%d.html",page] : [NSString stringWithFormat:@"mobile/v1/net/newest_1_1_%d.html",page];
    }
    
    /*
     MKNetworkOperation *op = nil;
     if (isIpad) {
     op = [self operationWithPath:[[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/category/list_2_2_14_%d.htm",page] : [NSString stringWithFormat:@"mobile/category/list_2_1_14_%d.htm",page]];
     }else
     {
     op = [self operationWithPath:[[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/category/list_1_2_14_%d.htm",page] : [NSString stringWithFormat:@"mobile/category/list_1_1_14_%d.htm",page]];
     }
     */
    NSLog(@"urlstring:%@",urlString);
    MKNetworkOperation *op = [self operationWithPath:urlString];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}

//网游-热门网游
- (MKNetworkOperation *)getOnlineGameHotForPage:(int)page
                            OnCompletionHandler:(MKNKResponseBlock) response
                                   errorHandler:(MKNKResponseErrorBlock) error
{
    NSString *urlString = nil;
    if (isIpad) {
        urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/net/hot_2_2_%d.html",page] : [NSString stringWithFormat:@"mobile/v1/net/hot_2_1_%d.html",page];
    }
    else
    {
        urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/net/hot_1_2_%d.html",page] : [NSString stringWithFormat:@"mobile/v1/net/hot_1_1_%d.html",page];
    }
    NSLog(@"urlstring:%@",urlString);
    MKNetworkOperation *op = [self operationWithPath:urlString];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
    /*
     MKNetworkOperation *op = nil;
     if (isIpad) {
     op = [self operationWithPath:[[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/net/hot_2_2_%d.html",page] : [NSString stringWithFormat:@"mobile/v1/net/hot_2_1_%d.html",page]];
     }else
     {
     op = [self operationWithPath:[[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/net/hot_1_2_%d.html",page] : [NSString stringWithFormat:@"mobile/v1/net/hot_1_1_%d.html",page]];
     }
     [op addCompletionHandler:response errorHandler:error];
     [self enqueueOperation:op];
     return op;
     */
}

//网游-网游分类
- (MKNetworkOperation *)getOnlineGameCategoryCompletionHandler:(MKNKResponseBlock) response
                                                  errorHandler:(MKNKResponseErrorBlock) error
{
    NSString *urlString = nil;
    if (isIpad) {
        urlString = [[UIDevice currentDevice] isJailbroken] ? @"mobile/v1/netcat/list_2_2.html" : @"mobile/v1/netcat/list_2_1.html";
    }
    else
    {
        urlString = [[UIDevice currentDevice] isJailbroken] ? @"mobile/v1/netcat/list_1_2.html" : @"mobile/v1/netcat/list_1_1.html";
    }
    NSLog(@"urlstring:%@",urlString);
    MKNetworkOperation *op = [self operationWithPath:urlString];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
    
    /*
     MKNetworkOperation *op = nil;
     //    if (isIpad) {
     //        op = [self operationWithPath:@"mobile/category/online_1_1.htm"];
     //    }else
     {
     op = [self operationWithPath:[[UIDevice currentDevice] isJailbroken] ? @"mobile/category/network_1_2.htm" : @"mobile/category/network_1_1.htm"];
     }
     [op addCompletionHandler:response errorHandler:error];
     [self enqueueOperation:op];
     return op;
     */
}

//网游-网游分类-列表详情
- (MKNetworkOperation *)getOnlineGameListWithId:(int)categoryId
                                   categoryType:(NSString *)categoryType
                                       sortType:(SortType)type
                                           page:(int)page
                             OnCompletionHander:(MKNKResponseBlock) response
                                   errorHandler:(MKNKResponseErrorBlock) error
{
    NSString *urlString = nil;
    if (isIpad) {
        urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/netcat/gamelist_2_2_%d_%d_%d.html",categoryId,type,page] : [NSString stringWithFormat:@"mobile/v1/netcat/gamelist_2_1_%d_%d_%d.html",categoryId,type,page];
    }
    else
    {
        urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/netcat/gamelist_1_2_%d_%d_%d.html",categoryId,type,page] : [NSString stringWithFormat:@"mobile/v1/netcat/gamelist_1_1_%d_%d_%d.html",categoryId,type,page];
    }
    
    NSLog(@"urlstring:%@",urlString);
    MKNetworkOperation *op = [self operationWithPath:urlString];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}

// 搜索-热词
- (MKNetworkOperation *)getSearchDataCompletionHandler:(MKNKResponseBlock) response
                                          errorHandler:(MKNKResponseErrorBlock) error
{
    MKNetworkOperation *op = nil;
    /*
    if (isIpad) {
        op = [self operationWithPath:[[UIDevice currentDevice] isJailbroken] ? @"mobile/v1/search/index_2_2.html" : @"mobile/v1/search/index_2_1.html"];
    }else
    {
        op = [self operationWithPath:[[UIDevice currentDevice] isJailbroken] ? @"mobile/v1/search/index_1_2.html" : @"mobile/v1/search/index_1_1.html"];
    }
     */
    NSLog(@"urlString:%@",@"mobile/v1/k7mobile/websetting/52_1_1.html");
    op = [self operationWithPath:@"mobile/v1/k7mobile/websetting/52_1_1.html"];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}


// 搜索关键词结果
- (MKNetworkOperation *)getSearchResultWithKeyWord:(NSString *)keyWord page:(int)page CompletionHandler:(MKNKResponseBlock) response
                                      errorHandler:(MKNKResponseErrorBlock) error
{
    NSString *urlString = nil;
    if (isIpad) {
        urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile_v1.php?action=search&op=result&product=2&version_type=2&key=%@&page=%d",keyWord,page] : [NSString stringWithFormat:@"mobile_v1.php?action=search&op=result&product=2&version_type=1&key=%@&page=%d",keyWord,page];
    }else
    {
        urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile_v1.php?action=search&op=result&product=1&version_type=2&key=%@&page=%d",keyWord,page] : [NSString stringWithFormat:@"mobile_v1.php?action=search&op=result&product=1&version_type=1&key=%@&page=%d",keyWord,page];
    }
    
    NSLog(@"urlstring:%@",urlString);
    MKNetworkOperation *op = [self operationWithPath:urlString];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}

// 搜索提示
- (MKNetworkOperation *)getSearchNoticeWithKeyWord:(NSString *)keyWord CompletionHandler:(MKNKResponseBlock) response
                                      errorHandler:(MKNKResponseErrorBlock) error
{
    //NSString *path = [NSString stringWithFormat:@"mobile.php?action=search&op=sotitle&q=%@",keyWord];
    NSString *urlString = nil;
    if (isIpad)
    {
        urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile_v1.php?action=search&op=sotitle&product=2&version_type=2&keyword=%@",keyWord] : [NSString stringWithFormat:@"mobile_v1.php?action=search&op=sotitle&product=2&version_type=1&keyword=%@",keyWord];
    }
    else
    {
        urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile_v1.php?action=search&op=sotitle&product=1&version_type=2&keyword=%@",keyWord] : [NSString stringWithFormat:@"mobile_v1.php?action=search&op=sotitle&product=1&version_type=1&keyword=%@",keyWord];
    }
    NSLog(@"urlString:%@",urlString);
    //NSString *path = [NSString stringWithFormat:@"mobile_v1.php?action=search&op=sotitle&product=1&version_type=1&keyword=%@",keyWord];
    MKNetworkOperation *op = [self operationWithPath:urlString];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}

//开发商信息
- (MKNetworkOperation *)getDeveloperInfo:(int)developerID OnCompletionHander:(MKNKResponseBlock) response errorHandler:(MKNKResponseErrorBlock) error
{
    NSString *urlString = nil;
    if (isIpad) {
        urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/dev/info_%d.html",developerID] : [NSString stringWithFormat:@"mobile/v1/dev/info_%d.html",developerID];
    }
    else
    {
        urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/dev/info_%d.html",developerID] : [NSString stringWithFormat:@"mobile/v1/dev/info_%d.html",developerID];
    }
    MKNetworkOperation *op = [self operationWithPath:urlString];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}

//开发商旗下应用
- (MKNetworkOperation *)getDeveloperID:(int)developerID andAppPage:(int)page OnCompletionHander:(MKNKResponseBlock) response errorHandler:(MKNKResponseErrorBlock) error
{
    NSString *urlString = nil;
    if (isIpad) {
        urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/dev/list_2_2_%d_%d.html",developerID,page] : [NSString stringWithFormat:@"mobile/v1/dev/list_2_1_%d_%d.html",developerID,page];
    }
    else
    {
        urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/dev/list_1_2_%d_%d.html",developerID,page] : [NSString stringWithFormat:@"mobile/v1/dev/list_1_1_%d_%d.html",developerID,page];
    }
    
    /*
     NSString *urlString = nil;
     if (isIpad) {
     urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/dev/info_2_2_%d_%d.html",developerID,page] : [NSString stringWithFormat:@"mobile/v1/dev/info_2_1_%d_%d.html",developerID,page];
     }
     else
     {
     urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/dev/info_1_2_%d_%d.html",developerID,page] : [NSString stringWithFormat:@"mobile/v1/dev/info_1_1_%d_%d.html",developerID,page];
     }
     */
    NSLog(@"urlstring:%@",urlString);
    MKNetworkOperation *op = [self operationWithPath:urlString];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
    
    /*
     NSString *urlString = [[UIDevice currentDevice] isJailbroken] ?[NSString stringWithFormat:@"mobile/dev/list_1_2_%d_%d.htm",deceloperID,page]:[NSString stringWithFormat:@"mobile/dev/list_1_1_%d_%d.htm",deceloperID,page];
     MKNetworkOperation *op = [self operationWithPath:urlString];
     [op addCompletionHandler:response errorHandler:error];
     [self enqueueOperation:op];
     return op;
     */
}


//首页-活动专题游戏列表
- (MKNetworkOperation *)getGameActiveSpecialOnCompletionHander:(MKNKResponseBlock) response errorHandler:(MKNKResponseErrorBlock) error
{
    MKNetworkOperation *op = [self operationWithPath:[[UIDevice currentDevice] isJailbroken] ? @"mobile/special/1_2_4.htm" : @"mobile/special/1_1_4.htm"];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}

// 根据包名 获取游戏详情页面
- (MKNetworkOperation *)getAppDetailInfoByPackage:(NSString *)package OnCompletionHander:(MKNKResponseBlock) response errorHandler:(MKNKResponseErrorBlock) error
{
    NSString *urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/package/%@_2_2.htm",package] : [NSString stringWithFormat:@"mobile/package/%@_2_1.htm",package];
    MKNetworkOperation *op = [self operationWithPath:urlString];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}


// pad排行榜必玩
- (MKNetworkOperation *)getNecessarilyAppInfoOnCompletionHander:(MKNKResponseBlock) response errorHandler:(MKNKResponseErrorBlock) error
{
    NSString *urlString = [[UIDevice currentDevice] isJailbroken] ?@"mobile/bibei/2_2.htm":@"mobile/bibei/2_1.htm";
    MKNetworkOperation *op = [self operationWithPath:urlString];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}

// pad 分类用途
- (MKNetworkOperation *)getCategoryUserInfoOnCompletionHander:(MKNKResponseBlock) response errorHandler:(MKNKResponseErrorBlock) error
{
    NSString *urlString = [[UIDevice currentDevice] isJailbroken] ?@"mobile/category/album_2_2.htm":@"mobile/category/album_2_1.htm";
    MKNetworkOperation *op = [self operationWithPath:urlString];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}

//推荐应用
- (MKNetworkOperation *)getRecommentAppInfoForPage:(int)page
                                OnCompletionHander:(MKNKResponseBlock) response errorHandler:(MKNKResponseErrorBlock) error
{
    NSString *urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/dev/list_1_2_7_%d.htm",page] : [NSString stringWithFormat:@"mobile/dev/list_1_1_7_%d.htm",page];
    MKNetworkOperation *op = [self operationWithPath:urlString];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}


//分类-用途
- (MKNetworkOperation *)getCategoryUserListWithId:(int)categoryId
                                         sortType:(SortType)type
                                             page:(int)page
                               OnCompletionHander:(MKNKResponseBlock) response
                                     errorHandler:(MKNKResponseErrorBlock) error
{
    NSString *urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/album/list_2_2_%d_%d_%d.htm",categoryId,page,type] : [NSString stringWithFormat:@"mobile/album/list_2_1_%d_%d_%d.htm",categoryId,page,type];
    MKNetworkOperation *op = [self operationWithPath:urlString];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}



- (MKNetworkOperation *)getContentForUrlString:(NSString *)urlString
                                      response:(MKNKResponseBlock)response
                                         error:(MKNKResponseErrorBlock)error
{
    MKNetworkOperation *op = [self operationWithURLString:urlString];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}

//  邮箱密码注册
- (MKNetworkOperation *)registerWithEmail:(NSString *)email
                                 password:(NSString *)password
                      onCompletionHandler:(MKNKResponseBlock) response
                             errorHandler:(MKNKResponseErrorBlock) error
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:email forKey:@"email"];
    [dic setValue:password forKey:@"pass"];
    MKNetworkOperation *op = [self operationWithPath:@"user/u.php?e=register" params:dic httpMethod:@"POST"];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}

//  邮箱密码登录
- (MKNetworkOperation *)loginWithEmail:(NSString *)email
                              password:(NSString *)password
                   onCompletionHandler:(MKNKResponseBlock) response
                          errorHandler:(MKNKResponseErrorBlock) error
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:email forKey:@"email"];
    [dic setValue:password forKey:@"pass"];
    MKNetworkOperation *op = [self operationWithPath:@"user/u.php?e=login" params:dic httpMethod:@"POST"];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}

// 找回密码
- (MKNetworkOperation *)findBackPassWordWithEmail:(NSString *)email onCompletionHandler:(MKNKResponseBlock) response
                                     errorHandler:(MKNKResponseErrorBlock) error
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:email forKey:@"email"];
    MKNetworkOperation *op = [self operationWithPath:@"user/u.php?e=getpwd" params:dic httpMethod:@"POST"];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}

// 修改密码
- (MKNetworkOperation *)changePassWordWithUid:(NSString *)uid oldPwd:(NSString *)oldPwd newPwd:(NSString *)newPwd onCompletionHandler:(MKNKResponseBlock) response
                                 errorHandler:(MKNKResponseErrorBlock) error
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:uid forKey:@"uid"];
    [dic setValue:oldPwd forKey:@"oldpwd"];
    [dic setValue:newPwd forKey:@"newpwd"];
    MKNetworkOperation *op = [self operationWithPath:@"user/u.php?e=uppwd" params:dic httpMethod:@"POST"];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}

// 获取评论列表
- (MKNetworkOperation *)getCommentsListByAppDetailInfoFor:(int)appID CompletionHandler:(MKNKResponseBlock) response
                                             errorHandler:(MKNKResponseErrorBlock) error
{
    
    //    NSString *path = [NSString stringWithFormat:@"mobile/comment/list_%d.htm",appID];
    //    MKNetworkOperation *op = [self operationWithPath:path];
    //    appID = 1;
    MKNetworkOperation *op = [self operationWithURLString:[NSString stringWithFormat:@"http://pl.naitang.com/api/get.php?app_id=%d",appID]];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}

// 发布评论
- (MKNetworkOperation *)CommentWithGameId:(NSString *)game_id
                                      pid:(NSString *)pid message:(NSString *)message userId:(NSString *)userId
                      onCompletionHandler:(MKNKResponseBlock) response
                             errorHandler:(MKNKResponseErrorBlock) error
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    //    game_id = @"1";
    [dic setValue:game_id forKey:@"app_id"];
    [dic setValue:pid forKey:@"pid"];
    [dic setValue:message forKey:@"message"];
    //    NSLog(@"%@",[NSString stringWithFormat:@"%d",[YSUserInfoManager sharedYSUserInfoManger].loginedUser.uid]);
    [dic setValue:userId forKey:@"uid"];
    MKNetworkOperation *op = [self operationWithURLString:@"http://pl.naitang.com/api/send.php" params:dic httpMethod:@"POST"];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}

// 修改用户信息
- (MKNetworkOperation *)setUserInfotWithUid:(int)uid
                                   nickName:(NSString *)nickname sex:(NSString *)sex phone:(NSString *)phone
                        onCompletionHandler:(MKNKResponseBlock) response
                               errorHandler:(MKNKResponseErrorBlock) error
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:[NSString stringWithFormat:@"%d",uid] forKey:@"uid"];
    [dic setValue:nickname forKey:@"nickname"];
    [dic setValue:sex forKey:@"sex"];
    [dic setValue:phone forKey:@"phone"];
    MKNetworkOperation *op = [self operationWithPath:@"user/u.php?e=edit" params:dic httpMethod:@"POST"];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}


// 上传头像
- (MKNetworkOperation *)setUserImgWithUid:(int)uid
                             headphotoImg:(UIImage *)photoImg
                      onCompletionHandler:(MKNKResponseBlock) response
                             errorHandler:(MKNKResponseErrorBlock) error
{
    
    //    MKNetworkOperation *op = [[HttpEngine sharedHttpEngine] operationWithURLString:@"http://api.naitang.com/user/u.php?e=setavatar&uid=2" params:dic httpMethod:@"POST"];
    //    NSData *data = UIImagePNGRepresentation([UIImage imageNamed:@"icon.png"]);
    //    [op addData:data forKey:@"avatar"];
    //    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
    //        NSLog(@"%@",[completedOperation responseString]);
    //    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
    //        showAlert([error description]);
    //    }];
    //    [[HttpEngine sharedHttpEngine] enqueueOperation:op];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:[NSString stringWithFormat:@"%d",uid] forKey:@"uid"];
    NSData *data = UIImagePNGRepresentation(photoImg);
    MKNetworkOperation *op = [self operationWithPath:@"user/u.php?e=setavatar" params:dic httpMethod:@"POST"];
    [op addData:data forKey:@"avatar"];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}

// 获取头像接口
- (MKNetworkOperation *)getUserImgWithUid:(int)uid
                      onCompletionHandler:(MKNKResponseBlock) response
                             errorHandler:(MKNKResponseErrorBlock) error
{
    NSString *path = [NSString stringWithFormat:@"user/u.php?e=getavatar&uid=%d",uid];
    MKNetworkOperation *op = [self operationWithPath:path];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}

// 获取常见问题列表
- (MKNetworkOperation *)getComQuestionCompletionHandler:(MKNKResponseBlock) response
                                           errorHandler:(MKNKResponseErrorBlock) error
{
    
    NSString *path = [[UIDevice currentDevice] isJailbroken] ? @"mobile/question/list_2.htm" : @"mobile/question/list_1.htm";
    MKNetworkOperation *op = [self operationWithPath:path];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}

// 获取意见反馈列表
- (MKNetworkOperation *)getAdviceFeedBackCompletionHandler:(MKNKResponseBlock) response
                                              errorHandler:(MKNKResponseErrorBlock) error
{
    
    NSString *path = @"mobile/feedback/category.htm";
    MKNetworkOperation *op = [self operationWithPath:path];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}

// 提交意见反馈
- (MKNetworkOperation *)postAdviceFeedBackWithType:(NSString *)type
                                             email:(NSString *)email game_name:(NSString *)game_name content:(NSString *)content
                               onCompletionHandler:(MKNKResponseBlock) response
                                      errorHandler:(MKNKResponseErrorBlock) error
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:type forKey:@"type"];
    [dic setValue:email forKey:@"email"];
    [dic setValue:game_name forKey:@"game_name"];
    [dic setValue:content forKey:@"content"];
    MKNetworkOperation *op = [self operationWithPath:@"mobile.php?action=feedback&op=set" params:dic httpMethod:@"POST"];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}

// 消息中心
- (MKNetworkOperation *)getMessageCenterInfoListByUserUid:(int)uid CompletionHandler:(MKNKResponseBlock) response
                                             errorHandler:(MKNKResponseErrorBlock) error
{
    
    NSString *path = [[UIDevice currentDevice] isJailbroken]?[NSString stringWithFormat:@"pm.php?action=index&op=list&uid=%d&type=2",uid]:[NSString stringWithFormat:@"pm.php?action=index&op=list&uid=%d&type=1",uid];
    MKNetworkOperation *op = [self operationWithPath:path];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}


// 检查版本更新
- (MKNetworkOperation *)checkIsNeedUpdateVersionCompletionHandler:(MKNKResponseBlock) response
                                                     errorHandler:(MKNKResponseErrorBlock) error
{
    
    //NSString *path = [[UIDevice currentDevice] isJailbroken]?@"mobile/version/get_1.htm":@"mobile/version/get_1.htm";
//    NSString *path = @"http://dl.naitang.com/yingyong/up/version.json";
    NSString *path = @"http://apitest.naitang.com/mobile/v1/ntupdate/1_1.html";
    MKNetworkOperation *op = [self operationWithURLString:path];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}

// 登出
- (MKNetworkOperation *)logOutCompletionHandler:(MKNKResponseBlock) response
                                   errorHandler:(MKNKResponseErrorBlock) error
{
    MKNetworkOperation *op = [self operationWithPath:@"user/u.php?e=logout"];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}


// 获取可更新列表
- (MKNetworkOperation *)getEnableUpdateListByIdentifer:(NSString *)identiferStr
                                   onCompletionHandler:(MKNKResponseBlock) response
                                          errorHandler:(MKNKResponseErrorBlock) error
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    if (isIpad)
    {
        [dic setValue:@"2" forKey:@"product"];
        if ([[UIDevice currentDevice] isJailbroken])
        {
            [dic setValue:@"2" forKey:@"version_type"];
        }
        else
        {
            [dic setValue:@"1" forKey:@"version_type"];
        }
    }
    else
    {
        [dic setValue:@"1" forKey:@"product"];
        if ([[UIDevice currentDevice] isJailbroken])
        {
            [dic setValue:@"1" forKey:@"version_type"];
            //[dic setValue:@"2" forKey:@"version_type"];
        }
        else
        {
            [dic setValue:@"1" forKey:@"version_type"];
        }

    }
    [dic setValue:identiferStr forKey:@"apks"];
     
     MKNetworkOperation *op = [self operationWithPath:@"mobile_v1.php?action=info&op=update" params:dic httpMethod:@"POST"];
     
    
    /*
    [dic setValue:identiferStr forKey:@"package"];
    
    MKNetworkOperation *op = [self operationWithPath:[[UIDevice currentDevice] isJailbroken]?@"mobile.php?action=update&op=getVersion&product=1&version_type=2":@"mobile.php?action=update&op=getVersion&product=1&version_type=1" params:dic httpMethod:@"POST"];
     */
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}

// 获取关于奶糖里的其他应用
- (MKNetworkOperation *)getAboutNTOtherGamesCompletionHandler:(MKNKResponseBlock) response
                                                 errorHandler:(MKNKResponseErrorBlock) error
{
    
    NSString *path = [[UIDevice currentDevice] isJailbroken]?@"mobile/about/index_1_2.htm":@"mobile/about/index_1_1.htm";
    MKNetworkOperation *op = [self operationWithPath:path];
    [op addCompletionHandler:response errorHandler:error];
    [self enqueueOperation:op];
    return op;
}

/*
 //上传文件的格式
 - (MKNetworkOperation *)postData:(NSData *)data type:(NSString *)type onCompletionHandler:(MKNKResponseBlock) response errorHandler:(MKNKResponseErrorBlock) error
 {
 MKNetworkOperation *op = [self operationWithPath:@"?m=file&a=upload" params:nil httpMethod:@"POST"];
 [op addData:data forKey:@"filename" mimeType:@"application/octet-stream" fileName:type];
 [op addCompletionHandler:response errorHandler:error];
 [self enqueueOperation:op];
 return op;
 }
 //POST的格式
 - (MKNetworkOperation *)loginWithAccount:(NSString *)account
 password:(NSString *)password
 onCompletionHandler:(MKNKResponseBlock) response
 errorHandler:(MKNKResponseErrorBlock) error
 {
 NSMutableDictionary *dic = [NSMutableDictionary dictionary];
 [dic setValue:account forKey:@"account"];
 [dic setValue:password forKey:@"password"];
 MKNetworkOperation *op = [self operationWithPath:@"?m=login&a=login" params:dic httpMethod:@"POST"];
 
 [op addCompletionHandler:response errorHandler:error];
 [self enqueueOperation:op];
 return op;
 }
 */
@end

@implementation MKNetworkOperation(null)

- (id)responseJSONRemoveNull
{
    id result = [self responseJSON];
    return [NSObject turnNullToNilForObject:result];
}

@end
