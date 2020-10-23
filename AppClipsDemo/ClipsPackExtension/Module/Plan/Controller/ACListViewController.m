//
//  ACListViewController.m
//  AppClipsDemo
//
//  Created by wangshuailong on 2020/10/23.
//  Copyright © 2020 APPCLIPS. All rights reserved.
//

#import "ACListViewController.h"
#import "ACHomeCollectionCell.h"
#import "ACWebViewController.h"
#import <StoreKit/StoreKit.h>

@interface ACListViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *listCollectionView;
@property (nonatomic, strong) NSMutableArray *tableListM;
@property (nonatomic, assign) NSInteger page;

@end

static NSString *kACHomeCollectionCellKey = @"kACHomeCollectionCellKey";

@implementation ACListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setHomeViewUI];
    [self reloadFeedItems];
    
    [self.listCollectionView.mj_header beginRefreshing];
}

- (void)setHomeViewUI{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"订阅" style:UIBarButtonItemStyleDone target:self action:@selector(getFullApp)];
    
    [self.listCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    /*
     obfs4
     */
}

- (void)getFullApp{
    UIWindowScene *scene = [UIApplication sharedApplication].windows.firstObject.windowScene;
    if (scene) {
        SKOverlayAppClipConfiguration *config = [[SKOverlayAppClipConfiguration alloc] initWithPosition:SKOverlayPositionBottom];
        SKOverlay *over = [[SKOverlay alloc] initWithConfiguration:config];
        [over presentInScene:scene];
    }
}

- (void)setItemModel:(RSSDetailModel *)itemModel{
    _itemModel = itemModel;
    
    self.title = itemModel.title;
}

#pragma mark - Get
- (void)fetchAllFeeds{
    //网络请求
    __weak __typeof(self) weakSelf = self;
    [[GRFeedAPIManager shareInstance] fecthGetListWithUrl:self.itemModel.link imgUrl:@"" complation:^(GRFeedContentModel * _Nullable feedModel, NSError * _Nullable error) {
        self.page = 0;
        [weakSelf.tableListM removeAllObjects];
        [weakSelf.listCollectionView.mj_header endRefreshing];
        [weakSelf reloadFeedItems];
    }];
}

- (void)reloadFeedItems{
    __weak __typeof(self) weakSelf = self;
    [GRRSSFeedDBHelper selectDetailFeedItemWIthPage:self.page andUrl:self.itemModel.link complatiion:^(NSArray * _Nullable modelList) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //
            if (modelList.count > 0) {
                [weakSelf.tableListM addObjectsFromArray:modelList];
                
                [weakSelf.listCollectionView.mj_footer endRefreshing];
            } else {
                [weakSelf.listCollectionView.mj_footer endRefreshingWithNoMoreData];
            }

            [weakSelf.listCollectionView reloadData];
            weakSelf.listCollectionView.mj_footer.hidden = (self.tableListM.count == 0);
        });
    }];
    self.page++;
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.tableListM.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ACHomeCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kACHomeCollectionCellKey forIndexPath:indexPath];
    
    cell.itemModel = self.tableListM[indexPath.item];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((GRScreenW-30)/2, 190);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 10, 0, 10);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    ACWebViewController *webVC = [[ACWebViewController alloc] init];
    
    GRFeedItemModel *itemModel = self.tableListM[indexPath.item];
    webVC.itemModel = itemModel;
    
    [self.navigationController pushViewController:webVC animated:YES];
}

#pragma mark - Lazy
- (UICollectionView *)listCollectionView{
    if (!_listCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = 10;
        flowLayout.minimumInteritemSpacing = 0;
        
        _listCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _listCollectionView.delegate = self;
        _listCollectionView.dataSource = self;
        _listCollectionView.backgroundColor = [UIColor whiteColor];
        
        [_listCollectionView registerClass:[ACHomeCollectionCell class] forCellWithReuseIdentifier:kACHomeCollectionCellKey];
        
        //上拉加载
        _listCollectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(reloadFeedItems)];
        MJRefreshAutoNormalFooter *footer = (MJRefreshAutoNormalFooter *)_listCollectionView.mj_footer;
        footer.hidden = YES;
        footer.stateLabel.textColor = GR_HEXCOLOR(0x999999);
        [footer setTitle:@"获取数据..." forState:MJRefreshStateRefreshing];
        [footer setTitle:@"—— 已经到底部了 ——" forState:MJRefreshStateNoMoreData];
        
        __weak __typeof(self) weakSelf = self;
        _listCollectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [weakSelf fetchAllFeeds];
        }];
        MJRefreshNormalHeader *header = (MJRefreshNormalHeader *)_listCollectionView.mj_header;
        header.lastUpdatedTimeLabel.hidden = YES;
        [header.arrowView setImage:[UIImage imageNamed:@""]];
        header.stateLabel.font = [UIFont systemFontOfSize:13];
        header.stateLabel.textColor = GR_HEXCOLOR(0x999999);
        [header setTitle:@"下拉更新数据" forState:MJRefreshStateIdle];
        [header setTitle:@"松开立刻更新" forState:MJRefreshStatePulling];
        [header setTitle:@"更新数据..." forState:MJRefreshStateRefreshing];
        
        
        [self.view addSubview:_listCollectionView];
    }
    return _listCollectionView;
}

- (NSMutableArray *)tableListM{
    if (!_tableListM) {
        _tableListM = [NSMutableArray array];
    }
    return _tableListM;
}



@end
