//
//  ACMineViewController.m
//  ClipsPackExtension
//
//  Created by wangshuailong on 2020/10/22.
//  Copyright © 2020 APPCLIPS. All rights reserved.
//

#import "ACMineViewController.h"
#import "ACMineCollectionCell.h"
#import "ACMineHeadCollectionCell.h"
#import "ACMineSectionHeadView.h"

@interface ACMineViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) ACMineSectionHeadView *headView;
@property (nonatomic, strong) UICollectionView *mineCollectionView;
@property (nonatomic, strong) NSArray *mineList;

@end

static NSString *kAACMineCollectionCellKey = @"kAACMineCollectionCellKey";
static NSString *kACMineHeadCollectionCellKey = @"kACMineHeadCollectionCellKey";

@implementation ACMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setMineViewUI];
}

- (void)setMineViewUI{
    [self.headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(GRNavigationBarHeight);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(100);
    }];
    [self.mineCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.headView.mas_bottom);
    }];
}


#pragma mark - UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.mineList.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.mineList[section] count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        ACMineHeadCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kACMineHeadCollectionCellKey forIndexPath:indexPath];
        
        NSArray *list = self.mineList[indexPath.section];
        NSDictionary *dict = list[indexPath.item];
        
        [cell cellTitleWithName:dict[@"TXT"] imgName:dict[@"IMG"]];
        
        return cell;
    }
    
    ACMineCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kAACMineCollectionCellKey forIndexPath:indexPath];
    
    NSArray *list = self.mineList[indexPath.section];
    NSDictionary *dict = list[indexPath.item];
    
    [cell cellTitleWithName:dict[@"TXT"] imgName:dict[@"IMG"]];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return CGSizeMake((GRScreenW-50)/4, 90);
    }
    return CGSizeMake(GRScreenW-20, 60);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 10, 0, 10);;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}


#pragma mark - Lazy
- (ACMineSectionHeadView *)headView{
    if (!_headView) {
        _headView = [[ACMineSectionHeadView alloc] init];
        [self.view addSubview:_headView];
    }
    return _headView;
}

- (UICollectionView *)mineCollectionView{
    if (!_mineCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = 10;
        flowLayout.minimumInteritemSpacing = 0;
        
        _mineCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _mineCollectionView.delegate = self;
        _mineCollectionView.dataSource = self;
        _mineCollectionView.backgroundColor = [UIColor whiteColor];
        
        [_mineCollectionView registerClass:[ACMineCollectionCell class] forCellWithReuseIdentifier:kAACMineCollectionCellKey];
        [_mineCollectionView registerClass:[ACMineHeadCollectionCell class] forCellWithReuseIdentifier:kACMineHeadCollectionCellKey];
        
        [self.view addSubview:_mineCollectionView];
    }
    return _mineCollectionView;
}

- (NSArray *)mineList{
    if (!_mineList) {
        _mineList = @[
            @[
                @{@"TXT":@"订阅管理", @"IMG":@""},
                @{@"TXT":@"我的消息", @"IMG":@""},
                @{@"TXT":@"我的收藏", @"IMG":@""},
                @{@"TXT":@"我要分享", @"IMG":@""},
            ],
            @[
                @{@"TXT":@"获取完整APP", @"IMG":@""},
                @{@"TXT":@"反馈与帮助", @"IMG":@""},
                @{@"TXT":@"设置", @"IMG":@""},
                @{@"TXT":@"关于", @"IMG":@""},
            ]
        ];
    }
    return _mineList;
}


@end
