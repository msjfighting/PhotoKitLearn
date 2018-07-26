//
//  MSJImagePickerController.m
//  Image练习
//
//  Created by zlhj on 2018/7/24.
//  Copyright © 2018年 MSJ. All rights reserved.
//

#import "MSJImagePickerController.h"
#import "ImageCell.h"
#import "MSJPhotoManager.h"
#import "ImageModel.h"
#import "AlbumModel.h"
#define ScreenWidth [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight [[UIScreen mainScreen] bounds].size.height
@interface MSJImagePickerController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic,strong) UICollectionView * collectionView;
@property (nonatomic,strong) NSMutableArray * selectedArray;
//@property (nonatomic,strong) NSMutableArray * indexArray;
@end

@implementation MSJImagePickerController
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *lay = [[UICollectionViewFlowLayout alloc] init];
        lay.itemSize = CGSizeMake(100, 120);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight) collectionViewLayout:lay];
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerNib:[UINib nibWithNibName:@"ImageCell" bundle:nil] forCellWithReuseIdentifier:@"ImageCell"];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.allowsMultipleSelection = YES;// 多选
    }
    
    return _collectionView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _selectedArray = [NSMutableArray arrayWithCapacity:0];
//    _indexArray = [NSMutableArray arrayWithCapacity:0];
    self.navigationItem.title = self.name;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(complete)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancel)];
    [self.view addSubview:self.collectionView];
 
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (self.dataSource.count > 0) {
        return self.dataSource.count;
    }
    return 0;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"ImageCell";
    ImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    PHAsset *asset = self.dataSource[indexPath.row];
    
    ImageModel *imgModel = [[ImageModel alloc] init];
    imgModel.name = [asset valueForKey:@"filename"];
    imgModel.asset = asset;
    cell.imageModel = imgModel;
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    PHAsset *asset = self.dataSource[indexPath.row];
    ImageCell *cell = (ImageCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.desc.backgroundColor = [UIColor redColor];
    
    [self.selectedArray addObject:asset];
//    [self.indexArray addObject:indexPath];

}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    PHAsset *asset = self.dataSource[indexPath.row];
    ImageCell *cell = (ImageCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.desc.backgroundColor = [UIColor whiteColor];
    
    [self.selectedArray removeObject:asset];
//    [self.indexArray removeObject:indexPath];
}
/**
 * Cell多选时是否支持取消功能
 */
- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)cancel{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)complete{
    UIViewController * controller = self.presentingViewController;
    [self dismissViewControllerAnimated:YES completion:^{
        UIViewController * c = controller.presentingViewController;
        [controller dismissViewControllerAnimated:YES completion:^{
            [c dismissViewControllerAnimated:YES completion:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Image" object:self.selectedArray];
        }];
    }];
}
- (void)dealloc{
    NSLog(@"%@---dealloc",[self class]);
}
@end
