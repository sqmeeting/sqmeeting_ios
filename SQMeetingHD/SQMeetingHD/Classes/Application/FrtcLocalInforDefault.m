#import "FrtcLocalInforDefault.h"
#import "FrtcUserDefault.h"
#import "RSA.h"

NSString * const pubkey = @"-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDDI2bvVLVYrb4B0raZgFP60VXY\ncvRmk9q56QiTmEm9HXlSPq1zyhyPQHGti5FokYJMzNcKm0bwL1q6ioJuD4EFI56D\na+70XdRz1CjQPQE3yXrXXVvOsmq9LsdxTFWsVBTehdCmrapKZVVx6PKl7myh0cfX\nQmyveT/eqyZK1gYjvQIDAQAB\n-----END PUBLIC KEY-----";


NSString * const privkey = @"-----BEGIN PRIVATE KEY-----\nMIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAMMjZu9UtVitvgHS\ntpmAU/rRVdhy9GaT2rnpCJOYSb0deVI+rXPKHI9Aca2LkWiRgkzM1wqbRvAvWrqK\ngm4PgQUjnoNr7vRd1HPUKNA9ATfJetddW86yar0ux3FMVaxUFN6F0KatqkplVXHo\n8qXubKHRx9dCbK95P96rJkrWBiO9AgMBAAECgYBO1UKEdYg9pxMX0XSLVtiWf3Na\n2jX6Ksk2Sfp5BhDkIcAdhcy09nXLOZGzNqsrv30QYcCOPGTQK5FPwx0mMYVBRAdo\nOLYp7NzxW/File//169O3ZFpkZ7MF0I2oQcNGTpMCUpaY6xMmxqN22INgi8SHp3w\nVU+2bRMLDXEc/MOmAQJBAP+Sv6JdkrY+7WGuQN5O5PjsB15lOGcr4vcfz4vAQ/uy\nEGYZh6IO2Eu0lW6sw2x6uRg0c6hMiFEJcO89qlH/B10CQQDDdtGrzXWVG457vA27\nkpduDpM6BQWTX6wYV9zRlcYYMFHwAQkE0BTvIYde2il6DKGyzokgI6zQyhgtRJ1x\nL6fhAkB9NvvW4/uWeLw7CHHVuVersZBmqjb5LWJU62v3L2rfbT1lmIqAVr+YT9CK\n2fAhPPtkpYYo5d4/vd1sCY1iAQ4tAkEAm2yPrJzjMn2G/ry57rzRzKGqUChOFrGs\nlm7HF6CQtAs4HC+2jC0peDyg97th37rLmPLB9txnPl50ewpkZuwOAQJBAM/eJnFw\nF5QAcL4CYDbfBKocx82VX/pFXng50T7FODiWbbL4UnxICE0UBFInNNiWJxNEb6jL\n5xd0pcy9O2DOeso=\n-----END PRIVATE KEY-----";

@implementation FrtcLocalInforDefault

+ (void)saveMeetingName:(NSString *)name {
    [[FrtcUserDefault sharedUserDefault] setObject:name forKey:DISPLAY_NAME];
}

+ (NSString *)getMeetingDisPlayName{
    return [[FrtcUserDefault sharedUserDefault] objectForKey:DISPLAY_NAME];
}

+ (void)saveLastMeetingNumber:(NSString *)number {
    [[FrtcUserDefault sharedUserDefault] setObject:number forKey:CONFERENCE_NUMBER];
}

+ (NSString *)getLastMeetingNumber {
    return [[FrtcUserDefault sharedUserDefault] objectForKey:CONFERENCE_NUMBER];
}

+ (void)saveLoginName:(NSString *)name {
    [[FrtcUserDefault sharedUserDefault] setObject:name forKey:LOGIN_NAME];
}

+ (NSString *)getLoginName {
    return [[FrtcUserDefault sharedUserDefault] objectForKey:LOGIN_NAME];
}

+ (void)saveLoginPassword:(NSString *)password {
    NSString *encryptPsd = [RSA encryptString:password publicKey:pubkey];
    [[FrtcUserDefault sharedUserDefault] setObject:encryptPsd forKey:LOGIN_PASSWORD];
}

+ (NSString *)getLoginPassword {
    NSString *decryptPsd = [[FrtcUserDefault sharedUserDefault] objectForKey:LOGIN_PASSWORD];
    NSString *password = [RSA decryptString:decryptPsd privateKey:privkey];
    return password;
}

+ (void)savePasswordState:(BOOL)psdState {
    [[FrtcUserDefault sharedUserDefault] setBool:psdState forKey:@"PSDSTATE"];
}

+ (BOOL)getPasswordState {
    return [[FrtcUserDefault sharedUserDefault] boolForKey:@"PSDSTATE"];
}

+ (void)saveNoiseSwitch:(BOOL)noise {
    [[FrtcUserDefault sharedUserDefault] setBool:!noise forKey:@"NOISESWITCH"];
}

+ (BOOL)getNoiseSwitch {
    return ![[FrtcUserDefault sharedUserDefault] boolForKey:@"NOISESWITCH"];
}

+ (void)saveYourSelf:(BOOL)your {
    [[FrtcUserDefault sharedUserDefault] setBool:your forKey:@"YOURSELF"];

}

+ (BOOL)getYourSelf {
    return [[FrtcUserDefault sharedUserDefault] boolForKey:@"YOURSELF"];
}


@end
