// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
//
//  AdCell.h
//

#if FREE_VERSION

#import <UIKit/UIKit.h>

#import "GADAdViewController.h"
#import "GADAdSenseParameters.h"

@interface AdCell : UITableViewCell <GADAdViewControllerDelegate> {
    GADAdViewController *adViewController;
    UIViewController *parentViewController;
}

@property(nonatomic,assign) UIViewController *parentViewController;

+ (AdCell *)adCell:(UITableView *)tableView parentViewController:(UIViewController *)parentViewController;
+ (CGFloat)adCellHeight;

#endif

@end
