#import <Foundation/Foundation.h>

@class EJDBQueryBuilder;
@class EJDBFIQueryBuilder;

@interface EJDBQueryFixtures : NSObject
+ (NSDictionary *)complexQuery;
+ (EJDBQueryBuilder *)testQueryBuilderObject;
+ (EJDBFIQueryBuilder *)testFIQueryBuilderObject;
+ (NSDictionary *)carsJoin;
+ (NSDictionary *)carsJoinWithCriteria;
@end
