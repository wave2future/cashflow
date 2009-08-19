// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
//
// AdCell.m
//

#import "AdCell.h"

@implementation AdCell

+ (AdCell *)adCell:(UITableView *)tableView
{
    NSString *identifier = @"AdCell";

    AdCell *cell = (AdCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[AdCell alloc] initWithFrame:CGRectZero reuseIdentifier:identifier] autorelease];
    }
    return cell;
}

- (UITableViewCell *)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)identifier
{
    self = [super initWithFrame:frame reuseIdentifier:identifier];

    [self.contentView addSubview:[AdMobView requestAdWithDelegate:self]];
    return self;
}

- (void)dealloc {
    [super dealloc];
}

// AdMob
- (NSString*)publisherId
{
    return @"a14a8b599ca8e92";
}

- (BOOL)useTestAd {
    return NO;
}

@end
