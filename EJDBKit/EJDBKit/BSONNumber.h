#import <Foundation/Foundation.h>

/**
 This class wraps an NSNumber to allow for accurate encoding/decoding of bson number types. Quite ungodly I admit but
 at this point I don't know of a better solution. For more info on this topic take a look at the NSNumber reference:
 https://developer.apple.com/library/ios/#documentation/Cocoa/Reference/Foundation/Classes/NSNumber_Class/Reference/Reference.html
 under ObjCType method. Here it states that: "The returned type does not necessarily match the method the receiver was created with."
 Anyone have a better solution? I would love to get rid of this class!!!
*/

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
