#import "BSONNumber.h"

@interface BSONNumber ()
@end

@implementation BSONNumber

+ (BSONNumber *)intNumberFromNumber:(NSNumber *)number
{
    BSONNumber *intNumber = [[BSONNumber alloc]initWithIntValue:[number intValue]];
    return intNumber;
}

+ (BSONNumber *)longlongNumberFromNumber:(NSNumber *)number
{
    BSONNumber *longlongNumber = [[BSONNumber alloc]initWithLongLongValue:[number longLongValue]];
    return longlongNumber;
}

+ (BSONNumber *)boolNumberFromNumber:(NSNumber *)number
{
    BSONNumber *boolNumber = [[BSONNumber alloc]initWithBoolValue:[number boolValue]];
    return boolNumber;
}

+ (BSONNumber *)doubleNumberFromNumber:(NSNumber *)number
{
    BSONNumber *doubleNumber = [[BSONNumber alloc]initWithDoubleValue:[number doubleValue]];
    return doubleNumber;
}

- (id)initWithIntValue:(int)intValue
{
    self = [super init];
    if (self)
    {
        _intValue = intValue;
        _isInt = YES;
    }
    return self;
}

- (id)initWithLongLongValue:(long long)longlongValue
{
    self = [super init];
    if (self)
    {
        _longlongValue = longlongValue;
        _isLongLong = YES;
    }
    return self;
}

- (id)initWithBoolValue:(BOOL)boolValue
{
    self = [super init];
    if (self)
    {
        _boolValue = boolValue;
        _isBool = YES;
    }
    return self;
}

- (id)initWithDoubleValue:(double)doubleValue
{
    self = [super init];
    if (self)
    {
        _doubleValue = doubleValue;
        _isDouble = YES;
    }
    return self;
}

@end