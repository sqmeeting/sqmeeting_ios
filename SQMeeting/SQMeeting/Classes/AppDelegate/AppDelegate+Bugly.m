#import "AppDelegate+Bugly.h"
#import <Bugly/Bugly.h>

@interface AppDelegate (Bugly) <BuglyDelegate>
@end

@implementation AppDelegate (Bugly) 

- (void)configBugly {
    
    BuglyConfig *config = [[BuglyConfig alloc] init];
    config.delegate = self;
    config.blockMonitorEnable = YES;
    config.reportLogLevel = BuglyLogLevelInfo;
    [Bugly startWithAppId:@"4405606926"
#if DEBUG
        developmentDevice:YES
#endif
                   config:config];
}

#pragma mark - BuglyDelegate

- (NSString * BLY_NULLABLE)attachmentForException:(NSException * BLY_NULLABLE)exception {
#ifdef DEBUG
    return [NSString stringWithFormat:@"frtc_error_msg:%@",[self redirectNSLogToDocumentFolder]];;
#endif
    return nil;
}

#pragma mark - 保存日志文件
- (NSString *)redirectNSLogToDocumentFolder{
    if(isatty(STDOUT_FILENO)) {
        return nil;
    }
    UIDevice *device = [UIDevice currentDevice];
    if([[device model] hasSuffix:@"Simulator"]){
        return nil;
    }

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *logDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Log"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:logDirectory];
    if (!fileExists) {
        [fileManager createDirectoryAtPath:logDirectory  withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    NSString *logFilePath = [logDirectory stringByAppendingFormat:@"/%@.txt",dateStr];
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
    
    return [[NSString alloc] initWithContentsOfFile:logFilePath encoding:NSUTF8StringEncoding error:nil];
    
}

@end
