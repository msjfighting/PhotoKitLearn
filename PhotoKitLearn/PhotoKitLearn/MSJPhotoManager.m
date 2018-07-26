//
//  MSJPhotoManager.m
//  Image练习
//
//  Created by zlhj on 2018/7/24.
//  Copyright © 2018年 MSJ. All rights reserved.
//

#import "MSJPhotoManager.h"
#import "AlbumModel.h"
@implementation MSJPhotoManager
static MSJPhotoManager *shareManager;
+ (instancetype)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[MSJPhotoManager alloc] init];
    });
    return shareManager;
}
// 保存图片到相册
- (void)saveImageFinished:(UIImage *)image
{
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
        //写入图片到相册
    [PHAssetChangeRequest creationRequestForAssetFromImage:image];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        
        NSLog(@"success = %d, error = %@", success, error);
        
    }];
}


// 根据您assset获取图片
- (void)fetchImageByAsset:(PHAsset *)asset imageBlock:(void (^)(NSData * imgData))imageBlock{
    
//PHImageRequestOptions: 如上面所说，控制加载图片时的一系列参数
    
    PHImageRequestOptions * options = [[PHImageRequestOptions alloc]init];
    options.deliveryMode=PHImageRequestOptionsDeliveryModeHighQualityFormat;
//PHImageManager:用于处理资源的加载，加载图片的过程带有缓存处理，可以通过传入一个 PHImageRequestOptions 控制资源的输出尺寸等规格
     /**
      asset:图像对应的asset
      targetSize:需要获取的图像的尺寸,如果输入的尺寸大于资源原图的尺寸,则只会返回原图.需要注意在PHImageManager中,所有的尺寸都是用pixel为单位,因此这里想要获得正确大小的图像,需要把输入的尺寸转换为pixel.如果需要返回原图,可以传入PhotoKit中预先定义好的常量,PHImageManagerMaximumSize,表示返回可选范围的最大尺寸,即原图
      contentMode:图像的剪裁方式,与UIView的contentMode参数相似,控制照片应该以按比例缩放还是按比例填充的方式放到最终展示的容器内.注意如果targetSize传入PHImageManagerMaximumSize,则contentMode无论传入什么值都会被视为PHImageContentModeDefault.
      options:可以控制图像的质量,版本,剪裁
      resultHandler:请求结束后的回调,返回一个包含资源对于图像的UIImage和包含图像信息的NSDictionary,在整个请求周期中,这个block可能会被多次调用
      */
     [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:[UIScreen mainScreen].bounds.size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result,NSDictionary * _Nullable info) {
       // 得到图片资源
         NSData *data = UIImagePNGRepresentation(result);
         imageBlock(data);
    }];
}
-(void)loadImages:(void (^)(NSMutableArray * models))images{
    NSMutableArray *photos = [NSMutableArray array];
    PHAssetCollectionSubtype subType =PHAssetCollectionSubtypeSmartAlbumRecentlyAdded| PHAssetCollectionSubtypeSmartAlbumUserLibrary|PHAssetCollectionSubtypeSmartAlbumScreenshots|PHAssetCollectionSubtypeSmartAlbumSelfPortraits;
    PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:subType options:nil];
       [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PHAssetCollection *assColl = (PHAssetCollection *)obj;
           [self getAssetInAssetCollection:assColl isSort:NO albumBlock:^(NSArray * albums) {
               if ([albums count]) {
                   AlbumModel *model = [[AlbumModel alloc] init];
                   model.name = [self transformAblumTitle:assColl.localizedTitle];// 相册名
                   model.count = albums.count;
                   model.firstAsset = [albums firstObject];
                   model.models = albums;
                   model.result = [self fetchAssetInCollection:assColl isSort:NO]; // 保存这个相册的内容
                   if (![model.name isEqualToString:@"最近删除"]) {
                       [photos addObject:model];
                   }
               }
           }];
       }];
       if (images != nil) {
          images(photos);
       }
}
- (NSString *)transformAblumTitle:(NSString *)title
{
    if ([title isEqualToString:@"Slo-mo"]) {
        return @"慢动作";
    } else if ([title isEqualToString:@"Recently Added"]) {
        return @"最近添加";
    } else if ([title isEqualToString:@"Favorites"]) {
        return @"最爱";
    } else if ([title isEqualToString:@"Recently Deleted"]) {
        return @"最近删除";
    } else if ([title isEqualToString:@"Videos"]) {
        return @"视频";
    } else if ([title isEqualToString:@"All Photos"]) {
        return @"所有照片";
    } else if ([title isEqualToString:@"Selfies"]) {
        return @"自拍";
    } else if ([title isEqualToString:@"Screenshots"]) {
        return @"屏幕快照";
    } else if ([title isEqualToString:@"Camera Roll"]) {
        return @"相机胶卷";
    }
    return nil;
}

- (void)getAssetInAssetCollection:(PHAssetCollection *)collection isSort:(BOOL)sort albumBlock:(void(^)(NSArray * albums))albums{
     NSMutableArray *photos = [NSMutableArray array];
    PHFetchResult *results = [self fetchAssetInCollection:collection isSort:sort];
    [results enumerateObjectsUsingBlock:^(PHAsset  * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.mediaType == PHAssetMediaTypeImage) {
             [photos addObject:obj];
        }
    }];
    albums(photos);
}
- (PHFetchResult *)fetchAssetInCollection:(PHAssetCollection *)collection isSort:(BOOL)sort{
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:sort]];
    PHFetchResult *results = [PHAsset fetchAssetsInAssetCollection:collection options:options];
    return  results;
}
/** 解决旋转90度问题 */
+ (UIImage *)fixOrientation:(UIImage *)aImage
{
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}
@end
