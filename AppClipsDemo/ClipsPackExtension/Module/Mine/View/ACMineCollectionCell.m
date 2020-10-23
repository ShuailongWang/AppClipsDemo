//
//  ACMineCollectionCell.m
//  ClipsPackExtension
//
//  Created by wangshuailong on 2020/10/23.
//  Copyright © 2020 APPCLIPS. All rights reserved.
//

#import "ACMineCollectionCell.h"

@interface ACMineCollectionCell()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *textTitleLabel;

@end

@implementation ACMineCollectionCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupCellViewUI];
    }
    return self;
}

- (void)setupCellViewUI{
    self.contentView.layer.borderWidth = 1;
    self.contentView.layer.borderColor = [UIColor grayColor].CGColor;
    self.contentView.layer.cornerRadius = 10;
    self.contentView.layer.masksToBounds = YES;
    
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(10);
        make.width.height.mas_equalTo(30);
        make.centerY.equalTo(self.contentView);
    }];
    [self.textTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImageView.mas_right).offset(10);
        make.right.equalTo(self.contentView).offset(-10);
        make.centerY.equalTo(self.iconImageView);
    }];
}


#pragma mark - Content
- (void)cellTitleWithName:(NSString*)name imgName:(NSString*)imgName{
    self.iconImageView.image = [UIImage imageNamed:imgName];
    self.textTitleLabel.text = name;
}

#pragma mark - Lazy
- (UIImageView *)iconImageView{
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.layer.cornerRadius = 10;
        _iconImageView.layer.masksToBounds = YES;
        _iconImageView.backgroundColor = [UIColor grayColor];
        [self.contentView addSubview:_iconImageView];
    }
    return _iconImageView;
}

- (UILabel *)textTitleLabel{
    if (!_textTitleLabel) {
        _textTitleLabel = [[UILabel alloc] init];
        _textTitleLabel.font = [UIFont systemFontOfSize:15];
        _textTitleLabel.textColor = [UIColor blackColor];
        _textTitleLabel.text = @"大标题";
        [self.contentView addSubview:_textTitleLabel];
    }
    return _textTitleLabel;
}


@end
