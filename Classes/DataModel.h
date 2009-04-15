// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
  CashFlow for iPhone/iPod touch

  Copyright (c) 2008, Takuya Murakami, All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

  1. Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer. 

  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution. 

  3. Neither the name of the project nor the names of its contributors
  may be used to endorse or promote products derived from this software
  without specific prior written permission. 

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import <UIKit/UIKit.h>
#import "Asset.h"
#import "Category.h"
#import "Database.h"

@interface DataModel : NSObject {
    // Asset
    NSMutableArray *assets;
    Asset *selAsset; // 選択中の Asset

    // Category
    Categories *categories;
}

@property(nonatomic,retain) NSMutableArray *assets;
@property(nonatomic,readonly) Asset *selAsset;
@property(nonatomic,retain) Categories *categories;

// initializer
- (id)init;

// load/save
- (void)load;
- (void)loadAssets; // private

// asset operation
- (void)reloadAssets;
- (void)dirtyAllAssets;
- (int)assetCount;
- (Asset *)assetAtIndex:(int)n;
- (int)assetIndexWithKey:(int)key;
- (Asset*)assetWithKey:(int)key;

- (void)addAsset:(Asset *)as;
- (void)deleteAsset:(Asset *)as;
- (void)updateAsset:(Asset*)asset;
- (void)reorderAsset:(int)from to:(int)to;
- (void)changeSelAsset:(Asset *)as;

// utility operation
+ (NSString*)currencyString:(double)x;

- (NSMutableArray *)descLRUWithCategory:(int)category;
- (void)_setDescLRU:(NSMutableArray *)descAry withCategory:(int)category;
- (int)categoryWithDescription:(NSString *)desc;

@end
