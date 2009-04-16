// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

@interface TestCommon
{
}


+ (void)deleteDatabase;
+ (void)installDatabase:(NSString *)sqlFileName;

@end
