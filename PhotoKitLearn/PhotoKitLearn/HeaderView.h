//
//  HeaderView.h
//  Image练习
//
//  Created by zlhj on 2018/7/23.
//  Copyright © 2018年 MSJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReactiveObjC.h"
@interface HeaderView : UICollectionReusableView
@property (strong, nonatomic) IBOutlet UIButton *Upload;
@property (strong, nonatomic) IBOutlet UILabel *title;
@property (nonatomic,strong) RACSubject * subject;
@end
