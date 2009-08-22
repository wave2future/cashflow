// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
//
// AdCell.m
//

// Note:
//   AdMob : size = 320x48
//   TG ad : size = 320x60

#import "AdCell.h"

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

- (BOOL)useTestAd {
    return NO;
    //return YES;
}

- (void)didReceiveAd:(AdMobView *)adView {
    NSLog(@"AdMob:didReceiveAd");
}

- (void)didFailToReceiveAd:(AdMobView *)adView {
    NSLog(@"AdMob:didFailToReceiveAd");
}

@end

/////////////////////////////////////////////////////////////////////
// AdCell

@implementation AdCell

+ (BOOL)_isJaAd
{
    return NO;
    
    static NSString *plang = nil;
    static BOOL isJa = YES;

    if (plang == nil) {
        plang = [[NSLocale preferredLanguages] objectAtIndex:0];
        if ([plang isEqualToString:@"ja"]) {
            isJa = YES;
        } else {
            isJa = NO;
        }
    }

    return isJa;
}

+ (CGFloat)adCellHeight
{
    if ([AdCell _isJaAd]) {
        return 60; // TG ad
    }
    return 48; // admob
}

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

    if ([AdCell _isJaAd]) {
        // TG ad
        static TGAView *tgad = nil;
        if (tgad == nil) {
            tgad = [TGAView requestWithKey:@"5AeoNWm3LatP" Position:0];
            [tgad retain];
        }
        [self.contentView addSubview:tgad];
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
