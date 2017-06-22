//
//  WellHeaderView.h
//  WellRefresh
//
//  Created by 同筑科技 on 2017/6/22.
//  Copyright © 2017年 well. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,WellRefresh) {
    WellRefreshWillRefresh = 0,
    WellRefreshing = 1,
    WellRefreshCancelRefresh = 2
};

@interface WellHeaderView : UIView

@property(nonatomic,assign)WellRefresh refreshStatus;

@end
