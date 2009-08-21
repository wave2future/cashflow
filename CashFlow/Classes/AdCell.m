// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
//
// AdCell.m
//

// Note:
//   AdMob : size = 320x48
//   TG ad : size = 320x60

#import "AdCell.h"
#import "TGAView.h" // TG ad

@implementation AdMobDelegate

+ (AdMobDelegate*)getInstance
{
    static AdMobDelegate *theInstance = nil;
    if (theInstance == nil) {
        theInstance = [[AdMobDelegate alloc] init];
    }
    return theInstance;
}

- (NSString*)publisherId
{
    return @"a14a8b599ca8e92";
}

#if 1
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

    NSString *plang = [[NSLocale preferredLanguages] objectAtIndex:0];
    //NSLog(@"Prefered Language: %@", plang);

    if ([plang isEqualToString:@"ja"]) {
        // TG ad
        static TGAView *tgad = nil;
        if (tgad == nil) {
            tgad = [TGAView requestWithKey:@"5AeoNWm3LatP" Position:0];
            [tgad retain];
        }
        [self.contentView addSubview:tgad];
        [tgad release];
    } else {
        // AdMob
        AdMobDelegate *amd = [AdMobDelegate getInstance];
        AdMobView *admob = [AdMobView requestAdWithDelegate:amd];
        [self.contentView addSubview:admob];
    }
    
    return self;
}

- (void)dealloc {
    [super dealloc];
}

@end
