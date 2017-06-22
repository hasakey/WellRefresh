//
//  WellFooterView.h
//  WellRefresh
//
//  Created by 同筑科技 on 2017/6/22.
//  Copyright © 2017年 well. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,WellLoad) {
    WellLoadWillLoad = 0,
    WellLoading = 1,
    WellLoadCancelLoad = 2
};

@interface WellFooterView : UIView

@property(nonatomic,assign)WellLoad loadStatus;

@end
