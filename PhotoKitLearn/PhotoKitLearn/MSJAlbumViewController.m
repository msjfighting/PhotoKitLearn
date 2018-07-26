//
//  MSJAlbumViewController.m
//  Image练习
//
//  Created by zlhj on 2018/7/25.
//  Copyright © 2018年 MSJ. All rights reserved.
//

#import "MSJAlbumViewController.h"
#import "AlbumCell.h"
#import "MSJPhotoManager.h"
#import "AlbumModel.h"
#import "MSJImagePickerController.h"
#define ScreenWidth [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight [[UIScreen mainScreen] bounds].size.height
@interface MSJAlbumViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView * tableView;
@property (nonatomic,strong) NSMutableArray * dataSource;
@end

@implementation MSJAlbumViewController
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth,ScreenHeight) style:UITableViewStylePlain];
        [_tableView registerClass:[AlbumCell class] forCellReuseIdentifier:@"AlbumCell"];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
    }
    return  _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"相册";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancel)];
    [self.view addSubview:self.tableView];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[MSJPhotoManager shareManager] loadImages:^(NSMutableArray * models) {
            self.dataSource = [NSMutableArray arrayWithArray:models];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
    });
}


- (void)cancel{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    AlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlbumCell"];
    AlbumModel *model = self.dataSource[indexPath.row];
    cell.albumModel = model;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AlbumModel *model = self.dataSource[indexPath.row];
    MSJImagePickerController *img = [[MSJImagePickerController alloc] init];
    img.name = model.name;
    img.dataSource = model.models;
     UINavigationController * navigation = [[UINavigationController alloc] initWithRootViewController:img];
    [self presentViewController:navigation animated:YES completion:nil];
    
    
}
- (void)dealloc{
    NSLog(@"%@---dealloc",[self class]);
}
@end
