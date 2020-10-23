//
//  ACPlanCollectionCell.m
//  AppClipsDemo
//
//  Created by wangshuailong on 2020/10/23.
//  Copyright © 2020 APPCLIPS. All rights reserved.
//

#import "ACPlanCollectionCell.h"

@interface ACPlanCollectionCell()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *textTitleLabel;
@property (nonatomic, strong) UILabel *detailsTextLabel;

@end

@implementation ACPlanCollectionCell

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
        make.width.height.mas_equalTo(60);
        make.centerY.equalTo(self.contentView);
    }];
    [self.textTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImageView.mas_right).offset(10);
        make.right.equalTo(self.contentView).offset(-10);
        make.top.equalTo(self.iconImageView).offset(5);
    }];
    [self.detailsTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.textTitleLabel);
        make.top.equalTo(self.textTitleLabel.mas_bottom).offset(10);
    }];
}

#pragma mark - Model
- (void)setDetailsModel:(RSSDetailModel *)detailsModel{
    _detailsModel = detailsModel;
    
    UIImage *phImg = [UIImage imageNamed:@""];
    if (detailsModel.imgName.length > 0) {
        self.iconImageView.image = [UIImage imageNamed:detailsModel.imgName];
    } else if (detailsModel.iconURL.length > 0) {
        NSURL *url = [NSURL URLWithString:detailsModel.iconURL];
        [self.iconImageView sd_setImageWithURL:url placeholderImage:phImg];
    } else {
        self.iconImageView.image = phImg;
    }
    
    self.textTitleLabel.text = detailsModel.title;
    
    if (detailsModel.info.length == 0) {
        self.detailsTextLabel.text = @"它还没有过多的自我介绍～";
    } else {
        self.detailsTextLabel.text = detailsModel.info;
    }
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
        _textTitleLabel.font = [UIFont systemFontOfSize:17];
        _textTitleLabel.textColor = [UIColor blackColor];
        _textTitleLabel.text = @"大标题";
        [self.contentView addSubview:_textTitleLabel];
    }
    return _textTitleLabel;
}

- (UILabel *)detailsTextLabel{
    if (!_detailsTextLabel) {
        _detailsTextLabel = [[UILabel alloc] init];
        _detailsTextLabel.font = [UIFont systemFontOfSize:15];
        _detailsTextLabel.textColor = GR_HEXCOLORA(0x000000, 0.38);
        _detailsTextLabel.text = @"详情";
        [self.contentView addSubview:_detailsTextLabel];
    }
    return _detailsTextLabel;
}

@end
