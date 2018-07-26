//
//  ViewController.m
//  Image练习
//
//  Created by zlhj on 2018/7/23.
//  Copyright © 2018年 MSJ. All rights reserved.
//

#import "ViewController.h"
#import "ImageCell.h"
#import "HeaderView.h"
#import "ReactiveObjC.h"
#import <Photos/Photos.h>   // AssetsLibrary 在iOS9中不推荐使用了
#import "MSJAlbumViewController.h"
@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic,strong) UICollectionView * collView;
@property (nonatomic,strong) NSMutableArray * dataArr;
@property (nonatomic,strong) UIImagePickerController * imagePick;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.navigationController.navigationBarHidden = YES;
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"Image" object:nil] subscribeNext:^(NSNotification *notification) {
        NSArray *arr = notification.object;
        for (PHAsset *ass in arr) {
            [self.dataArr addObject:ass];
        }
        [self.collView reloadData];
    }];
    [self.view addSubview:self.collView];
}
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [[NSMutableArray alloc] init ];
    }
    return _dataArr;
}
- (UICollectionView *)collView{
    if (!_collView) {
        UICollectionViewFlowLayout *lay = [[UICollectionViewFlowLayout alloc] init];
        lay.itemSize = CGSizeMake(100, 120);
        _collView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) collectionViewLayout:lay];
        // 注册cell
        _collView.backgroundColor = [UIColor whiteColor];
        [_collView registerNib:[UINib nibWithNibName:@"ImageCell" bundle:nil] forCellWithReuseIdentifier:@"ImageCell"];
        [_collView registerNib:[UINib nibWithNibName:@"HeaderView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
        _collView.delegate = self;
        _collView.dataSource = self;
    }
    return _collView;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArr.count;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"ImageCell";
    ImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    PHAsset *asset = self.dataArr[indexPath.row];
    
    ImageModel *imgModel = [[ImageModel alloc] init];
    imgModel.name = [asset valueForKey:@"filename"];
    imgModel.asset = asset;
    cell.imageModel = imgModel;
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(0, 55);
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if (kind == UICollectionElementKindSectionHeader) {
        HeaderView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        
        [[view.Upload rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            // 弹出选择相册或者相机的选项卡
            UIAlertController *al = [UIAlertController alertControllerWithTitle:@"标题" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction *ac1 = [UIAlertAction  actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self openCamera];
            }];
            UIAlertAction *ac2 = [UIAlertAction  actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self openAlbum];
            }];
            UIAlertAction *ac3 = [UIAlertAction  actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            
            [al addAction:ac1];
            [al addAction:ac2];
            [al addAction:ac3];
            [self presentViewController:al animated:YES completion:nil];
            
        }];
        return view;
    }
    return nil;
}
- (void)openCamera{
    AVAuthorizationStatus statue = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (statue == AVAuthorizationStatusRestricted || statue ==AVAuthorizationStatusDenied)
    {
        //无权限
    }else{
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
           UIImagePickerController *pick = [[UIImagePickerController alloc] init];
//             图片选择器 设置选择的资源为相册
//         UIImagePickerControllerSourceTypeSavedPhotosAlbum 相薄
           pick.sourceType = UIImagePickerControllerSourceTypeCamera;
           pick.delegate =self;
           [self presentViewController:pick animated:YES completion:nil];
        }
    }
}
- (void)openAlbum{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied){
        //无权限
    }else{
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
//            UIImagePickerController *pick = [[UIImagePickerController alloc] init];
            // 图片选择器 设置选择的资源为相册
            //UIImagePickerControllerSourceTypeSavedPhotosAlbum 相薄
//            pick.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//            pick.delegate =self;
//            [self presentViewController:pick animated:YES completion:nil];
            
            MSJAlbumViewController *picker = [[MSJAlbumViewController alloc] init];
            UINavigationController * navigation = [[UINavigationController alloc] initWithRootViewController:picker];
            
            [self presentViewController:navigation animated:YES completion:nil];
            
        }
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
     UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        /**
         第一个参数是要保存到相册的图片对象
         第二个参数是保存完成后回调的目标对象
         第三个参数就是保存完成后回调到目标对象的哪个方法中
         第四个参数在保存完成后，会原封不动地传回到回调方法的contextInfo参数中。
         */
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }else{
        [self.dataArr addObject:image];
        [self.collView reloadData];
    }
     [self dismissViewControllerAnimated:YES completion:nil];
}
// 取消选取调用的方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
