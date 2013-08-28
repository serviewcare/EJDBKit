#import <Foundation/Foundation.h>

@class EJDBFIQueryBuilder;

typedef EJDBFIQueryBuilder*(^EmptyBlock)();
typedef EJDBFIQueryBuilder*(^PathBlock)(NSString *fieldPath);
typedef EJDBFIQueryBuilder*(^NumberBlock)(NSNumber *number);
typedef EJDBFIQueryBuilder*(^ArrayBlock)(NSArray *array);
typedef EJDBFIQueryBuilder*(^DictionaryBlock)(NSDictionary *dictionary);
typedef EJDBFIQueryBuilder*(^PathValueBlock)(NSString *fieldPath, id obj);
typedef EJDBFIQueryBuilder*(^PathNumberBlock)(NSString *fieldPath, NSNumber *number);
typedef EJDBFIQueryBuilder*(^StringsBlock)(NSString *fieldPath, NSString *string);
typedef EJDBFIQueryBuilder*(^AndOrJoinBlock)(NSArray *subqueries);

@interface EJDBFIQueryBuilder : NSObject

@property (strong,nonatomic,readonly) NSDictionary *query;
@property (strong,nonatomic,readonly) NSDictionary *hints;

+ (EJDBFIQueryBuilder *)build;
- (PathValueBlock)match;
- (PathValueBlock)notMatch;
- (StringsBlock)matchIgnoreCase;
- (StringsBlock)beginsWith;
- (StringsBlock)notBeginsWith;
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
- (PathBlock)projection;
- (DictionaryBlock)set;
- (DictionaryBlock)upsert;
- (DictionaryBlock)increment;
- (EmptyBlock)dropAll;
- (DictionaryBlock)addToSet;
- (DictionaryBlock)addToSetAll;
- (DictionaryBlock)pull;
- (DictionaryBlock)pullAll;
- (NumberBlock)maxRecords;
- (NumberBlock)skipRecords;
- (ArrayBlock)onlyFields;
- (ArrayBlock)orderBy;
@end
