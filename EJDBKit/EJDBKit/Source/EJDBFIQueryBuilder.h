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
 "finalized" using the last approach.
*/
+ (EJDBFIQueryBuilder *)build;

/**
 Match the value parameter against the value of the field path.
 @param path - The field path whose value will be matched against the provided parameter.
 @param value - The value that will be used for matching.
 @since - v0.3.0
*/
- (PathValueBlock)match;
/**
 Build a query part whose field path value does not match the value provided in the value parameter.
 @param path - The field path whose value will be compared to the provided parameter.
 @param value - The value that should not match the value of the field path.
 @since - v0.3.0
*/
- (PathValueBlock)notMatch;
/**
 Match the string value against the value of the field path ignoring case.
 @param path - The field path whose value will be matched against the provided value.
 @param value - The value that will be used for matching ignoring case.
 @since - v0.3.0
*/
- (StringsBlock)matchIgnoreCase;
/**
 Match the substring value against the value of the field path.
 @param path - The field path whose value will be matched against the provided substring value.
 @param value - The substring value that will be used for matching.
 @since - v0.3.0
*/
- (StringsBlock)beginsWith;
/**
 Build a query part whose field path value does not match the substring value.
 @param path - The field path whose value should not match the provided substring value.
 @param value - The substring value that should not match the field path.
 @since - v0.3.0
*/
- (StringsBlock)notBeginsWith;
/**
 Match the number value that is greater than the value of the field path.
 @param path - The field path whose value should be greater than the provided value.
 @param value - The value to compare to the value of the field path.
 @since - v0.3.0
*/
- (PathNumberBlock)greaterThan;
/**
 Match the number value that is greater than or equal to the value of the field path.
 @param path - The field path whose value should be greater than or equal to the provided value.
 @param value - The value to compare to the value of the field path.
 @since - v0.3.0
*/
- (PathNumberBlock)greaterThanOrEqualTo;
/**
 Match the number value that is less than the value of the field path.
 @param path - The field path whose value should be less than the provided value.
 @param value - The value to compare to the value of the field path.
 @since - v0.3.0
*/
- (PathNumberBlock)lessThan;
/**
 Match the number value that is less than or equal to the value of the field path.
 @param path - The field path whose value should be less than or equal the provided value.
 @param value - The value to compare to the value of the field path.
 @since - v0.3.0
*/
- (PathNumberBlock)lessThanOrEqualTo;
/**
 Match the value of the field path that lies between the provided values.
 @param path - The field path whose value should lie between the provided values.
 @param values - An array of values.
 @since - v0.3.0
*/
- (PathValueBlock)between;
/**
 Match the value of the field path that is contained in the array of provided values.
 @param path - The field path whose value should be in the provided values.
 @param values - An array of values.
 @since - v0.3.0
*/
- (PathValueBlock)in;
/**
 Match the value of the field path that is contained in the array of provided values ignoring case.
 @param path - The field path whose value should be in the provided values ignoring case.
 @param inValues - An array of values.
 @since - v0.3.0
*/
- (PathValueBlock)inIgnoreCase;
/**
 Match the value of the field path that is not contained in the array of provided values.
 @param path - The field path whose value should not be in the provided values.
 @param inValues - An array of values.
 @since - v0.3.0
*/
- (PathValueBlock)notIn;
/**
 Match the value of the field path that is not contained in the array of provided values ignoring case.
 @param path - The field path whose value should not be in the provided values ignoring case.
 @param inValues - An array of values.
 @since - v0.3.0
*/
- (PathValueBlock)notInIgnoreCase;
/**
 Field path existence matching.
 @param path - The field path whose existence should be matched.
 @since - v0.3.0
*/
- (PathBlock)exists;
/**
 Field path non-existence matching.
 @param path - The field path whose existence should be matched.
 @since - v0.3.0
*/
- (PathBlock)notExists;
/**
 Match the value of the field path whose tokens match all of the tokens in the values provided.
 @param path - The field path whose values should be matched against the provided values.
 @param values - An array of string values.
 @since - v0.3.0
*/
- (PathValueBlock)stringAllIn;
/**
 Match the value of the field path whose tokens match any of the tokens in the values provided.
 @param path - The field path whose values should be matched against the provided values.
 @param values - An array of string values.
 @since - v0.3.0
*/
- (PathValueBlock)stringAnyIn;
/**
 Match more than one element in the field path array to the elements provided by the builder subquery.
 @param path - The field path whose value is an array.
 @param builder - The subquery whose elements match one or more elements of the field paths value.
 @since - v0.3.0
*/
- (PathValueBlock)elemsMatch;

