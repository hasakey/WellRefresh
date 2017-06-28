//
//  WellHeaderView.m
//  WellRefresh
//
//  Created by 同筑科技 on 2017/6/22.
//  Copyright © 2017年 well. All rights reserved.
//

#define REFRESHING @"正在刷新数据"
#define WILLREFRESH @"松手刷新数据"
#define CANCELREFRESH @"下拉刷新数据"

#import "WellHeaderView.h"

@interface WellHeaderView ()

/* 文字 **/
@property(nonatomic,strong)UILabel *textLabel;
/* 图片 **/
@property(nonatomic,strong)UIImageView *imageView;
/* 转圈圈 **/
@property(nonatomic,strong)UIActivityIndicatorView *activityIndicatorView;
/* 转圈圈 **/
@property(nonatomic,strong)NSArray *gifArray;

@end

@implementation WellHeaderView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = CGRectMake(0, -50, self.frame.size.width, 50);
        [self setUpSubViews];
        [self addObserver:self forKeyPath:@"refreshStatus" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

#pragma mark    METHODS
-(void)setUpSubViews
{
    [self addSubview:self.textLabel];
    [self addSubview:self.imageView];
//    [self addSubview:self.activityIndicatorView];

}

#pragma mark    监听
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"refreshStatus"]) {
        if (self.refreshStatus == WellRefreshWillRefresh) {
            self.textLabel.text = WILLREFRESH;
//            self.imageView.hidden = NO;
            [self.imageView stopAnimating];
//            self.activityIndicatorView.hidden = YES;
            [UIView animateWithDuration:0.3 animations:^{
//                self.imageView.transform = CGAffineTransformMakeRotation(0);
                self.imageView.image = [UIImage imageNamed:@"pulling"];
            }];
            
        }else if (self.refreshStatus == WellRefreshing)
        {
            self.textLabel.text = REFRESHING;
//            self.imageView.hidden = YES;
//            self.activityIndicatorView.hidden = NO;
            self.imageView.animationImages = self.gifArray;
            self.imageView.animationDuration = 0.1 * self.gifArray.count;
            [self.imageView startAnimating];
        }else if (self.refreshStatus == WellRefreshCancelRefresh)
        {
            self.textLabel.text = CANCELREFRESH;
//            self.imageView.hidden = NO;
            [self.imageView stopAnimating];
//            self.activityIndicatorView.hidden = YES;
            [UIView animateWithDuration:0.3 animations:^{
//                self.imageView.transform = CGAffineTransformMakeRotation(M_PI);
                self.imageView.image = [UIImage imageNamed:@"normal"];
            }];
        }
    }
}

#pragma mark    懒加载
-(UILabel *)textLabel
{
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/3, 0, self.frame.size.width/3, 50)];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.font = [UIFont systemFontOfSize:18];
        _textLabel.text = CANCELREFRESH;
    }
    return _textLabel;
}

-(UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width / 3 - 30, 10, 30, 30)];
        _imageView.image = [UIImage imageNamed:@"normal"];
//        _imageView.transform = CGAffineTransformMakeRotation(M_PI);
        _imageView.hidden = NO;
    }
    return _imageView;
}
-(UIActivityIndicatorView *)activityIndicatorView
{
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicatorView.center = CGPointMake(self.frame.size.width/3 - 15, 25);
        _activityIndicatorView.hidden = YES;
        [_activityIndicatorView startAnimating];
    }
    return _activityIndicatorView;
}

-(NSArray *)gifArray
{
    if (!_gifArray) {
        NSMutableArray *arrayM = [NSMutableArray array];
        for (int i=1; i<4; i++) {
            NSString *imagesName = [NSString stringWithFormat:@"%d",i];
            UIImage *image = [UIImage imageNamed:imagesName];
            [arrayM addObject:image];
        }
        _gifArray = arrayM;
    }
    return _gifArray;
}


-(void)dealloc
{
    [self.activityIndicatorView stopAnimating];
    [self removeObserver:self forKeyPath:@"refreshStatus"];
}

@end
