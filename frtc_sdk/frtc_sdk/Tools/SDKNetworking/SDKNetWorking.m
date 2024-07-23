#import "SDKNetWorking.h"
#import "AFNetworking.h"
#import "FrtcUUID.h"
#import "SDKUserDefault.h"
#import "FrtcUIMacro.h"

static SDKNetWorking *sharedSDKNetWorkingDefault = nil;

@interface SDKNetWorking()

@property (nonatomic, strong) AFHTTPSessionManager *httpSessionManager;

@end

@implementation SDKNetWorking

+ (SDKNetWorking *)sharedSDKNetWorking {
    if (sharedSDKNetWorkingDefault == nil) {
        @synchronized(self) {
            if (sharedSDKNetWorkingDefault == nil) {
                sharedSDKNetWorkingDefault = [[SDKNetWorking alloc] init];
            }
        }
    }
    
    return sharedSDKNetWorkingDefault;
}

- (instancetype)init {
    if(self = [super init]) {
        [self setAFNetWorking];
    }
    
    return self;
}

- (void)sdkNetWorkingPOST:(NSString *)uri
                userToken:(NSString *)userToken
               parameters:(nullable NSDictionary *)parameters
 requestCompletionHandler:(RequestCompletionHandler)completionHandler
       requestPOSTFailure:(RequestFailure)failuer {
    NSString *urlString = [self generateRestfulUrlWithUri:uri userToken:userToken];
    
    [_httpSessionManager POST:urlString parameters:parameters headers:[self HEADER] progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //[[SDKUserDefault sharedSDKUserDefault] setSDKBoolObject:YES forKey:SKD_LOGIN_VALUE];
        completionHandler((NSDictionary *)responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //[[SDKUserDefault sharedSDKUserDefault] setSDKBoolObject:NO forKey:SKD_LOGIN_VALUE];
        failuer(error);
        NSLog(@"%@", error.localizedDescription);
        NSLog(@"%@", error.localizedFailureReason);
    }];
}

- (void)sdkNetWorkingCustomServerPOST:(NSString *)uri
                            userToken:(NSString *)userToken
                        serverAddress:(NSString *)serverAddress
                           parameters:(nullable NSDictionary *)parameters
             requestCompletionHandler:(RequestCompletionHandler)completionHandler
                   requestPOSTFailure:(RequestFailure)failuer {
    
    NSString *urlString = [self generateRestfulUrlWithUri:uri userToken:userToken serverAddress:serverAddress];
    
    [_httpSessionManager POST:urlString parameters:parameters headers:[self HEADER] progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completionHandler((NSDictionary *)responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failuer(error);
        NSLog(@"%@", error.localizedDescription);
        NSLog(@"%@", error.localizedFailureReason);
    }];
}

- (void)sdkNetWorkingGET:(NSString *)uri
               userToken:(NSString *)userToken
              parameters:(nullable NSDictionary *)parameters
requestCompletionHandler:(RequestCompletionHandler)completionHandler
      requestPOSTFailure:(RequestFailure)failuer {
    NSString *urlString = [self generateRestfulUrlWithUri:uri userToken:userToken];
    
    [_httpSessionManager GET:urlString parameters:parameters headers:[self HEADER] progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"get in progress");
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completionHandler((NSDictionary *)responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failuer(error);
    }];
}

- (void)sdkNetWorkingGET:(NSString *)uri
              parameters:(nullable NSDictionary *)parameters
requestCompletionHandler:(RequestCompletionHandler)completionHandler
      requestPOSTFailure:(RequestFailure)failuer {
    [_httpSessionManager GET:uri parameters:parameters headers:[self HEADER] progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"get in progress");
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completionHandler((NSDictionary *)responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failuer(error);
    }];
}

- (void)sdkNetWorkingPUT:(NSString *)uri
               userToken:(NSString *)userToken
              parameters:(nullable NSDictionary *)parameters
requestCompletionHandler:(RequestCompletionHandler)completionHandler
      requestPOSTFailure:(RequestFailure)failuer {
    NSString *urlString = [self generateRestfulUrlWithUri:uri userToken:userToken];
    
    [_httpSessionManager PUT:urlString parameters:parameters headers:[self HEADER] success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completionHandler((NSDictionary *)responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failuer(error);
    }];
}

