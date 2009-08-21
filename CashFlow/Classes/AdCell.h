// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
//
//  AdCell.h
//

#import <UIKit/UIKit.h>

#import "AdMobDelegateProtocol.h"
#import "AdMobView.h"

@interface AdMobDelegate : NSObject <AdMobDelegate> {
}
@end

@interface AdCell : UITableViewCell {
}

+ (AdCell *)adCell:(UITableView *)tableView;
@end