/**
 Join a collection with the provided collection name.
 @param path - The field path whose OID(s) point to the OID(s) of the collection with the specified name.
 @param collectionName - The name of the collection to be joined.
 @since - v0.3.0
*/
- (StringsBlock)joinCollection;

/**
 And join. Please see: http://docs.mongodb.org/manual/reference/operator/and/#op._S_and
 @param subqueries - The subqueries for the and join. Should be an array of querybuilder objects.
 @since - v0.3.0
*/
- (AndOrJoinBlock)andJoin;
/**
 Or join. Please see: http://docs.mongodb.org/manual/reference/operator/or/
 @param subqueries - The subqueries for the or join. Should be an array of querybuilder objects.
 @since - v0.3.0
*/
- (AndOrJoinBlock)orJoin;
/**
 Projection operator. Please see: http://docs.mongodb.org/manual/reference/projection/positional/#proj._S_
 @param path - The path to apply the projection to.
 @since - v0.3.0
*/
- (PathBlock)projection;
/**
 Field set operation.
 @param keysAndValues - A dictionary containing the field paths as keys and values that the fields will be set to.
 @since - v0.3.0
*/
- (DictionaryBlock)set;
/**
 Upsert operation.
 If matching records are found a set operation will be used, otherwise a new record will be inserted
 with the keys and values.
 @param keysAndValues - A dictionary containing the field paths as keys and values that the fields will be set to or the fields
 of the record that will be inserted.
 @since - v0.3.0
*/
- (DictionaryBlock)upsert;
/**
 Increment operation. Values of the dictionary should be numbers only!
 @param keysAndValues - A dictionary containing the field paths as keys and number values that the fields will be incremented to.
 @since - v0.3.0
*/
- (DictionaryBlock)increment;
/**
 In place record removal.
 @since - v0.3.0
*/
- (EmptyBlock)dropAll;
/**
 Add to set operation.Atomically adds value to the array only if its not in the array already. If containing array is missing it will be created.
 @param keysAndValues - A dictionary containing the field paths as keys and the values that will be added to the array.
 @since - v0.3.0
*/
- (DictionaryBlock)addToSet;
/**
 Add to set all. Batch version of addToSet.
 @param keysAndValues - A dictionary containing the field paths as keys and the values as arrays that will be added to the array.
 @since - v0.3.0
*/
- (DictionaryBlock)addToSetAll;
/**
 Pull operation. Atomically removes all occurrences of values from field path, if field path value is an array.
 @param keysAndValues - A dictionary containing the field paths as key/values.
 @since - v0.3.0
*/
- (DictionaryBlock)pull;
/**
 Pull all operation. Batch version of pull.
 @param keysAndValues - A dictionary containing the field paths as key and the values as arrays that will be removed from the array.
 @since - v0.3.0
*/
- (DictionaryBlock)pullAll;
/**
 Maximum records that should be returned from a query. This is a query hint.
 @param number - The maximum number of records.
 @since - v0.3.0
*/
- (NumberBlock)maxRecords;
/**
 The amount of records that should be skipped for a query. This is a query hint.
 @param number - The number of records to skip.
 @since - v0.3.0
*/
- (NumberBlock)skipRecords;
/**
 Only the fields specified in the field array should be returned from the query. This is a query hint.
 @param fields - The array of the fields that should be returned from the query.
 @since - v0.3.0
*/
- (ArrayBlock)onlyFields;
/**
 The sorting order of the query. This is a query hint.
 @param fields - The array of sort orders. Each element must be an instance of EJDBQueryOrderByHint.
 @since - v0.3.0
*/
- (ArrayBlock)orderBy;
@end
