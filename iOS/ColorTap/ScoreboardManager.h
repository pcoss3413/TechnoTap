//
//  ScoreboardManager.h
//  ColorTap
//
//  Created by Patrick Cossette on 4/30/15.
//  Copyright (c) 2015 Patrick Cossette. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

//The API key name is a bit misleading, this key is used to encrypt the scores we upload to prevent tampering with the score databse
//This API key must match the key hardcoded in the server's PHP code, otherwise score uploads will fail
#define API_KEY @"API_KEY"
#define BASE_URL @"https://www.digitaldiscrepancy.com/API/Scoreboard"

typedef enum {
    timePeriodForever,
    timePeriodRecent
} TimePeriod;

@interface ScoreboardManager : NSObject

NSData* sha256(NSData *data);

+(id)sharedManager;
+(NSString*)getISOCountryCode;

+(NSUInteger)alltimeBest;
+(void)setAlltimeBest:(NSUInteger)score;

-(void)submitScore:(NSUInteger)score forUser:(NSString*)user completion:(void (^)(NSDictionary *response, NSError *error))completion;
-(void)getScoresInTimePeriod:(TimePeriod)period completion:(void (^)(NSArray *scores, NSError *error))completion;

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;

@end
