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

@property (strong,nonatomic) NSDictionary *query;

@property (strong,nonatomic) NSDictionary *hints;

- (id)initWithCollection:(EJDBCollection *)collection query:(NSDictionary *)query hints:(NSDictionary *)hints;

- (id)initWithCollection:(EJDBCollection *)collection query:(NSDictionary *)query;

/**
  The count of records returned by a query.
*/
- (NSUInteger)recordCount;

/**
 Executes the query but only fetches the amount of records instead of the results.
 @returns count - The count of records.
*/
- (int)fetchCount;

/**
 Executes the query but only fetches the amount of records instead of the results.
 @param error - The error object that will be filled if there is an error.
 @returns - The count of records.
*/
- (int)fetchCountWithError:(NSError **)error;

/** 
 Fetch a single object.
 @returns - The returned object or nil if not found.
*/
- (id)fetchObject;

/**
 Fetch a single object.
 @param error - The error object that will be filled if there is an error.
 @returns - The returned object or nil if not found.
*/
- (id)fetchObjectWithError:(NSError **)error;

/**
 Fetch an array of objects. You can safely call this method multiple times across the EJBDQuery's lifetime.
 @returns - An array of objects.
*/
- (NSArray *)fetchObjects;

/**
 Fetch an array of objects. You can safely call this method multiple times across the EJBDQuery's lifetime.
 @param error - The error object that will be filled if there is an error.
 @returns - An array of objects.
*/
- (NSArray *)fetchObjectsWithError:(NSError **)error;

@end
