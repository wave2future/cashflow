// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
//
//  AdCell.h
//

#if FREE_VERSION

#import <UIKit/UIKit.h>

#import "GADAdViewController.h"
#import "GADAdSenseParameters.h"

#define AFMA_CLIENT_ID  @"ca-mb-app-pub-4621925249922081"
#define AFMA_CHANNEL_IDS @"7922983440"
#define AFMA_CHANNEL_IDS_IPAD @"5863989042"
#define AFMA_KEYWORDS  @"マネー,預金,キャッシュ,クレジット,小遣い,貯金,資産+管理,money,deposit,cash,credit,allowance,spending+money,pocket+money,savings,saving+money,asset+management"
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
