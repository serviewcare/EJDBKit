#import <Foundation/Foundation.h>
#import "EJDBModel.h"


@interface TestRelatedObject : EJDBModel
@property (copy,nonatomic) NSString *name;
@end

@interface TestSupportedObject : EJDBModel
@property (copy,nonatomic) NSString *aString;
@property (strong,nonatomic) NSNumber *aNumber;
@property (strong,nonatomic) NSDictionary *aDict;
@property (strong,nonatomic) NSArray *anArray;
@property (strong,nonatomic) NSDate *aDate;
@property (strong,nonatomic) NSData *someData;
@property (strong,nonatomic) TestRelatedObject *relatedObj;
@property (strong,nonatomic) NSArray *relatedObjects;
@property (nonatomic) int anInteger;
@property (nonatomic) bool aBool;
@property (nonatomic) float aFloat;
@property (nonatomic) double aDouble;
@property (nonatomic) long long aLongLong;
@end



@interface EJDBModelFixtures : NSObject
+ (TestRelatedObject *)relatedObject;
+ (TestSupportedObject *)supportedObject;
@end