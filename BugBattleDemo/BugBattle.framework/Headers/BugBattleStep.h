//
//  BugBattleStep.h
//  AyAyObjectiveCPort
//
//  Created by Lukas Boehler on 13.01.19.
//  Copyright © 2019 BugBattle. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BugBattleStep : NSObject

- (instancetype)initWithType: (NSString *)type andDescription: (NSString *)description andDate: (NSDate *)date andData: (NSDictionary *)data;
- (instancetype)initWithType: (NSString *)type andDescription: (NSString *)description andDate: (NSDate *)date;
- (instancetype)initWithType: (NSString *)type andDescription: (NSString *)description;
-(NSDictionary *)toDictionary;

@end

NS_ASSUME_NONNULL_END
