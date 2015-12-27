#import "NSData+AES.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation NSData (AES)

- (NSData *)AES128EncryptedDataWithKey:(NSData *)key{
    return [self AES128EncryptedDataWithKey:key iv:nil];
}

- (NSData *)AES128DecryptedDataWithKey:(NSData *)key{
    return [self AES128DecryptedDataWithKey:key iv:nil];
}

- (NSData *)AES128EncryptedDataWithKey:(NSData *)key iv:(NSData *)iv{
    return [self AES128Operation:kCCEncrypt key:key iv:iv];
}

- (NSData *)AES128DecryptedDataWithKey:(NSData *)key iv:(NSData *)iv{
    return [self AES128Operation:kCCDecrypt key:key iv:iv];
}


- (NSData *)AES128Operation:(CCOperation)operation key:(NSData *)key iv:(NSData *)iv{
	
    char ivPtr[kCCKeySizeAES256 + 1];
    bzero(ivPtr, sizeof(ivPtr));
    if (iv) {
        [iv getBytes:&ivPtr length:sizeof(char)*[iv length]];
    }
    
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCKeySizeAES256;
    void *buffer = malloc(bufferSize);
	
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(operation,
                                          kCCAlgorithmAES,
                                          kCCOptionPKCS7Padding,
                                          (const char*) [key bytes],
                                          [key length],
                                          (const void*)[iv bytes],
                                          [self bytes],
                                          [self length] ,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    
    if (cryptStatus == kCCSuccess) {
        NSData *dataToReturn = [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
        return dataToReturn;
    }
    else{
        NSLog(@"Encrytion not successful. status; %d", cryptStatus);
    }
    
    free(buffer);
    return nil;
}

@end