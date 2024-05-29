#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (AES)

-(NSData*)AES256EncryptWithKey:(NSString*)key;
-(NSData*)AES256DecryptWithKey:(NSString*)key;

@end

NS_ASSUME_NONNULL_END
