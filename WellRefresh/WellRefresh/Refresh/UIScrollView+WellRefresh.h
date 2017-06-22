//
//  UIScrollView+WellRefresh.h
//  WellRefresh
//
//  Created by 同筑科技 on 2017/6/22.
//  Copyright © 2017年 well. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WellHeaderView;

typedef NS_ENUM(NSInteger,WellRefreshStatus) {
    // 刷新状态
    WellRefreshStatusWillRefresh = 0,
    WellRefreshStatusRefreshing = 1,
    WellRefreshStatusCancelRefresh = 2,
    WellRefreshStatusWillLoad = 3,
    WellRefreshStatusLoading = 4,
    WellRefreshStatusCancelLoad
};

//刷新的回调

typedef void(^WellHeaderRefreshBlock)();

@interface UIScrollView (WellRefresh)

@property(nonatomic,copy) WellHeaderRefreshBlock wellHeaderRefreshBlock;

@property (nonatomic , copy) NSString *wellRefreshStatus;

// 下拉刷新
- (void)welladdHeaderRefreshWithBlock:(WellHeaderRefreshBlock)block;
- (void)endHeaderRefresh;

@end
