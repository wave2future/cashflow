// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */
// AdCell.h

#if FREE_VERSION

#import <UIKit/UIKit.h>

#import "GADAdViewController.h"
#import "GADAdSenseParameters.h"

#define AFMA_CLIENT_ID  @"ca-mb-app-pub-4621925249922081"
#define AFMA_APPID @"294304828" // CashFlow Free

#define AFMA_CHANNEL_IDS @"7922983440"
#define AFMA_CHANNEL_IDS_IPAD @"5863989042"
#define AFMA_KEYWORDS  @"マネー,預金,キャッシュ,クレジット,小遣い,貯金,資産+管理,money,deposit,cash,credit,allowance,spending+money,pocket+money,savings,saving+money,asset+management"
#define AFMA_IS_TEST 0

@interface AdUtil : NSObject {
}

+ (NSDictionary *)adAttributes;

#endif

@end
