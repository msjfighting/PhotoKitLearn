//
//  HeaderView.m
//  Image练习
//
//  Created by zlhj on 2018/7/23.
//  Copyright © 2018年 MSJ. All rights reserved.
//

#import "HeaderView.h"
@interface HeaderView()

@end

@implementation HeaderView
- (void)awakeFromNib{
    [super awakeFromNib];
    self.title.text = @"测试测试";

}

- (RACSubject *)subject{
    if (!_subject) {
        _subject = [[RACSubject alloc] init];
    }
    return _subject;
}

@end
