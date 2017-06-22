//
//  WellFooterView.m
//  WellRefresh
//
//  Created by 同筑科技 on 2017/6/22.
//  Copyright © 2017年 well. All rights reserved.
//

#define LOADING @"正在刷新数据"
#define WILLLOAD @"松手刷新数据"
#define CANCELLOAD @"下拉刷新数据"

#import "WellFooterView.h"

@interface WellFooterView()

/* 文字 **/
@property(nonatomic,strong)UILabel *textLabel;
/* 图片 **/
@property(nonatomic,strong)UIImageView *imageView;
/* 转圈圈 **/
@property(nonatomic,strong)UIActivityIndicatorView *activityIndicatorView;

@end

@implementation WellFooterView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpSubViews];
        [self addObserver:self forKeyPath:@"loadStatus" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

#pragma mark    METHODS
-(void)setUpSubViews
{
    [self addSubview:self.textLabel];
    [self addSubview:self.imageView];
    [self addSubview:self.activityIndicatorView];
    
}

#pragma mark    监听
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"loadStatus"]) {
        if (self.loadStatus == WellLoadWillLoad) {
            self.textLabel.text = WILLLOAD;
            self.imageView.hidden = NO;
            self.activityIndicatorView.hidden = YES;
            [UIView animateWithDuration:0.3 animations:^{
                self.imageView.transform = CGAffineTransformMakeRotation(M_PI);
            }];
            
        }else if (self.loadStatus == WellLoading)
        {
            self.textLabel.text = LOADING;
            self.imageView.hidden = YES;
            self.activityIndicatorView.hidden = NO;
        }else if (self.loadStatus == WellLoadCancelLoad)
        {
            self.textLabel.text = CANCELLOAD;
            self.imageView.hidden = NO;
            self.activityIndicatorView.hidden = YES;
            [UIView animateWithDuration:0.3 animations:^{
                self.imageView.transform = CGAffineTransformMakeRotation(0);
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
        _textLabel.text = CANCELLOAD;
    }
    return _textLabel;
}

-(UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width / 3 - 30, 10, 30, 30)];
        _imageView.image = [UIImage imageNamed:@"RefreshArrow"];
        _imageView.transform = CGAffineTransformMakeRotation(0);
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

-(void)dealloc
{
    [self.activityIndicatorView stopAnimating];
    [self removeObserver:self forKeyPath:@"loadStatus"];
}

@end
