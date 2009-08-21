// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
//
// AdCell.m
//

#import "AdCell.h"

#import "TGAView.h" // TG ad

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

#if 0
    // AdMob
    AdMobView *admob = [AdMobView requestAdWithDelegate:self];
    [self.contentView addSubview:admob];

#else
    // TG ad
    static TGAView *tgad = nil;
    if (tgad == nil) {
        tgad = [TGAView requestWithKey:@"5AeoNWm3LatP" Position:0];
        [tgad retain];
    }
    [self.contentView addSubview:tgad];
    [tgad release];
#endif
    
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

#if 0
- (BOOL)useTestAd {
    return YES;
}
#endif

- (void)didReceiveAd:(AdMobView *)adView {
    NSLog(@"AdMob:disReceiveAd");
}

- (void)didFailToReceiveAd:(AdMobView *)adView {
    NSLog(@"AdMob:didFailToReceiveAd");
}

@end
