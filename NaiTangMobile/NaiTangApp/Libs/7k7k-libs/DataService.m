//
//  DataService.m
//  WXHL_Weibo_08
//
//  Created by JayWon on 13-10-18.
//  Copyright (c) 2013年 JayWon. All rights reserved.
//

#import "DataService.h"
#import "NTAppDelegate.h"
#import "AppDelegate_Def.h"
#define Base_url    @"http://w.7kapp.cn/zshtml/gamenews/"
//http://w.7kapp.cn/zshtml/gamenews/gamebody/wd/35714.html

@implementation DataService

+ (ASIHTTPRequest *)requestWithURL:(NSString *)url
                      finishBlock:(FinishLoadHandle)block
{
     NTAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    NSString *urlString = @"";
    if([url hasPrefix:@"http"]){
        urlString = [NSString stringWithFormat:@"%@", url];
    }else{
        urlString = [NSString stringWithFormat:@"%@%@", Base_url, url];
    }
//    NSLog(@"url %@",urlString);
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setRequestMethod:@"GET"];
    [request setTimeOutSeconds:7];
    
    [request setDelegate:self];
    [request startAsynchronous];
    [request setTimeOutSeconds:10];
    
   
    //设置缓存方式
    [request setDownloadCache:appDelegate.myCache];
    [request setSecondsToCache:60*60*24*30]; // 缓存30天
    
    
    //设置缓存数据存储策略，这里采取的是如果无更新或无法联网就读取缓存数据
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
//    [request setCachePolicy: ASIAskServerIfModifiedWhenStaleCachePolicy];
    //request 持有 block
    //block 持有 request
    [request setCompletionBlock:^{
        //解析json9

        NSData *responseData = request.responseData;
//        if (request.didUseCachedResponse) {
            id result = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:NULL];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

            //block传值
            if(block){
                block(result);
            }

//        }
    }];
    [request setFailedBlock:^{
        NSLog(@"请求失败:%@", request.error);
        
        [appDelegate.window showLoadingMeg:@"网络异常" time:1];
        
        /*
        NSString * tmpstring = [NSString stringWithFormat:@"%@%@", AppNickname,@"，网络不给力呀!"];
        UIAlertView * alertview = [[UIAlertView alloc] initWithTitle:nil message:tmpstring delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertview show];
         */
         //NSString * tmpstring = [NSString stringWithFormat:@"%@%@", AppNickname,@"，网络不给力呀!"];
        //[appDelegate.window showLoadingMeg:tmpstring time:1];
    }];

    //发异步请求
   

    return request;
}

+ (ASIHTTPRequest *)requestWithURL:(NSString *)url
                       finishBlock:(FinishLoadHandle)block errorBlock:(ErrorHandle)errorBlock
{
    NTAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSString *urlString = @"";
    if([url hasPrefix:@"http"]){
        urlString = [NSString stringWithFormat:@"%@", url];
    }else{
        urlString = [NSString stringWithFormat:@"%@%@", Base_url, url];
    }
    //    NSLog(@"url %@",urlString);
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setRequestMethod:@"GET"];
    [request setTimeOutSeconds:7];
    
    [request setDelegate:self];
    [request startAsynchronous];
    [request setTimeOutSeconds:10];
    
    
    //设置缓存方式
    [request setDownloadCache:appDelegate.myCache];
    [request setSecondsToCache:60*60*24*30]; // 缓存30天
    
    
    //设置缓存数据存储策略，这里采取的是如果无更新或无法联网就读取缓存数据
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    //    [request setCachePolicy: ASIAskServerIfModifiedWhenStaleCachePolicy];
    //request 持有 block
    //block 持有 request
    [request setCompletionBlock:^{
        //解析json9
        
        NSData *responseData = request.responseData;
        //        if (request.didUseCachedResponse) {
        id result = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:NULL];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        //block传值
        if(block){
            block(result);
        }
        
        //        }
    }];
    [request setFailedBlock:^{
        NSLog(@"请求失败:%@", request.error);
        
        if (errorBlock) {
            errorBlock(request.error);
        }
        
        /*
         NSString * tmpstring = [NSString stringWithFormat:@"%@%@", AppNickname,@"，网络不给力呀!"];
         UIAlertView * alertview = [[UIAlertView alloc] initWithTitle:nil message:tmpstring delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
         [alertview show];
         */
        //NSString * tmpstring = [NSString stringWithFormat:@"%@%@", AppNickname,@"，网络不给力呀!"];
        //[appDelegate.window showLoadingMeg:tmpstring time:1];
    }];
    
    //发异步请求
    return request;
}

- (void)dealloc
{
    //在ASIHTTPRequest所有请求完成前，返回前页会报"message sent to deallocated instance"
    for (ASIHTTPRequest *req in  ASIHTTPRequest.sharedQueue.operations)
    {
        [req cancel];
        [req setDelegate:nil];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        return;
    }
}


@end
