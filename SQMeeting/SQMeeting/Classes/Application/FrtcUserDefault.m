#import "FrtcUserDefault.h"

static FrtcUserDefault *sharedUserDefault = nil;

@implementation FrtcUserDefault

+ (FrtcUserDefault *)sharedUserDefault {
    if (sharedUserDefault == nil) {
        @synchronized(self) {
            if (sharedUserDefault == nil) {
                sharedUserDefault = [[FrtcUserDefault alloc] init];
            }
        }
    }
    
    return sharedUserDefault;
}

- (void)setObject:(NSString *)object forKey:(NSString *)objectKey {
    NSUserDefaults *userDefault =[NSUserDefaults standardUserDefaults];
    [userDefault setObject:object forKey:objectKey];
    [userDefault synchronize];
}

- (NSString *)objectForKey:(NSString *)defaultKey {
    NSUserDefaults *userDefault =[NSUserDefaults standardUserDefaults];
    NSString *value = [userDefault objectForKey:defaultKey];
    
    if(value == nil) {
        value = @"";
    }
    
    return value;
}

- (void)setBool:(BOOL)object forKey:(nonnull NSString *)defaultName {
    [[NSUserDefaults standardUserDefaults] setBool:object forKey:defaultName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)boolForKey:(nonnull NSString *)defaultName {
    return [[NSUserDefaults standardUserDefaults] boolForKey:defaultName];
}

@end
