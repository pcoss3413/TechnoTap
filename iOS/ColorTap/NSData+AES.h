
#import <Foundation/Foundation.h>

@interface NSData (AES)

- (NSData *)AES128EncryptedDataWithKey:(NSData *)key;
- (NSData *)AES128DecryptedDataWithKey:(NSData *)key;
- (NSData *)AES128EncryptedDataWithKey:(NSData *)key iv:(NSData *)iv;
- (NSData *)AES128DecryptedDataWithKey:(NSData *)key iv:(NSData *)iv;

@end