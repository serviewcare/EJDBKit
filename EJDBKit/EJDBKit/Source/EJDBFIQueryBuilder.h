#import <Foundation/Foundation.h>

@class EJDBFIQueryBuilder;

typedef EJDBFIQueryBuilder*(^PathBlock)(NSString *fieldPath);
typedef EJDBFIQueryBuilder*(^NumberBlock)(NSNumber *number);
typedef EJDBFIQueryBuilder*(^ArrayBlock)(NSArray *array);
typedef EJDBFIQueryBuilder*(^PathValueBlock)(NSString *fieldPath, id obj);
typedef EJDBFIQueryBuilder*(^PathNumberBlock)(NSString *fieldPath, NSNumber *number);
typedef EJDBFIQueryBuilder*(^SubstringBlock)(NSString *fieldPath, NSString *substring);
typedef EJDBFIQueryBuilder*(^AndOrJoinBlock)(NSArray *subqueries);

@interface EJDBFIQueryBuilder : NSObject

@property (strong,nonatomic,readonly) NSDictionary *query;
@property (strong,nonatomic,readonly) NSDictionary *hints;

+ (EJDBFIQueryBuilder *)build;
- (PathValueBlock)match;
- (PathValueBlock)notMatch;
- (SubstringBlock)matchIgnoreCase;
- (SubstringBlock)beginsWith;
- (SubstringBlock)notBeginsWith;
- (PathNumberBlock)greaterThan;
- (PathNumberBlock)greaterThanOrEqualTo;
- (PathNumberBlock)lessThan;
- (PathNumberBlock)lessThanOrEqualTo;
- (PathValueBlock)between;
- (PathValueBlock)in;
- (PathValueBlock)inIgnoreCase;
- (PathValueBlock)notIn;
- (PathValueBlock)notInIgnoreCase;
- (PathBlock)exists;
- (PathBlock)notExists;
- (PathValueBlock)stringAllIn;
- (PathValueBlock)stringAnyIn;
- (PathValueBlock)elemsMatch;
- (AndOrJoinBlock)andJoin;
- (AndOrJoinBlock)orJoin;
- (NumberBlock)maxRecords;
- (NumberBlock)skipRecords;
- (ArrayBlock)onlyFields;
- (ArrayBlock)orderBy;
@end
