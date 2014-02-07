#import <Foundation/Foundation.h>
#import "EJDBQueryBuilderDelegate.h"

/**
 This class is a utility to create ejdb queries in a programmatic fashion
 as opposed to hand coding queries with dictionaries.
*/
@interface EJDBQueryBuilder : NSObject <EJDBQueryBuilderDelegate>

/** 
 The dictionary representation of the query built so far.
 @returns query - An NSDictionary representation of the built query.
 @since - v0.3.0
*/
- (NSDictionary *)query;
/**
 The dictionary representation of the hints built so far.
 @returns hints - An NSDictionary representation of the built hints.
 @since - v0.3.0
*/
- (NSDictionary *)hints;
/**
 The dictionary representation of joins built so far.
 @returns joins - An NSDictionary representation of the built joins.
 @since - v0.6.0
*/
- (NSDictionary *)joins;
/**
 Match the value parameter against the value of the field path.
 @param path - The field path whose value will be matched against the provided parameter.
 @param value - The value that will be used for matching.
 @since - v0.3.0
*/
- (void)path:(NSString *)path matches:(id)value;
/**
 Build a query part whose field path value does not match the value provided in the value parameter.
 @param path - The field path whose value will be compared to the provided parameter.
 @param value - The value that should not match the value of the field path.
 @since - v0.3.0
*/
- (void)path:(NSString *)path notMatches:(id)value;
/**
 Match the string value against the value of the field path ignoring case.
 @param path - The field path whose value will be matched against the provided value.
 @param value - The value that will be used for matching ignoring case.
 @since - v0.3.0
*/
- (void)path:(NSString *)path matchesIgnoreCase:(NSString *)value;
/**
 Match the substring value against the value of the field path.
 @param path - The field path whose value will be matched against the provided substring value.
 @param value - The substring value that will be used for matching.
 @since - v0.3.0
*/
- (void)path:(NSString *)path beginsWith:(NSString *)value;
/**
 Build a query part whose field path value does not match the substring value.
 @param path - The field path whose value should not match the provided substring value.
 @param value - The substring value that should not match the field path.
 @since - v0.3.0
*/
- (void)path:(NSString *)path notBeginsWith:(NSString *)value;
/**
 Match the number value that is greater than the value of the field path.
 @param path - The field path whose value should be greater than the provided value.
 @param value - The value to compare to the value of the field path.
 @since - v0.3.0
*/
- (void)path:(NSString *)path greaterThan:(NSNumber *)number;
/**
 Match the number value that is greater than or equal to the value of the field path.
 @param path - The field path whose value should be greater than or equal to the provided value.
 @param value - The value to compare to the value of the field path.
 @since - v0.3.0
 
*/
- (void)path:(NSString *)path greaterThanOrEqualTo:(NSNumber *)number;
/**
 Match the number value that is less than the value of the field path.
 @param path - The field path whose value should be less than the provided value.
 @param value - The value to compare to the value of the field path.
 @since - v0.3.0
*/
- (void)path:(NSString *)path lessThan:(NSNumber *)number;
/**
 Match the number value that is less than or equal to the value of the field path.
 @param path - The field path whose value should be less than or equal the provided value.
 @param value - The value to compare to the value of the field path.
 @since - v0.3.0
*/
- (void)path:(NSString *)path lessThanOrEqualTo:(NSNumber *)number;
/**
 Match the value of the field path that lies between the provided values.
 @param path - The field path whose value should lie between the provided values.
 @param values - An array of values.
 @since - v0.3.0
*/
- (void)path:(NSString *)path between:(NSArray *)values;
/**
 Match the value of the field path that is contained in the array of provided values.
 @param path - The field path whose value should be in the provided values.
 @param values - An array of values.
 @since - v0.3.0
*/
- (void)path:(NSString *)path in:(NSArray *)inValues;
/**
 Match the value of the field path that is contained in the array of provided values ignoring case.
 @param path - The field path whose value should be in the provided values ignoring case.
 @param inValues - An array of values.
 @since - v0.3.0
*/
- (void)path:(NSString *)path inIgnoreCase:(NSArray *)inValues;
/**
 Match the value of the field path that is not contained in the array of provided values.
 @param path - The field path whose value should not be in the provided values.
 @param inValues - An array of values.
 @since - v0.3.0
*/
- (void)path:(NSString *)path notIn:(NSArray *)inValues;
/**
 Match the value of the field path that is not contained in the array of provided values ignoring case.
 @param path - The field path whose value should not be in the provided values ignoring case.
 @param inValues - An array of values.
 @since - v0.3.0
*/
- (void)path:(NSString *)path notInIgnoreCase:(NSArray *)inValues;
/**
 Field path existence matching.
 @param path - The field path whose existence should be matched.
 @param exists - Provide YES to assert the field exists or NO if not.
 @since - v0.3.0
*/
- (void)path:(NSString *)path exists:(BOOL)exists;
/**
 Match the value of the field path whose tokens match all of the tokens in the values provided.
 @param path - The field path whose values should be matched against the provided values.
 @param values - An array of string values.
 @since - v0.3.0
*/
- (void)path:(NSString *)path stringAllIn:(NSArray *)values;
/**
 Match the value of the field path whose tokens match any of the tokens in the values provided.
 @param path - The field path whose values should be matched against the provided values.
 @param values - An array of string values.
 @since - v0.3.0
*/
- (void)path:(NSString *)path stringAnyIn:(NSArray *)values;
/**
 Match more than one element in the field path array to the elements provided by the builder subquery.
 @param path - The field path whose value is an array.
 @param builder - The subquery whose elements match one or more elements of the field paths value.
 @since - v0.3.0
*/
- (void)path:(NSString *)path elementsMatch:(EJDBQueryBuilder *)builder;
/**
 This method is deprecated and will be removed in a future release! Use path:addCollectionToJoin instead!
 Join a collection with the provided collection name.
 @param path - The field path whose OID(s) point to the OID(s) of the collection with the specified name.
 @param collectionName - The name of the collection to be joined.
 @since - v0.3.0
*/
- (void)path:(NSString *)path joinCollectionNamed:(NSString *)collectionName __deprecated;

