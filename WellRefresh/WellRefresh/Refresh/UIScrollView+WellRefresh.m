//
//  UIScrollView+WellRefresh.m
//  WellRefresh
//
//  Created by 同筑科技 on 2017/6/22.
//  Copyright © 2017年 well. All rights reserved.
//

#define REFRESHING @"正在刷新数据"
#define WILLREFRESH @"松手刷新数据"
#define CANCELREFRESH @"下拉刷新数据"

#import "UIScrollView+WellRefresh.h"
#import "WellHeaderView.h"
#import "WellFooterView.h"
#import <objc/message.h>

@interface UIScrollView()

@property(nonatomic,strong)WellHeaderView *wellHeaderView;

@property(nonatomic,strong)WellFooterView *wellFooterView;

@end

@implementation UIScrollView (WellRefresh)

//下拉刷新
-(void)welladdHeaderRefreshWithBlock:(WellHeaderRefreshBlock)block
{
    self.wellHeaderRefreshBlock = block;
    if (!self.wellHeaderView) {
        self.wellHeaderView = [[WellHeaderView alloc] initWithFrame:CGRectMake(0, -50, self.frame.size.width, 50)];
    }
    [self addSubview:self.wellHeaderView];
    
    //添加监听
    [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"wellRefreshStatus" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)endHeaderRefresh
{
    [self getRefreshStatus:WellRefreshStatusCancelRefresh];
    [UIView animateWithDuration:0.5 animations:^{
        self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }];
}


//上拉加载
-(void)welladdFooterLoadWithBlock:(WellFooterLoadBlock)block
{
    self.wellFooterLoadBlock = block;
    if (!self.wellFooterView) {
        self.wellFooterView = [[WellFooterView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, 50)];
    }
    [self addSubview:self.wellFooterView];
    
    [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"wellRefreshStatus" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)endFooterLoad
{
    [self getRefreshStatus:WellRefreshStatusCancelLoad];
    [UIView animateWithDuration:0.5 animations:^{
        self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }];
}

// 设置刷新状态
- (void)getRefreshStatus:(WellRefreshStatus)status
{
    switch (status) {
        case WellRefreshStatusWillRefresh:
            self.wellRefreshStatus = @"WellRefreshStatusWillRefresh";
            self.wellHeaderView.refreshStatus = WellRefreshWillRefresh;
            break;
        case WellRefreshStatusRefreshing:
            self.wellRefreshStatus = @"WellRefreshStatusRefreshing";
            self.wellHeaderView.refreshStatus = WellRefreshing;
            break;
        case WellRefreshStatusCancelRefresh:
            self.wellRefreshStatus = @"WellRefreshStatusCancelRefresh";
            self.wellHeaderView.refreshStatus = WellRefreshCancelRefresh;
            break;
        case WellRefreshStatusWillLoad:
            self.wellRefreshStatus = @"WellRefreshStatusWillLoad";
            self.wellFooterView.loadStatus = WellLoadWillLoad;
            break;
        case WellRefreshStatusLoading:
            self.wellRefreshStatus = @"WellRefreshStatusLoading";
            self.wellFooterView.loadStatus = WellLoading;
            break;
        case WellRefreshStatusCancelLoad:
            self.wellRefreshStatus = @"WellRefreshStatusCancelLoad";
            self.wellFooterView.loadStatus = WellLoadCancelLoad;
            break;
            
        default:
            break;
    }
}

#pragma mark 观察者方法
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"]) {
        //正在拖拽
        if (self.dragging) {
            if (self.contentOffset.y < 0) {//下拉
                NSLog(@"%@",self.wellRefreshStatus);
                if (![self.wellRefreshStatus isEqualToString:@"WellRefreshStatusRefreshing"]) {
                    if (self.contentOffset.y <= -50) {//准备下拉刷新
                        [self getRefreshStatus:WellRefreshStatusWillRefresh];
                    }else//取消下拉刷新
                    {
                        [self getRefreshStatus:WellRefreshStatusCancelRefresh];
                    }
                }
            }else//上拉加载
            {
                if (![self.wellRefreshStatus isEqualToString:@"WellRefreshStatusLoading"]) {
                    
                    CGFloat offsetY = self.contentOffset.y;
                    CGFloat frameY = self.frame.size.height;
                    CGFloat contentY = self.contentSize.height;
                    float bottomY = offsetY + frameY - contentY;//这个值是否是拉倒最下面了
                    if (frameY > contentY) {
                        bottomY = offsetY;
                    }
                    
                    if (bottomY > 50) {
                        [self getRefreshStatus:WellRefreshStatusWillLoad];
                    }else
                    {
                        [self getRefreshStatus:WellRefreshStatusCancelLoad];
                    }
                    
                }
            }
        }else if ([self.wellRefreshStatus isEqualToString:@"WellRefreshStatusWillRefresh"])//下拉刷新
        {
            [self getRefreshStatus:WellRefreshStatusRefreshing];
            self.contentInset = UIEdgeInsetsMake(50, 0, 0, 0);
            self.wellHeaderRefreshBlock();
        }else if ([self.wellRefreshStatus isEqualToString:@"WellRefreshStatusWillLoad"])//上拉加载
        {
            [self getRefreshStatus:WellRefreshStatusLoading];
            self.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
            self.wellFooterLoadBlock();
            
        }
    }
    
    if ([keyPath isEqualToString:@"wellRefreshStatus"]) {
        if (!self.dragging) {
            if ([self.wellRefreshStatus isEqualToString:@"WellRefreshStatusWillRefresh"]) {
                [self getRefreshStatus:WellRefreshStatusRefreshing];
                self.contentInset = UIEdgeInsetsMake(50, 0, 0, 0);
                self.wellHeaderRefreshBlock();
            }else if ([self.wellRefreshStatus isEqualToString:@"WellRefreshStatusWillLoad"])
            {
                [self getRefreshStatus:WellRefreshStatusLoading];
                self.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
                self.wellFooterLoadBlock();
            }
        }
    }
    
    if ([keyPath isEqualToString:@"contentSize"]) {
        if (self.wellFooterView) {
            CGSize contentSize = self.contentSize;
            CGFloat contentY = contentSize.height;
            CGFloat frameY = self.frame.size.height;
            float BottomY = contentY;
            if (frameY >= contentY) {
                BottomY = frameY;
            }
            self.wellFooterView.frame = CGRectMake(0, BottomY, self.frame.size.width, 50);
        }
    }
}

