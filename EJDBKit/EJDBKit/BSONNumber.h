#import <Foundation/Foundation.h>

@interface BSONNumber : NSObject

@property (nonatomic,readonly) BOOL isInt;
@property (nonatomic,readonly) BOOL isLongLong;
@property (nonatomic,readonly) BOOL isBool;
@property (nonatomic,readonly) BOOL isDouble;
@property (nonatomic,readonly) int intValue;
@property (nonatomic,readonly) long long longlongValue;
@property (nonatomic,readonly) BOOL boolValue;
@property (nonatomic,readonly) double doubleValue;

+ (BSONNumber *)intNumberFromNumber:(NSNumber *)number;

+ (BSONNumber *)longlongNumberFromNumber:(NSNumber *)number;

+ (BSONNumber *)boolNumberFromNumber:(NSNumber *)number;

+ (BSONNumber *)doubleNumberFromNumber:(NSNumber *)number;

@end
