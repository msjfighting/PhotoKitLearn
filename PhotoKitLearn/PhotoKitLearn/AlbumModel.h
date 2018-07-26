//
//  AlbumModel.h
//  Image练习
//
//  Created by zlhj on 2018/7/24.
//  Copyright © 2018年 MSJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlbumModel : NSObject
@property (nonatomic,copy) NSString * name;
@property (nonatomic,assign) NSInteger  count;
@property (nonatomic,strong) id  result;//相册的内容

@property (nonatomic,strong) NSArray * models; //
@property (nonatomic,strong) id  firstAsset; //  相册的第一个内容
@end
