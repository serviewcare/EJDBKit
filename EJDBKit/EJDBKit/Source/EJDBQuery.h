#import <Foundation/Foundation.h>
#include "tcejdb/ejdb.h"

typedef enum {
  /** Fetch only the count of records. */
  EJDBQueryCountOnly = 1,
  /** Fetch only the first record. */
  EJDBQueryFetchFirstOnly = 1 << 1
} EJDBQueryOptions;

@class EJDBCollection;

/**
 This class wraps the EJQ query object and provides a facility for fetching one or more objects.
 It's also possible to fetch objects multiple times, in other words the query is reusable.
 */
@interface EJDBQuery : NSObject

/** The query dictionary that will be used when executing the query. */
@property (strong,nonatomic) NSDictionary *query;

/** The hints dictionary that will be used when executing the query. */
@property (strong,nonatomic) NSDictionary *hints;

/**
 The designated initializer.It hooks the query to the collection it belongs to and sets query/hints.
 @param collection - The collection this query will belong to.
 @param query - The query that will be used when executing the query.
 @param hints - The hints that will be used when executing the query.
 @since - v0.2.0
*/
- (id)initWithCollection:(EJDBCollection *)collection query:(NSDictionary *)query hints:(NSDictionary *)hints;
/**
 A convenience initializer if you don't plan on providing hints for query execution.
 You can always do so at a later point by setting the hints property.
 @since - v0.2.0
*/
- (id)initWithCollection:(EJDBCollection *)collection query:(NSDictionary *)query;
/**
 The count of records returned by a query.
 @since - v0.1.0
*/
- (uint32_t)recordCount;
/**
 Executes the query but only fetches the amount of records instead of the results.
 @returns count - The count of records.
 @since - v0.1.0
*/
- (int)fetchCount;
/**
 Executes the query but only fetches the amount of records instead of the results.
 @param error - The error object that will be filled if there is an error.
 @returns - The count of records.
 @since - v0.2.0
*/
- (uint32_t)fetchCountWithError:(NSError **)error;
/** 
 Fetch a single object.
 @returns - The returned object or nil if not found.
 @since - v0.1.0
*/
- (id)fetchObject;
/**
 Fetch a single object.
 @param error - The error object that will be filled if there is an error.
 @returns - The returned object or nil if not found.
 @since - v0.2.0
*/
- (id)fetchObjectWithError:(NSError **)error;
/**
 Fetch an array of objects. You can safely call this method multiple times across the EJBDQuery's lifetime.
 @returns - An array of objects.
 @since - v0.1.0
*/
- (NSArray *)fetchObjects;
/**
 Fetch an array of objects. You can safely call this method multiple times across the EJBDQuery's lifetime.
 @param error - The error object that will be filled if there is an error.
 @returns - An array of objects.
 @since - v0.2.0
*/
- (NSArray *)fetchObjectsWithError:(NSError **)error;

@end