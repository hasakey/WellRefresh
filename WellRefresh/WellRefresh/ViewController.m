//
//  ViewController.m
//  WellRefresh
//
//  Created by 同筑科技 on 2017/6/22.
//  Copyright © 2017年 well. All rights reserved.
//

#import "ViewController.h"
#import "WellRefresh.h"


@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    [self.tableView welladdHeaderRefreshWithBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView endHeaderRefresh];
        });
    }];
    
    [self.tableView welladdFooterLoadWithBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView endFooterLoad];
            NSLog(@"加载中");
        });
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"test";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"哈哈哈哈哈哈哈哈哈哈哈哈----%ld",(long)indexPath.row];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return _tableView;
}



@end
