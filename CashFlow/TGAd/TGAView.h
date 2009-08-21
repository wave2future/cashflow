//
//  TGAView.h
//  TGAd for iPhone
//
//  Copyright 2009 株式会社トラフィックゲート. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TGAView : UIView {
	NSString *linkUrl;
}

+ (id)requestWithKey:(NSString*)key Position:(CGFloat)y;
+ (id)requestWithKey:(NSString*)key Position:(CGFloat)y OpenType:(unsigned int)type;
- (id)initWithKey:(NSString*)key Position:(CGFloat)y;
- (id)initWithKey:(NSString*)key Position:(CGFloat)y OpenType:(unsigned int)type;

@end
