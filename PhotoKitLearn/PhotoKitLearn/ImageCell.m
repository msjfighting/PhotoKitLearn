//
//  ImageCell.m
//  Image练习
//
//  Created by zlhj on 2018/7/23.
//  Copyright © 2018年 MSJ. All rights reserved.
//

#import "ImageCell.h"
#import <Photos/Photos.h>
#import "MSJPhotoManager.h"
@implementation ImageCell
- (void)awakeFromNib{
    [super awakeFromNib];
    self.desc.textColor = [UIColor  blackColor];
    self.desc.textAlignment = NSTextAlignmentCenter;
    self.photoView.backgroundColor = [UIColor whiteColor];
    
}

- (void)setImageModel:(ImageModel *)imageModel{
    _imageModel = imageModel;
    NSMutableAttributedString *name = [[NSMutableAttributedString alloc] initWithString:_imageModel.name attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor blackColor]}];
  
    self.desc.attributedText = name;
    PHAsset *asset = _imageModel.asset;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[MSJPhotoManager shareManager] fetchImageByAsset:asset imageBlock:^(NSData *imgData) {
            UIImage *img = [UIImage imageWithData:imgData];
            dispatch_async(dispatch_get_main_queue(), ^{
                 self.photoView.image = img;
            });
        }];
    });
   
    
}
@end
