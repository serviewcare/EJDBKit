#import <Foundation/Foundation.h>

@interface EJDBQueryBuilder : NSObject

- (NSDictionary *)query;
- (NSDictionary *)hints;
- (void)path:(NSString *)path matches:(id)value;
- (void)path:(NSString *)path notMatches:(id)value;
- (void)path:(NSString *)path matchesIgnoreCase:(NSString *)value;
- (void)path:(NSString *)path beginsWith:(NSString *)value;
- (void)path:(NSString *)path notBeginsWith:(NSString *)value;
- (void)path:(NSString *)path greaterThan:(NSNumber *)number;
- (void)path:(NSString *)path greaterThanOrEqualTo:(NSNumber *)number;
- (void)path:(NSString *)path lessThan:(NSNumber *)number;
- (void)path:(NSString *)path lessThanOrEqualTo:(NSNumber *)number;
- (void)path:(NSString *)path between:(NSArray *)values;
- (void)path:(NSString *)path in:(NSArray *)inValues;
- (void)path:(NSString *)path inIgnoreCase:(NSArray *)inValues;
- (void)path:(NSString *)path notIn:(NSArray *)inValues;
- (void)path:(NSString *)path notInIgnoreCase:(NSArray *)inValues;
- (void)path:(NSString *)path exists:(BOOL)exists;
- (void)path:(NSString *)path stringAllIn:(id)values;
- (void)path:(NSString *)path stringAnyIn:(id)values;
- (void)path:(NSString *)path elementsMatch:(EJDBQueryBuilder *)builder;
- (void)path:(NSString *)path joinCollectionNamed:(NSString *)collectionName;
- (void)andJoin:(NSArray *)subqueries;
- (void)orJoin:(NSArray *)subqueries;
- (void)projectionForPath:(NSString *)path;
- (void)set:(NSDictionary *)keysAndValues;
- (void)upsert:(NSDictionary *)keysAndValues;
- (void)increment:(NSDictionary *)keysAndValues;
- (void)dropAll;
- (void)addToSet:(NSDictionary *)keysAndValues;
- (void)addToSetAll:(NSDictionary *)keysAndValues;
- (void)pull:(NSDictionary *)keysAndValues;
- (void)pullAll:(NSDictionary *)keysAndValues;
- (void)maxRecords:(NSNumber *)number;
- (void)skipRecords:(NSNumber *)number;
- (void)onlyFields:(NSArray *)fields;
- (void)orderBy:(NSArray *)fields;

@end
