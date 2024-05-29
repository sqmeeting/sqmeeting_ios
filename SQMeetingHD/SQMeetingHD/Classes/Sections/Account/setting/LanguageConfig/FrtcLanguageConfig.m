static NSString *const FUserLanguageKey = @"FUserLanguageKey";

#import "FrtcLanguageConfig.h"

@implementation FrtcLanguageConfig

+ (void)setUserLanguage:(NSString *)userLanguage {
    [[NSUserDefaults standardUserDefaults] setValue:userLanguage forKey:FUserLanguageKey];
    [[NSUserDefaults standardUserDefaults] setValue:@[userLanguage] forKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)userLanguage {
    return [[NSUserDefaults standardUserDefaults] valueForKey:FUserLanguageKey];
}

@end
