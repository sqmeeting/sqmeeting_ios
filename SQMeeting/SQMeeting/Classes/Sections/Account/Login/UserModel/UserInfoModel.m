#import "UserInfoModel.h"
#import "YYModel.h"

@implementation UserInfoModel

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self yy_modelEncodeWithCoder:aCoder];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    return [self yy_modelInitWithCoder:aDecoder];
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    _meetingOperator =  [_role containsObject:@"MeetingOperator"];
    _systemAdmin =  [_role containsObject:@"SystemAdmin"];
    if (kStringIsEmpty(_real_name)) {
        _real_name = @"";
    }
    _levelHigh = [_security_level isEqualToString:@"HIGH"];
    return YES;
}

@end
