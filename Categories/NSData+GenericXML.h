#import <Foundation/Foundation.h>

@interface NSData (GenericXML)

- (NSData *)md5Digest;

- (NSData *)sha1Digest;

- (NSString *)hexStringValue;

- (NSString *)base64Encoded;
- (NSData *)base64Decoded;

@end
