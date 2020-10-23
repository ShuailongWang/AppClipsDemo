//
//  ACWebViewController.m
//  AppClipsDemo
//
//  Created by wangshuailong on 2020/10/23.
//  Copyright © 2020 APPCLIPS. All rights reserved.
//

#import "ACWebViewController.h"
#import <WebKit/WebKit.h>

@interface ACWebViewController () <WKUIDelegate, WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *myWebView;
@property (nonatomic,strong) UIProgressView *myProgressView;

@end

@implementation ACWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setViewUI];
}

- (void)setViewUI{
    [self.myWebView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.myProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.height.mas_equalTo(1);
    }];
    
    
    NSURL *url = [NSURL URLWithString:self.itemModel.link];
    NSMutableURLRequest *requestM = [NSMutableURLRequest requestWithURL:url];
    [self.myWebView loadRequest:requestM];
}

- (void)setItemModel:(GRFeedItemModel *)itemModel{
    _itemModel = itemModel;
    
    self.title = itemModel.title;
}

#pragma mark - 进度条
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if (object == self.myWebView && [keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        self.myProgressView.alpha = 1.0f;
        [self.myProgressView setProgress:newprogress animated:YES];
        if (newprogress >= 1.0f) {
            [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.myProgressView.alpha = 0.0f;
            } completion:^(BOOL finished) {
                [self.myProgressView setProgress:0 animated:NO];
            }];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - lazy
- (WKWebView *)myWebView{
    if (!_myWebView) {
        WKWebViewConfiguration *configuration = [WKWebViewConfiguration new];
        configuration.processPool = [WKProcessPool new];
        configuration.allowsInlineMediaPlayback = YES;
        configuration.mediaTypesRequiringUserActionForPlayback = NO;
        
        _myWebView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
        _myWebView.UIDelegate = self;
        _myWebView.navigationDelegate = self;
        _myWebView.customUserAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 13_3_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.5 Mobile/15E148 Safari/604.1";
        [_myWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
        [self.view addSubview:_myWebView];
    }
    return _myWebView;
}

- (UIProgressView *)myProgressView{
    if (!_myProgressView) {
        _myProgressView = [[UIProgressView alloc] init];
        _myProgressView.tintColor = [UIColor blueColor];
        _myProgressView.trackTintColor = [UIColor whiteColor];
        [self.view addSubview:self.myProgressView];
    }
    return _myProgressView;
}

@end
