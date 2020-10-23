//
//  ACHomeCollectionCell.m
//  ClipsPackExtension
//
//  Created by wangshuailong on 2020/10/22.
//  Copyright © 2020 APPCLIPS. All rights reserved.
//

#import "ACHomeCollectionCell.h"

@interface ACHomeCollectionCell()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *textTitleLabel;
@property (nonatomic, strong) UIImageView *tipImgView;
@property (nonatomic, strong) UILabel *authorLabel;

@end

@implementation ACHomeCollectionCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setCellViewUI];
    }
    return self;
}

- (void)setCellViewUI{
    self.contentView.layer.borderWidth = 1;
    self.contentView.layer.borderColor = [UIColor grayColor].CGColor;
    self.contentView.layer.cornerRadius = 10;
    self.contentView.layer.masksToBounds = YES;
    
    //
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.contentView);
        make.height.mas_equalTo(109);
    }];
    [self.tipImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(10);
        make.bottom.equalTo(self.contentView).offset(-6);
        make.width.height.mas_equalTo(16);
    }];
    [self.authorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.tipImgView);
        make.left.equalTo(self.tipImgView.mas_right).offset(5);
        make.right.equalTo(self.contentView).offset(-10);
    }];
    [self.textTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.tipImgView);
        make.right.equalTo(self.contentView).offset(-10);
        make.top.equalTo(self.iconImageView.mas_bottom).offset(8);
        make.bottom.lessThanOrEqualTo(self.tipImgView.mas_top).offset(-5);
    }];
}

#pragma mark - Model
- (void)setItemModel:(GRFeedItemModel *)itemModel{
    _itemModel = itemModel;
    
    self.textTitleLabel.text = itemModel.title;
    self.authorLabel.text = itemModel.author;
    
    //图标
    NSString *urlStr = itemModel.iconUrl;
    BOOL show = (urlStr.length > 0 && ([urlStr hasPrefix:@"http://"] || [urlStr hasPrefix:@"https://"]));
    if (show) {
        [self.iconImageView setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"home_feed_bg_deflate_big_light"]];
    } else {
        self.iconImageView.image = [UIImage imageNamed:@"home_feed_bg_deflate_big_light"];
    }
    
    //logo
    if (itemModel.tipImgUrl.length > 0 && [itemModel.tipImgUrl isEqualToString:@"(null)"] == NO) {
        if ([itemModel.tipImgUrl hasPrefix:@"http://"] || [itemModel.tipImgUrl hasPrefix:@"https://"]) {
            [self.tipImgView setImageWithURL:[NSURL URLWithString:itemModel.tipImgUrl] placeholderImage:[UIImage imageNamed:@"home_feed_avatar_light"]];
        } else {
            self.tipImgView.image = [UIImage imageNamed:itemModel.tipImgUrl];
        }
    } else {
        self.tipImgView.image = [UIImage imageNamed:@"home_feed_avatar_light"];
    }
}

#pragma mark - Lazy
- (UIImageView *)iconImageView{
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_feed_bg_deflate_big_light"]];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFill;
        _iconImageView.clipsToBounds = YES;
        [self.contentView addSubview:_iconImageView];
    }
    return _iconImageView;
}

- (UILabel *)textTitleLabel{
    if (!_textTitleLabel) {
        _textTitleLabel = [[UILabel alloc] init];
        _textTitleLabel.textColor = [UIColor blackColor];
        _textTitleLabel.font = [UIFont systemFontOfSize:12];
        _textTitleLabel.numberOfLines = 2;
        _textTitleLabel.text = @"是神马的样式，你来了";
        [self.contentView addSubview:_textTitleLabel];
    }
    return _textTitleLabel;
}

- (UIImageView *)tipImgView{
    if (!_tipImgView) {
        _tipImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_feed_avatar_light"]];
        _tipImgView.layer.cornerRadius = 8;
        _tipImgView.layer.masksToBounds = YES;
        [self.contentView addSubview:_tipImgView];
    }
    return _tipImgView;
}

- (UILabel *)authorLabel{
    if (!_authorLabel) {
        _authorLabel = [[UILabel alloc] init];
        _authorLabel.font = [UIFont systemFontOfSize:11];
        _authorLabel.textColor = GR_HEXCOLORA(0x000000, 0.38);
        _authorLabel.text = @"作诗的人";
        [self.contentView addSubview:_authorLabel];
    }
    return _authorLabel;
}


@end
