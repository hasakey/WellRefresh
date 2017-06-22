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
#import <objc/message.h>

@interface UIScrollView()

@property(nonatomic,strong)WellHeaderView *wellHeaderView;

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
            }
        }else if ([self.wellRefreshStatus isEqualToString:@"WellRefreshStatusWillRefresh"])//下拉刷新
        {
            [self getRefreshStatus:WellRefreshStatusRefreshing];
            self.contentInset = UIEdgeInsetsMake(50, 0, 0, 0);
            self.wellHeaderRefreshBlock();
        }
    }
    
    if ([keyPath isEqualToString:@"wellRefreshStatus"]) {
        if (!self.dragging) {
            if ([self.wellRefreshStatus isEqualToString:@"WellRefreshStatusWillRefresh"]) {
                [self getRefreshStatus:WellRefreshStatusRefreshing];
                self.contentInset = UIEdgeInsetsMake(50, 0, 0, 0);
                self.wellHeaderRefreshBlock();
            }
        }
    }
}

- (void)dealloc{
    [self removeObserver:self forKeyPath:@"contentOffset"];
    [self removeObserver:self forKeyPath:@"RefreshStatu"];
}

#pragma mark 动态添加属性
// 利用runtime来添加视图属性
-(void)setWellHeaderView:(WellHeaderView *)wellHeaderView
{
    objc_setAssociatedObject(self, @selector(wellHeaderView), wellHeaderView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(WellHeaderView *)wellHeaderView
{
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setWellHeaderRefreshBlock:(WellHeaderRefreshBlock)wellHeaderRefreshBlock
{
    objc_setAssociatedObject(self, @selector(wellHeaderRefreshBlock), wellHeaderRefreshBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(WellHeaderRefreshBlock)wellHeaderRefreshBlock
{
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setWellRefreshStatus:(NSString *)wellRefreshStatus
{
    objc_setAssociatedObject(self, @selector(wellRefreshStatus), wellRefreshStatus, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSString *)wellRefreshStatus
{
    return objc_getAssociatedObject(self, _cmd);
}

@end
