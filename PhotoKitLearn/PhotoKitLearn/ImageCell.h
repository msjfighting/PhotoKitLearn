//
//  ImageCell.h
//  Image练习
//
//  Created by zlhj on 2018/7/23.
//  Copyright © 2018年 MSJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageModel.h"
@interface ImageCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *photoView;
@property (strong, nonatomic) IBOutlet UILabel *desc;
@property (nonatomic,strong) ImageModel * imageModel;
@end
