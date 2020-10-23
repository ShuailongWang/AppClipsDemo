//
//  ACMineSectionHeadView.m
//  ClipsPackExtension
//
//  Created by wangshuailong on 2020/10/23.
//  Copyright © 2020 APPCLIPS. All rights reserved.
//

#import "ACMineSectionHeadView.h"

@interface ACMineSectionHeadView()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *textTitleLabel;

@end

@implementation ACMineSectionHeadView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupViewUI];
    }
    return self;
}

- (void)setupViewUI{
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(15);
        make.width.height.mas_equalTo(70);
        make.centerY.equalTo(self);
    }];
    [self.textTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImageView.mas_right).offset(10);
        make.right.equalTo(self).offset(-10);
        make.centerY.equalTo(self.iconImageView);
    }];
}


#pragma mark - Lazy
- (UIImageView *)iconImageView{
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.layer.cornerRadius = 35;
        _iconImageView.layer.masksToBounds = YES;
        _iconImageView.backgroundColor = [UIColor grayColor];
        [self addSubview:_iconImageView];
    }
    return _iconImageView;
}

- (UILabel *)textTitleLabel{
    if (!_textTitleLabel) {
        _textTitleLabel = [[UILabel alloc] init];
        _textTitleLabel.font = [UIFont boldSystemFontOfSize:20];
        _textTitleLabel.textColor = [UIColor blackColor];
        _textTitleLabel.text = @"我的大名";
        [self addSubview:_textTitleLabel];
    }
    return _textTitleLabel;
}



@end