- (void)dealloc{
    [self removeObserver:self forKeyPath:@"contentOffset"];
    [self removeObserver:self forKeyPath:@"wellRefreshStatus"];
    [self removeObserver:self forKeyPath:@"contentSize"];
}

#pragma mark 动态添加属性
// 利用runtime来添加视图属性
//wellHeaderView
-(void)setWellHeaderView:(WellHeaderView *)wellHeaderView
{
    objc_setAssociatedObject(self, @selector(wellHeaderView), wellHeaderView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(WellHeaderView *)wellHeaderView
{
    return objc_getAssociatedObject(self, _cmd);
}

//wellHeaderRefreshBlock
-(void)setWellHeaderRefreshBlock:(WellHeaderRefreshBlock)wellHeaderRefreshBlock
{
    objc_setAssociatedObject(self, @selector(wellHeaderRefreshBlock), wellHeaderRefreshBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(WellHeaderRefreshBlock)wellHeaderRefreshBlock
{
    return objc_getAssociatedObject(self, _cmd);
}

//wellRefreshStatus
-(void)setWellRefreshStatus:(NSString *)wellRefreshStatus
{
    objc_setAssociatedObject(self, @selector(wellRefreshStatus), wellRefreshStatus, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSString *)wellRefreshStatus
{
    return objc_getAssociatedObject(self, _cmd);
}

//wellFooterView
-(void)setWellFooterView:(WellFooterView *)wellFooterView
{
    objc_setAssociatedObject(self, @selector(wellFooterView), wellFooterView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


-(WellFooterView *)wellFooterView
{
    return objc_getAssociatedObject(self, _cmd);
}

//wellFooterLoadBlock
-(void)setWellFooterLoadBlock:(WellFooterLoadBlock)wellFooterLoadBlock
{
    objc_setAssociatedObject(self, @selector(wellFooterLoadBlock), wellFooterLoadBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(WellFooterLoadBlock)wellFooterLoadBlock
{
    return objc_getAssociatedObject(self, _cmd);
}

@end
