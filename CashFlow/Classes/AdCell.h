// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
//
//  AdCell.h
//

#if FREE_VERSION

#import <UIKit/UIKit.h>

#import "GADAdViewController.h"
#import "GADAdSenseParameters.h"

#define AFMA_CLIENT_ID  @"ca-mb-app-pub-4621925249922081"
#define AFMA_CHANNEL_IDS @"9215174282"
#define AFMA_KEYWORDS  @"マネー,ファイナンス,銀行,預金,キャッシュ,クレジット,節約,資産,money,finance,bank,cash,credit,saving,asset"
#define AFMA_IS_TEST 1

@interface AdCell : UITableViewCell <GADAdViewControllerDelegate> {
    GADAdViewController *adViewController;
    UIViewController *parentViewController;
}

@property(nonatomic,assign) UIViewController *parentViewController;

+ (AdCell *)adCell:(UITableView *)tableView parentViewController:(UIViewController *)parentViewController;
+ (CGFloat)adCellHeight;

+ (NSDictionary *)adAttributes;
#endif

@end
