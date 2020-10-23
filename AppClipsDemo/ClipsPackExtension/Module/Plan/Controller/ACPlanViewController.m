//
//  ACPlanViewController.m
//  ClipsPackExtension
//
//  Created by wangshuailong on 2020/10/22.
//  Copyright © 2020 APPCLIPS. All rights reserved.
//

#import "ACPlanViewController.h"
#import "ACPlanCollectionCell.h"
#import "ACListViewController.h"

@interface ACPlanViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *planCollectionView;
@property (nonatomic, strong) NSArray *planLists;

@end

static NSString *kACPlanViewControllerKey = @"kACPlanViewControllerKey";

@implementation ACPlanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setPlanViewUI];
}

- (void)setPlanViewUI{
    [self.planCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}


#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.planLists.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ACPlanCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kACPlanViewControllerKey forIndexPath:indexPath];
    
    cell.detailsModel = self.planLists[indexPath.item];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(GRScreenW-20, 80);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 10, 0, 10);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    ACListViewController *listVC = [[ACListViewController alloc] init];
    
    listVC.itemModel = self.planLists[indexPath.item];
    
    [self.navigationController pushViewController:listVC animated:YES];
}

#pragma mark - Lazy
- (UICollectionView *)planCollectionView{
    if (!_planCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = 10;
        flowLayout.minimumInteritemSpacing = 0;
        
        _planCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _planCollectionView.delegate = self;
        _planCollectionView.dataSource = self;
        _planCollectionView.backgroundColor = [UIColor whiteColor];
        
        [_planCollectionView registerClass:[ACPlanCollectionCell class] forCellWithReuseIdentifier:kACPlanViewControllerKey];
        
        [self.view addSubview:_planCollectionView];
    }
    return _planCollectionView;
}

- (NSArray *)planLists{
    if (!_planLists) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"rssRecommend" ofType:@"json"];
        NSString *str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *catArr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSArray *list = [RSSDetailModel mj_objectArrayWithKeyValuesArray:catArr];
        
        _planLists = list;
    }
    return _planLists;
}


@end
