//
//  AlbumCell.m
//  Image练习
//
//  Created by zlhj on 2018/7/24.
//  Copyright © 2018年 MSJ. All rights reserved.
//

#import "AlbumCell.h"
#import <Photos/Photos.h>
#import "MSJPhotoManager.h"
@interface AlbumCell ()
@property (nonatomic,strong) UILabel * photoName;
@property (nonatomic,strong) UIImageView * photos;
@end
@implementation AlbumCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}
- (void)setAlbumModel:(AlbumModel *)albumModel{
    _albumModel = albumModel;
    NSMutableAttributedString *name = [[NSMutableAttributedString alloc] initWithString:_albumModel.name attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor blackColor]}];
    NSAttributedString *countString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  (%zd)",_albumModel.count]];
    [name appendAttributedString:countString];
    self.photoName.attributedText = name;
    PHAsset *asset = _albumModel.firstAsset;
    
    [[MSJPhotoManager shareManager] fetchImageByAsset:asset imageBlock:^(NSData *imgData) {
        UIImage *img = [UIImage imageWithData:imgData];
        self.photos.image = img;
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSInteger titleHeight = ceil(self.photoName.font.lineHeight);
    self.photoName.frame = CGRectMake(90, (self.frame.size.height - titleHeight) / 2, self.frame.size.width - 80 - 50, titleHeight);
    self.photos.frame = CGRectMake(5, 5, 70, 70);
}
#pragma mark - Lazy load

- (UIImageView *)photos {
    if (_photos == nil) {
        UIImageView *posterImageView = [[UIImageView alloc] init];
        posterImageView.contentMode = UIViewContentModeScaleAspectFill;
        posterImageView.clipsToBounds = YES;
        [self.contentView addSubview:posterImageView];
        _photos = posterImageView;
    }
    return _photos;
}

- (UILabel *)photoName {
    if (_photoName == nil) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont boldSystemFontOfSize:17];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:titleLabel];
        _photoName = titleLabel;
    }
    return _photoName;
}

@end