- (void)sdkNetWorkingDELETE:(NSString *)uri
                  userToken:(NSString *)userToken
                 parameters:(nullable NSDictionary *)parameters
   requestCompletionHandler:(RequestCompletionHandler)completionHandler
       requestDELETEFailure:(RequestFailure)failuer {
    NSString *urlString = [self generateRestfulUrlWithUri:uri userToken:userToken];
    
    if (parameters && parameters.allKeys.count > 0) {
        if ([parameters.allKeys containsObject:@"deleteGroup"]) {
            BOOL deleteGroup = [[parameters objectForKey:@"deleteGroup"] boolValue];
            if (deleteGroup) {
                urlString = [NSString stringWithFormat:@"%@&deleteGroup=%@",urlString,[NSNumber numberWithBool:YES]];
            }
        }
    }

    [_httpSessionManager DELETE:urlString parameters:parameters headers:[self HEADER] success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completionHandler((NSDictionary *)responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failuer(error);
    }];
}

#pragma mark --internal function--
- (NSString *)generateRestfulUrlWithUri:(NSString *)uri
                              userToken:(NSString *)userToken
                          serverAddress:(NSString *)serverAddress {
    serverAddress = [self removeSpaceAndNewLine:serverAddress];
    NSString *uuid = [[FrtcUUID sharedUUID] getAplicationUUID];
    NSString *restfulUrl;
    if([uri isEqualToString:@"/api/v1/user/sign_in"]) {
        restfulUrl = [NSString stringWithFormat:@"https://%@%@?client_id=%@", serverAddress, uri, uuid];
    } else if([uri isEqualToString:@"/api/v1/meeting_schedule"] || [uri isEqualToString:@"/api/v1/user/public/users"]) {
        restfulUrl = [NSString stringWithFormat:@"https://%@%@?client_id=%@&token=%@&page_num=1&page_size=50", serverAddress, uri, uuid, userToken];
    } else {
        if (kStringIsEmpty(userToken)) {
            restfulUrl = [NSString stringWithFormat:@"https://%@%@?client_id=%@",serverAddress, uri, uuid];
        }else{
            restfulUrl = [NSString stringWithFormat:@"https://%@%@?client_id=%@&token=%@",serverAddress, uri, uuid, userToken];
        }
    }
    //NSLog(@"The url is %@", restfulUrl);
    
    return restfulUrl;
}

- (NSString *)generateRestfulUrlWithUri:(NSString *)uri userToken:(NSString *)userToken {
    NSString *serverAddress = [[[SDKUserDefault sharedSDKUserDefault] sdkObjectForKey:SKD_SERVER_ADDRESS] lowercaseString];
    return [self generateRestfulUrlWithUri:uri userToken:userToken serverAddress:serverAddress];
}

- (void)setAFNetWorking {
    _httpSessionManager = [AFHTTPSessionManager manager];
    _httpSessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    _httpSessionManager.requestSerializer=[AFJSONRequestSerializer serializer];
    _httpSessionManager.requestSerializer.timeoutInterval = 10.f;
    _httpSessionManager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", nil];
    
    NSMutableSet *jsonAcceptableContentTypes = [NSMutableSet setWithSet:_httpSessionManager.responseSerializer.acceptableContentTypes];
    [jsonAcceptableContentTypes addObject:@"text/plain"];
    [jsonAcceptableContentTypes addObject:@"text/json"];
    [jsonAcceptableContentTypes addObject:@"application/json"];
    
    _httpSessionManager.responseSerializer.acceptableContentTypes = jsonAcceptableContentTypes;
    
    /*
     need skip certificate verify
     */
    _httpSessionManager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    _httpSessionManager.securityPolicy.allowInvalidCertificates = YES;
    [_httpSessionManager.securityPolicy setValidatesDomainName:NO];
}

#pragma mark --HTTP HEADER--
- (NSDictionary *)HEADER {
    return @{@"User-Agent":@"FrtcMeeting/3.4.1 ios"};
}

- (NSString *)removeSpaceAndNewLine:(NSString *)str {
    NSString *temp = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return temp;
}

@end
