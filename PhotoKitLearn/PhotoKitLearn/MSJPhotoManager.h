//
//  MSJPhotoManager.h
//  Image练习
//
//  Created by zlhj on 2018/7/24.
//  Copyright © 2018年 MSJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
@interface MSJPhotoManager : NSObject
+(instancetype)shareManager;
// 通过asset得到一张图片信息
- (void)fetchImageByAsset:(PHAsset *)asset imageBlock:(void(^)(NSData * imgData))imageBlock;
// 获取所有相册信息
- (void)loadImages:(void(^)(NSMutableArray * models))images;
@end
