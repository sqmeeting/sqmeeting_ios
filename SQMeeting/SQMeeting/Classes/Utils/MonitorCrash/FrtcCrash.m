#import "FrtcCrash.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>

NSString * applicationDocumentsDirectory() {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES)lastObject];
}

static void SignalHandler(int signal, siginfo_t* info, void* context) {
    NSMutableString *mstr = [[NSMutableString alloc] init];
    [mstr appendString:@"Signal Exception:\n"];
    [mstr appendString:[NSString stringWithFormat:@"Signal was raised.\n"]];
    [mstr appendString:@"Call Stack:\n"];
    
    for (NSUInteger index = 1; index < NSThread.callStackSymbols.count; index++) {
        NSString *str = [NSThread.callStackSymbols objectAtIndex:index];
        [mstr appendString:[str stringByAppendingString:@"\n"]];
    }
    
    [mstr appendString:@"threadInfo:\n"];
    [mstr appendString:[[NSThread currentThread] description]];
    
    NSString * path = [applicationDocumentsDirectory()stringByAppendingPathComponent:@"Crash.txt"];
    [mstr writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}


static void SignalRegister(int signal) {
    struct sigaction action;
    action.sa_sigaction = SignalHandler;
    action.sa_flags = SA_NODEFER | SA_SIGINFO;
    sigemptyset(&action.sa_mask);
    sigaction(signal, &action, 0);
}

static void UncaughtExceptionHandler(NSException * exception) {
    NSArray * stackArray = [exception callStackSymbols];
    NSString * reason = [exception reason];
    NSString * name = [exception name];
    
    NSString * exceptionInfo = [NSString stringWithFormat:@"========uncaughtException异常错误报告========\nname:%@\nreason:\n%@\ncallStackSymbols:\n%@", name, reason, [stackArray componentsJoinedByString:@"\n"]];
    NSString * path = [applicationDocumentsDirectory()stringByAppendingPathComponent:@"Crash1.txt"];
    [exceptionInfo writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

@implementation FrtcCrash

+ (void)signalRegister {
    SignalRegister(SIGABRT);
    SignalRegister(SIGBUS);
    SignalRegister(SIGFPE);
    SignalRegister(SIGILL);
    SignalRegister(SIGPIPE);
    SignalRegister(SIGSEGV);
    SignalRegister(SIGSYS);
    SignalRegister(SIGTRAP);
}

+ (void)registerHandler {
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES)lastObject];
}


@end
