//
//  NT_HotKeyCell.m
//  NaiTangApp
//
//  Created by 张正超 on 14-3-6.
//  Copyright (c) 2014年 张正超. All rights reserved.
//

#import "NT_HotKeyCell.h"

@implementation NT_HotKeyCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.opaque = YES;
        self.alpha = 1.0;
        self.backgroundColor = [UIColor colorWithHex:@"#efefef"];
        
        //默认显示热词个数
        self.hotKeyCount = 13;
        self.hotKeysArray = [NSArray array];
        self.nextHotKeyArray = [NSArray array];
        //图片
        self.imageArray = [NSArray arrayWithObjects:@"search-white.png",@"search-blue.png",@"search-orange.png",@"search-purple.png",@"search-light-blue.png",@"search-green.png", nil];
        
        self.rowCountWithImage = 0;
        self.imageIndex = 0;
        
        UILabel *hotLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 12, SCREEN_WIDTH, 20)];
        hotLabel.text = @"最热搜索";
        //hotLabel.textColor = [UIColor colorWithHex:@"#8c9599"];
        hotLabel.textColor = Text_Color_Title;
        hotLabel.font = [UIFont systemFontOfSize:12];
        hotLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:hotLabel];
        
        UIButton *changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [changeButton setImage:[UIImage imageNamed:@"refresh.png"] forState:UIControlStateNormal];
        
        [changeButton setTitle:@" 换一组看看" forState:UIControlStateNormal];
        [changeButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [changeButton setTitleColor:Text_Color  forState:UIControlStateNormal];
        [changeButton setBackgroundImage:[UIImage imageNamed:self.imageArray[0]] forState:UIControlStateNormal];
        [changeButton setBackgroundImage:[UIImage imageNamed:@"btn-selected.png"] forState:UIControlStateHighlighted];
        //changeButton.frame = CGRectMake(0, SCREEN_HEIGHT - (40+180+30), SCREEN_WIDTH, 30);
        
        if (isIphone5Screen)
        {
            //changeButton.frame = CGRectMake(0, 300, SCREEN_WIDTH, 30);
            changeButton.frame = CGRectMake(5, 280, SCREEN_WIDTH - 10, 30);
        }
        else
        {
            //changeButton.frame = CGRectMake(0, 240, SCREEN_WIDTH, 30);
            changeButton.frame = CGRectMake(5, 220, SCREEN_WIDTH - 10, 30);
        }
        
        [changeButton addTarget:self action:@selector(changeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:changeButton];
        
        
        UIControl *control = [[UIControl alloc] init];
        if (isIphone5Screen)
        {
            control.frame = CGRectMake(0, 260, SCREEN_WIDTH, 60);
        }
        else
        {
            control.frame = CGRectMake(0, 200, SCREEN_WIDTH, 60);
        }
        [control addTarget:self action:@selector(changeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:control];
        
    }
    return self;
}

//获取所有热词
- (void)getHotKeyArray:(NSArray *)keywordArray
{
    [self clearButton];
    if (keywordArray.count>0)
    {
        self.hotKeysArray = keywordArray;
        
        //首次加载默认显示热词数
        self.nextHotKeyArray = [self getHotKeyData:0];
        
        [self loadHotKeyButton:self.nextHotKeyArray];
    }
}

//加载热词按钮
- (void)loadHotKeyButton:(NSArray *)hotArray
{
    //存储每行的按钮
    NSMutableArray *buttonMutArray = [NSMutableArray array];
    
    if (self.hotKeysArray.count>0&&hotArray.count>0)
    {
        //UIView *hotKeyView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, SCREEN_WIDTH, 240)];
        UIView *hotKeyView = [[UIView alloc] initWithFrame:CGRectMake(0, 30, SCREEN_WIDTH, 160)];
        [self addSubview:hotKeyView];
        
        //默认显示热词
        [hotArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             
             
             NSLog(@"obj:%@",obj);
             NSString *hotKey = obj;
             
             CGSize maximumSize = CGSizeMake(SCREEN_WIDTH, 30);
             UIFont *myFont = [UIFont systemFontOfSize:12];
             CGSize hotKeySize = [hotKey sizeWithFont:myFont
                                    constrainedToSize:maximumSize
                                        lineBreakMode:NSLineBreakByWordWrapping];
             
             UIButton *hotKeyButton = [UIButton buttonWithType:UIButtonTypeCustom];
             
             
             //第一行或换行
             hotKeySize.height = 30;
             if (idx == 0 || self.hotKeyX == 5)
             {
                 self.hotKeyX = 5;
                 self.hotKeyY = 10;
                 //一行的图片数量
                 self.rowCountWithImage = 1;
                 self.positonX = 5;
             }
             else
             {
                 CGFloat otherX=self.hotKeyX;
                 CGFloat otherPosition = otherX+(hotKeySize.width+20)+10;
                 
                 self.positonX = otherPosition;
                 //若换行
                 if (otherPosition>=SCREEN_WIDTH)
                 {
                     //若需要换行，则移除上一行热词
                     [buttonMutArray removeAllObjects];
                     //行数
                     self.rowCount ++;
                     self.hotKeyX = 5;
                     self.hotKeyY += hotKeySize.height+10;
                     //一行的图片数量
                     self.rowCountWithImage = 1;
                     self.positonX = 5;
                 }
                 else
                 {
                     //一行的图片数量
                     ++ self.rowCountWithImage;
                     
                 }
             }
             
             //搜索热词按钮
             
             hotKeyButton.frame = CGRectMake(self.hotKeyX, self.hotKeyY, hotKeySize.width+20,30);
             [hotKeyButton.titleLabel setFont:myFont];
             [hotKeyButton setTitle:hotKey forState:UIControlStateNormal];
             [hotKeyButton setTitleColor:Text_Color forState:UIControlStateNormal];
             [hotKeyButton setBackgroundImage:[UIImage imageNamed:[self.imageArray objectAtIndex:0]] forState:UIControlStateNormal];
             [hotKeyButton setBackgroundImage:[UIImage imageNamed:@"btn-selected.png"] forState:UIControlStateHighlighted];
             hotKeyButton.titleLabel.adjustsFontSizeToFitWidth = YES;
             [hotKeyButton addTarget:self action:@selector(hotKeyButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
             hotKeyButton.backgroundColor = [UIColor clearColor];
             hotKeyButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
             [hotKeyView addSubview:hotKeyButton];
             
             [buttonMutArray addObject:hotKeyButton];
             
             
             //若不是换行
             if (self.positonX != 5 && self.positonX <= SCREEN_WIDTH)
             {
                 //一行内，先是3个，然后循环到第4个，若有第4个
                 if (self.rowCountWithImage % 2 == 0)
                 {
                     //若一行有偶数个热词，若有4个，则颜色图片就是1、3
                     if (self.rowCountWithImage == 4)
                     {
                         //int temp = self.imageIndex - 1;
                         int temp = self.imageIndex;
                         if (temp<0)
                         {
                             self.imageIndex = 0;
                         }
                         else
                         {
                             self.imageIndex = temp;
                         }
                         NSLog(@"image index:%d",self.imageIndex);
                         //若第3个图片，设置了，则取消第2个图片显示，改为第1个和第3个颜色图片
                         
                         //则取消第2个图片显示
                         UIButton *btn2 =[buttonMutArray objectAtIndex:1];
                         [btn2 setBackgroundImage:[UIImage imageNamed:[self.imageArray objectAtIndex:0]] forState:UIControlStateNormal];
                         [btn2 setTitleColor:Text_Color forState:UIControlStateNormal];
                         
                         
                         //改为第1个和第3个颜色图片
                         UIButton *btn1 =[buttonMutArray objectAtIndex:0];
                         [btn1 setBackgroundImage:[UIImage imageNamed:[self.imageArray objectAtIndex:self.imageIndex]] forState:UIControlStateNormal];
                         [btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                         
                         
                         UIButton *btn3 = [buttonMutArray objectAtIndex:2];
                         [btn3 setBackgroundImage:[UIImage imageNamed:[self.imageArray objectAtIndex:++self.imageIndex]] forState:UIControlStateNormal];
                         [btn3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                     }
                 }
                 else
                 {
                     //若一行有奇数个热词，若有3个，颜色图片就是中间2
                     if (self.rowCountWithImage == 3)
                     {
                         int temp = self.imageIndex + 1;
                         if (temp<=5)
                         {
                             self.imageIndex = temp;
                         }
                         else
                         {
                             self.imageIndex = 0;
                         }
                         NSLog(@"image index:%d",self.imageIndex);
                         UIButton *btn = [buttonMutArray objectAtIndex:1];
                         [btn setBackgroundImage:[UIImage imageNamed:[self.imageArray objectAtIndex:self.imageIndex]] forState:UIControlStateNormal];
                         [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                         
                     }
                 }
                 
             }
             else if(self.imageIndex<0 || self.imageIndex>5)
             {
                 self.imageIndex = 0;
             }
             
             //获取 x+hotKeySize.width的位置
             self.hotKeyX += (hotKeySize.width+20)+10;
             
             
         }];
        //NSLog(@"button array:%d",buttonMutArray.count);
        self.rowCountWithImage = 1;
        self.imageIndex = 0;
    }
}

//热词搜索
- (void)hotKeyButtonPressed:(id)sender
{
    UIButton *hotButton = (UIButton *)sender;
    NSString *hotKey = hotButton.titleLabel.text;
    
    
    //搜索热词委托
    if (self.delegate&&[self.delegate respondsToSelector:@selector(searchWithHotKey:)])
    {
        [self.delegate searchWithHotKey:hotKey];
    }
}

//换一组看看
- (void)changeButtonPressed:(id)sender
{
    self.changeClickCount ++;
    
    NSArray *changeArray = [self getHotKeyData:self.changeClickCount];
    
    if (changeArray.count==0)
    {
        self.changeClickCount = 0;
        //重新刷新首次热词
        changeArray=[self getHotKeyData:0];
    }
    
    if (changeArray.count>0)
    {
        [self clearButton];
    }
    //刷新热词数据
    [self loadHotKeyButton:changeArray];
    
    
}

//清空按钮
- (void)clearButton
{
    BOOL flag = false;
    //清空按钮
    for (int i = 0; i<self.subviews.count; i++)
    {
        if ([[self.subviews objectAtIndex:i] isKindOfClass:[UIView class]])
        {
            UIView *view = (UIView *)[self.subviews objectAtIndex:i];
            if (isIOS7)
            {
                for (int j = 0; j<view.subviews.count; j++)
                {
                    if ([[view.subviews objectAtIndex:j] isKindOfClass:[UIView class]])
                    {
                        UIView *subview = (UIView *)view.subviews[j];
                        for (int k = 0; k<subview.subviews.count; k++)
                        {
                            if ([[subview.subviews objectAtIndex:k] isKindOfClass:[UIButton class]])
                            {
                                flag = true;
                                break;
                            }
                            
                        }
                        if (flag) {
                            [subview removeFromSuperview];
                        }
                    }
                    
                }
                
            }
            else
            {
                for (int j = 0; j<view.subviews.count; j++)
                {
                    if ([[view.subviews objectAtIndex:j] isKindOfClass:[UIButton class]])
                    {
                        flag = true;
                        break;
                    }
                }
                if (flag) {
                    [view removeFromSuperview];
                }
                
            }
            
        }
    }
    
}

//换一组按钮点击次数
- (void)changeHotKey:(int)changeButtonClickCount
{
    NSArray *changeArray = [self getHotKeyData:changeButtonClickCount];
    
    if (changeArray.count==0)
    {
        //重新刷新首次热词
        changeArray=[self getHotKeyData:0];
    }
    
    if (changeArray.count>0)
    {
        BOOL flag = false;
        //清空显示过的按钮
        for (int i = 0; i<self.subviews.count; i++)
        {
            if ([[self.subviews objectAtIndex:i] isKindOfClass:[UIView class]])
            {
                UIView *view = (UIView *)[self.subviews objectAtIndex:i];
                if (isIOS7)
                {
                    for (int j = 0; j<view.subviews.count; j++)
                    {
                        if ([[view.subviews objectAtIndex:j] isKindOfClass:[UIView class]])
                        {
                            UIView *subview = (UIView *)view.subviews[j];
                            for (int k = 0; k<subview.subviews.count; k++)
                            {
                                if ([[subview.subviews objectAtIndex:k] isKindOfClass:[UIButton class]])
                                {
                                    flag = true;
                                    break;
                                }
                                
                            }
                            if (flag) {
                                [subview removeFromSuperview];
                            }
                        }
                        
                    }
                    
                }
                else
                {
                    for (int j = 0; j<view.subviews.count; j++)
                    {
                        if ([[view.subviews objectAtIndex:j] isKindOfClass:[UIButton class]])
                        {
                            flag = true;
                            break;
                        }
                    }
                    if (flag) {
                        [view removeFromSuperview];
                    }
                    
                }
                
            }
        }
        
    }
    //刷新热词数据
    [self loadHotKeyButton:changeArray];
}

//获取下一组热词
- (NSArray *)getHotKeyData:(NSInteger)clickCount
{
    NSArray *changeHotArray = nil;
    if (self.hotKeysArray.count > 0)
    {
        NSInteger tempCount = self.hotKeysArray.count - self.nextHotKeyArray.count*clickCount;
        
        if (tempCount>=0)
        {
            if (self.hotKeysArray.count>self.nextHotKeyArray.count*clickCount)
            {
                
                if (tempCount>= self.hotKeyCount)
                {
                    //首次加载默认显示热词数
                    if (self.hotKeysArray.count%self.hotKeyCount == 0)
                    {
                        changeHotArray =[self.hotKeysArray subarrayWithRange:NSMakeRange(self.nextHotKeyArray.count*clickCount, self.hotKeyCount)];
                    }
                    else
                    {
                        changeHotArray = [self.hotKeysArray subarrayWithRange:NSMakeRange(self.nextHotKeyArray.count*clickCount, self.hotKeyCount)];
                    }
                }
                else
                {
                    changeHotArray = [self.hotKeysArray subarrayWithRange:NSMakeRange(self.nextHotKeyArray.count*clickCount, tempCount)];
                }
                
            }
            else
            {
                changeHotArray = [self.hotKeysArray subarrayWithRange:NSMakeRange(self.nextHotKeyArray.count*clickCount, tempCount)];
            }
        }
    }
    return changeHotArray;
}

- (void)showError
{
    [self showLoadingMeg:@"数据加载失败" time:1];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
