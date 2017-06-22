//
//  UITableView+NoMoreData.m
//  WellRefresh
//
//  Created by 同筑科技 on 2017/6/22.
//  Copyright © 2017年 well. All rights reserved.
//

#import "UITableView+NoMoreData.h"
#import <objc/message.h>


@interface UITableView()

@property(nonatomic,strong)UIView *noMoreDataView;

@end

@implementation UITableView (NoMoreData)

+(void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method reloadData = class_getInstanceMethod(self, @selector(reloadData));
        Method wellReloadData = class_getInstanceMethod(self, @selector(wellReloadData));
        method_exchangeImplementations(reloadData, wellReloadData);
    });
}

-(void)wellReloadData
{
    [self setUpEmptyFootView];
    [self wellReloadData];
    id <UITableViewDataSource> dataSource = self.dataSource;
    NSInteger sections = 0;
    if ([dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
        sections = [dataSource numberOfSectionsInTableView:self];
    }
    
    for (NSInteger i = 0; i < sections; ++i) {
        NSInteger rows = [dataSource tableView:self numberOfRowsInSection:sections];
        if (!rows) {
            if (self.tableHeaderView) {
                CGFloat y = self.tableHeaderView.frame.size.height;
                self.noMoreDataView.frame = CGRectMake(0, y, self.frame.size.width, self.frame.size.height - y);
                self.scrollEnabled = YES;
            }else
            {
                self.scrollEnabled = NO;
            }
            [self addSubview:self.noMoreDataView];
            
        }else
        {
            self.scrollEnabled = YES;
            if (self.noMoreDataView) {
                [self.noMoreDataView removeFromSuperview];
            }
        }
    }
}

-(void)setNoMoreDataImageView:(UIView *)noMoreDataImageView
{
    if (self.noMoreDataView) {
        self.noMoreDataView = nil;
    }
    self.noMoreDataView = noMoreDataImageView;
}


-(void)noMoreDataView:(UIView *)noMoreDataView
{
    objc_setAssociatedObject(self, @selector(noMoreDataView), noMoreDataView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIView *)noMoreDataView
{
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setUpEmptyFootView
{
    if (!self.tableFooterView) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        self.tableFooterView = view;
    }
}

@end
