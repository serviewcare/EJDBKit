#import <Foundation/Foundation.h>

@class EJDBFIQueryBuilder;

/** A no argument builder block. */
typedef EJDBFIQueryBuilder*(^EmptyBlock)();

/** A block that takes a field path as its only argument. */
typedef EJDBFIQueryBuilder*(^PathBlock)(NSString *fieldPath);

/** A block that takes a number as its only argument. */
typedef EJDBFIQueryBuilder*(^NumberBlock)(NSNumber *number);

/** A block that takes an array as its only argument. */
typedef EJDBFIQueryBuilder*(^ArrayBlock)(NSArray *array);

/** A block that takes a dictionary as its only argument. */
typedef EJDBFIQueryBuilder*(^DictionaryBlock)(NSDictionary *dictionary);

/** A block that takes a field path and an object as its arguments. Typically the object is either a string or array but doesn't have to be. */
typedef EJDBFIQueryBuilder*(^PathValueBlock)(NSString *fieldPath, id obj);

/** A block that takes a field path and a number as its arguments. */
typedef EJDBFIQueryBuilder*(^PathNumberBlock)(NSString *fieldPath, NSNumber *number);

/** A block that takes a field path and a string as its arguements. This is used mainly for substring type queries such as beginsWith. */
typedef EJDBFIQueryBuilder*(^StringsBlock)(NSString *fieldPath, NSString *string);

/** A block that takes an array of subqueries whose elements are themselves EJDBFIQueryBuilder objects. Used for and/or joins. */
typedef EJDBFIQueryBuilder*(^AndOrJoinBlock)(NSArray *subqueries);

/**
 This class is a utility to create ejdb queries in a programmatic fashion using a fluent interface paradigm.
 Instead of repeatedly sending messages you can chain multiple query construction steps.
 Every method in this class (excluding the build method) takes various types of blocks as "parameters"
 to make this happen.
 Note: They aren't really method parameters in the traditional sense as they are actually return values but syntactically they
 appear as such when written in code as the following example illustrates:
 
     [EJDBFIQueryBuilder build].match(@"a",@1).beginsWith(@"b",@"prefix");
 
 Take a look at the tests for more complex examples of using this class.
 If you are an objective-c purist and believe this is as an abomination :), take a look at the EJDBQueryBuilder
 class for a more traditional means of building queries.
*/
@interface EJDBFIQueryBuilder : NSObject

/**
 The dictionary representation of the query built so far.
 @returns query - An NSDictionary representation of the built query.
 @since - v0.3.0
*/
@property (strong,nonatomic,readonly) NSDictionary *query;
/**
 The dictionary representation of the hints built so far.
 @returns hints - An NSDictionary representation of the built hints.
 @since - v0.3.0
 */
@property (strong,nonatomic,readonly) NSDictionary *hints;

/**
 The class method that should be used to build queries. You can chain multiple block calls like so:
      
        [EJDBFIQueryBuilder build].match(@"a",@1).beginsWith(@"b",@"prefix");
 
 Or:
       
       [EJDBFIQueryBuilder build].match(@"a",@1)
                                 .beginsWith(@"b",@"prefix);
 
 You CANNOT however, do something like this:
 
       EJDBFIQueryBuilder *builder = [EJDBFIQueryBuilder build];
       build.match(@"a",@1).beginsWith(@"b",@"prefix");
 
 because the underlying dictionaries that hold the query and the hints are immutable and will be effectively
 "finalized" using the second approach.
*/
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
