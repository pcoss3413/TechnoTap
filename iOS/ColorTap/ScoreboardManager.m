//
//  ScoreboardManager.m
//  ColorTap
//
//  Created by Patrick Cossette on 4/30/15.
//  Copyright (c) 2015 Patrick Cossette. All rights reserved.
//

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#import <CommonCrypto/CommonCrypto.h>
#import <CommonCrypto/CommonRandom.h>
#import "ScoreboardManager.h"
#import "NSData+AES.h"

@implementation ScoreboardManager

NSData* sha256(NSData *data){
    unsigned char hash[CC_SHA256_DIGEST_LENGTH];
    if (CC_SHA256([data bytes], (CC_LONG)[data length], hash) ) {
        NSData *sha256 = [NSData dataWithBytes:hash length:CC_SHA256_DIGEST_LENGTH];
        return sha256;
    }
    return nil;
}

+(id)sharedManager {
    static ScoreboardManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
        sharedManager.manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://www.digitaldiscrepancy.com/"]];
        [sharedManager.manager.requestSerializer setValue:@"Content-Type" forHTTPHeaderField:@"application/json"];
        [sharedManager.manager.requestSerializer setTimeoutInterval:15.f]; //Timeout after 15 seconds if no response
    });
    
    return sharedManager;
}

+(NSUInteger)alltimeBest{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"allTimeBest"] unsignedIntegerValue];
}

+(void)setAlltimeBest:(NSUInteger)score{
    [[NSUserDefaults standardUserDefaults] setObject:@(score) forKey:@"allTimeBest"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(id)init{
    if ((self = [super init])) {
 
    }
    
    return self;
}

+(NSString*)getISOCountryCode{
    //Try to get the country code using CoreTelephony, which wont' work on non-networked devices like WiFi-Only iPads and iPod Touches
    CTTelephonyNetworkInfo *network_Info = [CTTelephonyNetworkInfo new];
    CTCarrier *carrier = network_Info.subscriberCellularProvider;
    if (carrier.isoCountryCode)
        return carrier.isoCountryCode;
    
    return [[[[NSLocale currentLocale] localeIdentifier] substringFromIndex:[[[NSLocale currentLocale] localeIdentifier] length] - 2] lowercaseString];
}

-(void)submitScore:(NSUInteger)score forUser:(NSString*)user completion:(void (^)(NSDictionary *response, NSError *error))completion{
    //Encrypt our score using a sha256 hash of our secret key, so that nobody can spoof the network call and submit a false score

    uint8_t iv[16];
    
    NSString *ISOCountryCode = [ScoreboardManager getISOCountryCode];
    NSString *scoreData = [NSString stringWithFormat:@"%@|%@|%lu|", user, ISOCountryCode, (unsigned long)score];
    

    NSData *ivData = [scoreData dataUsingEncoding:NSASCIIStringEncoding];

    
    int i = 0;
    do{
        CCRandomGenerateBytes(&iv, sizeof(uint8_t)*16);
        NSMutableData *ivD = [NSMutableData dataWithBytes:&iv length:sizeof(iv)];
        NSData *encryptedData = [ivData AES128EncryptedDataWithKey:sha256([API_KEY dataUsingEncoding:NSASCIIStringEncoding]) iv:ivD];
        ivData = [[NSString stringWithFormat:@"%@:%@", [ivD base64EncodedStringWithOptions:0], [encryptedData base64EncodedStringWithOptions:0]] dataUsingEncoding:NSASCIIStringEncoding];
        i++;
    } while (i < 7);


    NSDictionary *params = @{@"data":[[NSString alloc] initWithData:ivData encoding:NSASCIIStringEncoding]};
    
    
    [[[ScoreboardManager sharedManager] manager] POST:@"/TechnoTap/Scoreboard.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
            if ([responseObject[@"success"] boolValue]) {
                completion ? completion(responseObject, nil) : nil;
            }
            else{
                UIAlertView *alt = [[UIAlertView alloc] initWithTitle:@"Error" message:responseObject[@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alt show];
                completion ? completion(nil, [[NSError alloc] initWithDomain:@"com.digitaldiscrepancy.technotap" code:0xDEADC0DE userInfo:responseObject]) : nil;
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        
        if (error) {
            NSLog(@"Error: %@", error);
            //if ([error.userInfo objectForKey:@"com.alamofire.serialization.response.error.data"]){
            //    NSLog(@"ERROR: %@", [[NSString alloc] initWithData:[error.userInfo objectForKey:@"com.alamofire.serialization.response.error.data"] encoding:NSASCIIStringEncoding]);
            //}
        }
        
        completion ? completion(nil, error) : nil;
    }];
}

-(void)getScoresInTimePeriod:(TimePeriod)period completion:(void (^)(NSArray *scores, NSError *error))completion{
    
    NSString *action = [@[@"getTop100", @"getMostRecent"] objectAtIndex:period];
    
    [[[ScoreboardManager sharedManager] manager] POST:@"/TechnoTap/Scoreboard.php" parameters:@{@"action":action} success:^(AFHTTPRequestOperation *operation, id responseObject){
        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
            if ([responseObject[@"success"] boolValue]) {
                completion ? completion(responseObject[@"scores"], nil) : nil;
            }
            else{
                UIAlertView *alt = [[UIAlertView alloc] initWithTitle:@"Error" message:responseObject[@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alt show];
                completion ? completion(nil, [[NSError alloc] initWithDomain:@"com.digitaldiscrepancy.technotap" code:0xDEADC0DE userInfo:responseObject]) : nil;
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        
        if (error) {
            NSLog(@"Error: %@", error);
            //if ([error.userInfo objectForKey:@"com.alamofire.serialization.response.error.data"]){
            //    NSLog(@"ERROR: %@", [[NSString alloc] initWithData:[error.userInfo objectForKey:@"com.alamofire.serialization.response.error.data"] encoding:NSASCIIStringEncoding]);
            //}
        }
        
        completion ? completion(nil, error) : nil;
    }];
}

@end