/**
 Add a collection name to the join dictionary.
 @param path - The field path whose OID(s) point to the OID(s) of the collection with the specified name.
 @param collectionName - The name of the collection to be joined.
 @since - v0.6.0
*/
- (void)path:(NSString *)path addCollectionToJoin:(NSString *)collectionName;

/**
 And join. Please see: http://docs.mongodb.org/manual/reference/operator/and/#op._S_and
 @param subqueries - The subqueries for the and join. Should be an array of querybuilder objects.
 @since - v0.3.0
*/
- (void)andJoin:(NSArray *)subqueries;
/**
 Or join. Please see: http://docs.mongodb.org/manual/reference/operator/or/
 @param subqueries - The subqueries for the or join. Should be an array of querybuilder objects.
 @since - v0.3.0
*/
- (void)orJoin:(NSArray *)subqueries;
/**
 Projection operator. Please see: http://docs.mongodb.org/manual/reference/projection/positional/#proj._S_
 @param path - The path to apply the projection to.
 @since - v0.3.0
*/
- (void)projectionForPath:(NSString *)path;
/**
 Field set operation.
 @param keysAndValues - A dictionary containing the field paths as keys and values that the fields will be set to.
 @since - v0.3.0
*/
- (void)set:(NSDictionary *)keysAndValues;
/**
 Field(s) unset operation.
 @param keys - An array containing the keys or keypaths that will be unset i.e. deleted.
 @since - v0.4.2
*/
- (void)unset:(NSArray *)keys;
/**
 Upsert operation.
 If matching records are found a set operation will be used, otherwise a new record will be inserted
 with the keys and values.
 @param keysAndValues - A dictionary containing the field paths as keys and values that the fields will be set to or the fields
 of the record that will be inserted.
 @since - v0.3.0
*/
- (void)upsert:(NSDictionary *)keysAndValues;
/**
 Increment operation. Values of the dictionary should be numbers only!
 @param keysAndValues - A dictionary containing the field paths as keys and number values that the fields will be incremented to.
 @since - v0.3.0
*/
- (void)increment:(NSDictionary *)keysAndValues;
/**
 In place record removal.
 @since - v0.3.0
*/
- (void)dropAll;
/**
 Add to set operation.Atomically adds value to the array only if its not in the array already. If containing array is missing it will be created.
 @param keysAndValues - A dictionary containing the field paths as keys and the values that will be added to the array.
 @since - v0.3.0
*/
- (void)addToSet:(NSDictionary *)keysAndValues;
/**
 Add to set all. Batch version of addToSet.
 @param keysAndValues - A dictionary containing the field paths as keys and the values as arrays that will be added to the array.
 @since - v0.3.0
*/
- (void)addToSetAll:(NSDictionary *)keysAndValues;
/**
 Pull operation. Atomically removes all occurrences of values from field path, if field path value is an array.
 @param keysAndValues - A dictionary containing the field paths as key/values.
 @since - v0.3.0
*/
- (void)pull:(NSDictionary *)keysAndValues;
/**
 Pull all operation. Batch version of pull.
 @param keysAndValues - A dictionary containing the field paths as key and the values as arrays that will be removed from the array.
 @since - v0.3.0
*/
- (void)pullAll:(NSDictionary *)keysAndValues;
/**
 Maximum records that should be returned from a query. This is a query hint.
 @param number - The maximum number of records.
 @since - v0.3.0
*/
- (void)maxRecords:(NSNumber *)number;
/**
 The amount of records that should be skipped for a query. This is a query hint.
 @param number - The number of records to skip.
 @since - v0.3.0
*/
- (void)skipRecords:(NSNumber *)number;
/**
 Only the fields specified in the field array should be returned from the query. This is a query hint.
 @param fields - The array of the fields that should be returned from the query.
 @since - v0.3.0
*/
- (void)onlyFields:(NSArray *)fields;
/**
 The sorting order of the query. This is a query hint.
 @param fields - The array of sort orders. Each element must be an instance of EJDBQueryOrderByHint.
 @since - v0.3.0
*/
- (void)orderBy:(NSArray *)fields;

@end