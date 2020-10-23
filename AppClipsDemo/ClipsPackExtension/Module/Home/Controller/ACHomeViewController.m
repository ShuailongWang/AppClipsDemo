//
//  ACHomeViewController.m
//  ClipsPackExtension
//
//  Created by wangshuailong on 2020/10/22.
//  Copyright © 2020 APPCLIPS. All rights reserved.
//

#import "ACHomeViewController.h"
#import "ACHomeCollectionCell.h"
#import <StoreKit/StoreKit.h>
#import "ACWebViewController.h"

@interface ACHomeViewController () <SKOverlayDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *homeCollectionView;
@property (nonatomic, strong) NSArray *recomList;
@property (nonatomic, strong) NSMutableArray *tableListM;
@property (nonatomic, assign) NSUInteger page;

@end

static NSString *kACHomeCollectionCellKey = @"kACHomeCollectionCellKey";

@implementation ACHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setHomeViewUI];
    [self reloadFeedItems];
    
    if (self.tableListM.count == 0) {
        [self.homeCollectionView.mj_header beginRefreshing];
    }
}

- (void)setHomeViewUI{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Pro版" style:UIBarButtonItemStyleDone target:self action:@selector(getFullApp)];
    
    [self.homeCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - Get
- (void)fetchAllFeeds{
    //网络请求
    __weak __typeof(self) weakSelf = self;
    [[GRFeedAPIManager shareInstance] fetchAllFeedWithModelArray:self.recomList type:HOME_RECOMMEND complation:^() {
        weakSelf.page = 0;
        [weakSelf.tableListM removeAllObjects];
        [weakSelf.homeCollectionView.mj_header endRefreshing];
        [weakSelf reloadFeedItems];
    }];
}

- (void)reloadFeedItems{
    __weak __typeof(self) weakSelf = self;
    [GRRSSFeedDBHelper selectRecommendFeedItemWIthPage:self.page feeds:self.recomList type:HOME_RECOMMEND complatiion:^(NSArray * _Nullable modelList) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //
            if (modelList.count > 0) {
                [weakSelf.tableListM addObjectsFromArray:modelList];
                
                [weakSelf.homeCollectionView.mj_footer endRefreshing];
            } else {
                [weakSelf.homeCollectionView.mj_footer endRefreshingWithNoMoreData];
            }
            
            [weakSelf.homeCollectionView reloadData];
            weakSelf.homeCollectionView.mj_footer.hidden = (self.tableListM.count == 0);
        });
    }];
    self.page++;
}

#pragma mark - click
- (void)getFullApp{
    UIWindowScene *scene = [UIApplication sharedApplication].windows.firstObject.windowScene;
    if (scene) {
        SKOverlayAppClipConfiguration *config = [[SKOverlayAppClipConfiguration alloc] initWithPosition:SKOverlayPositionBottom];
        
        SKOverlay *over = [[SKOverlay alloc] initWithConfiguration:config];
        over.delegate = self;
        
        [over presentInScene:scene];
    }
}

#pragma mark - SKOverlayDelegate

- (void)storeOverlay:(SKOverlay *)overlay didFinishDismissal:(SKOverlayTransitionContext *)transitionContext{
    NSLog(@"didFinishDismissal");
}

- (void)storeOverlay:(SKOverlay *)overlay willStartDismissal:(SKOverlayTransitionContext *)transitionContext{
    NSLog(@"willStartDismissal");
}

- (void)storeOverlay:(SKOverlay *)overlay didFinishPresentation:(SKOverlayTransitionContext *)transitionContext{
    NSLog(@"didFinishPresentation");
}

- (void)storeOverlay:(SKOverlay *)overlay willStartPresentation:(SKOverlayTransitionContext *)transitionContext{
    NSLog(@"willStartPresentation");
}

- (void)storeOverlay:(SKOverlay *)overlay didFailToLoadWithError:(NSError *)error{
    NSLog(@"didFailToLoadWithError");
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
- (UICollectionView *)homeCollectionView{
    if (!_homeCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = 10;
        flowLayout.minimumInteritemSpacing = 0;
        
        _homeCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _homeCollectionView.delegate = self;
        _homeCollectionView.dataSource = self;
        _homeCollectionView.backgroundColor = [UIColor whiteColor];
        
        [_homeCollectionView registerClass:[ACHomeCollectionCell class] forCellWithReuseIdentifier:kACHomeCollectionCellKey];
        
        //上拉加载
        _homeCollectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(reloadFeedItems)];
        MJRefreshAutoNormalFooter *footer = (MJRefreshAutoNormalFooter *)_homeCollectionView.mj_footer;
        footer.hidden = YES;
        footer.stateLabel.textColor = GR_HEXCOLOR(0x999999);
        [footer setTitle:@"获取数据..." forState:MJRefreshStateRefreshing];
        [footer setTitle:@"—— 已经到底部了 ——" forState:MJRefreshStateNoMoreData];
        
        __weak __typeof(self) weakSelf = self;
        _homeCollectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [weakSelf fetchAllFeeds];
        }];
        MJRefreshNormalHeader *header = (MJRefreshNormalHeader *)_homeCollectionView.mj_header;
        header.lastUpdatedTimeLabel.hidden = YES;
        [header.arrowView setImage:[UIImage imageNamed:@""]];
        header.stateLabel.font = [UIFont systemFontOfSize:13];
        header.stateLabel.textColor = GR_HEXCOLOR(0x999999);
        [header setTitle:@"下拉更新数据" forState:MJRefreshStateIdle];
        [header setTitle:@"松开立刻更新" forState:MJRefreshStatePulling];
        [header setTitle:@"更新数据..." forState:MJRefreshStateRefreshing];
        
        
        [self.view addSubview:_homeCollectionView];
    }
    return _homeCollectionView;
}

- (NSMutableArray *)tableListM{
    if (!_tableListM) {
        _tableListM = [NSMutableArray array];
    }
    return _tableListM;
}

- (NSArray *)recomList{
    if (!_recomList) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"rssHome" ofType:@"json"];
        NSString *str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *catArr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        
        //
        NSMutableArray *arrM = [NSMutableArray array];
        for (NSDictionary *dict in catArr) {
            NSString *link = [dict objectForKey:@"link"];
            //判断连接
            if (link.length > 0) {
                //
                [arrM addObject:link];
                
                //插入数据库中
                GRFeedContentModel *feedModel = [GRFeedContentModel defauleFeedModel];
                feedModel.title = [dict objectForKey:@"link"];
                feedModel.feedUrl = [dict objectForKey:@"title"];
                feedModel.imageUrl = ([[dict objectForKey:@"imgName"] length] == 0) ? [dict objectForKey:@"iconURL"] : [dict objectForKey:@"imgName"];
                
                [GRRSSFeedDBHelper insertRecommendOrSubWithFeedmodel:feedModel type:HOME_RECOMMEND];
            }
        }
        
        //
        _recomList = arrM.copy;
    }
    return _recomList;
}


@end
